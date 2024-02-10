//===----- CPUXMergeBaseOffset.cpp - Optimise address calculations  ------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Merge the offset of address calculation into the offset field
// of instructions in a global address lowering sequence.
//
//===----------------------------------------------------------------------===//

#include "CPUX.h"
#include "CPUXTargetMachine.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/Debug.h"
#include "llvm/Target/TargetOptions.h"
#include <optional>
#include <set>
using namespace llvm;

#define DEBUG_TYPE "cpux-merge-base-offset"
#define CPUX_MERGE_BASE_OFFSET_NAME "CPUX Merge Base Offset"
namespace {

struct CPUXMergeBaseOffsetOpt : public MachineFunctionPass {
private:
  const CPUXSubtarget *ST = nullptr;

public:
  static char ID;
  bool runOnMachineFunction(MachineFunction &Fn) override;
  bool detectFoldable(MachineInstr &Hi, MachineInstr *&Lo);

  bool foldLargeOffset(MachineInstr &Hi, MachineInstr &Lo,
                       MachineInstr &TailAdd, Register GSReg);

  bool foldIntoMemoryOps(MachineInstr &Hi, MachineInstr &Lo);

  CPUXMergeBaseOffsetOpt() : MachineFunctionPass(ID) {}

  MachineFunctionProperties getRequiredProperties() const override {
    return MachineFunctionProperties().set(
        MachineFunctionProperties::Property::IsSSA);
  }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
    MachineFunctionPass::getAnalysisUsage(AU);
  }

  StringRef getPassName() const override { return CPUX_MERGE_BASE_OFFSET_NAME; }

private:
  MachineRegisterInfo *MRI;
};
} // end anonymous namespace

char CPUXMergeBaseOffsetOpt::ID = 0;

// Detect either of the patterns:
//
// 1. (medlow pattern):
//   lui   vreg1, %hi(s)
//   addi  vreg2, vreg1, %lo(s)
//
// 2. (medany pattern):
// .Lpcrel_hi1:
//   auipc vreg1, %pcrel_hi(s)
//   addi  vreg2, vreg1, %pcrel_lo(.Lpcrel_hi1)
//
// The pattern is only accepted if:
//    1) The first instruction has only one use, which is the ADDI.
//    2) The address operands have the appropriate type, reflecting the
//       lowering of a global address or constant pool using medlow or medany.
//    3) The offset value in the Global Address or Constant Pool is 0.
bool CPUXMergeBaseOffsetOpt::detectFoldable(MachineInstr &Hi,
                                            MachineInstr *&Lo) {
  if (Hi.getOpcode() != CPUX::LUI)
    return false;

  const MachineOperand &HiOp1 = Hi.getOperand(1);
  unsigned ExpectedFlags = CPUXII::MO_HI20;
  if (HiOp1.getTargetFlags() != ExpectedFlags)
    return false;

  if (!(HiOp1.isGlobal() || HiOp1.isCPI()) || HiOp1.getOffset() != 0)
    return false;

  Register HiDestReg = Hi.getOperand(0).getReg();
  if (!MRI->hasOneUse(HiDestReg))
    return false;

  Lo = &*MRI->use_instr_begin(HiDestReg);
  if (Lo->getOpcode() != CPUX::ADDI)
    return false;

  const MachineOperand &LoOp2 = Lo->getOperand(2);
  if (Hi.getOpcode() == CPUX::LUI) {
    if (LoOp2.getTargetFlags() != CPUXII::MO_LO12_I ||
        !(LoOp2.isGlobal() || LoOp2.isCPI()) || LoOp2.getOffset() != 0)
      return false;
  }
  if (HiOp1.isGlobal()) {
    LLVM_DEBUG(dbgs() << "  Found lowered global address: "
                      << *HiOp1.getGlobal() << "\n");
  } else {
    assert(HiOp1.isCPI());
    LLVM_DEBUG(dbgs() << "  Found lowered constant pool: " << HiOp1.getIndex()
                      << "\n");
  }

  return true;
}

// Detect patterns for large offsets that are passed into an ADD instruction.
// If the pattern is found, updates the offset in Hi and Lo instructions
// and deletes TailAdd and the instructions that produced the offset.
//
//                     Base address lowering is of the form:
//                       Hi:  lui   vreg1, %hi(s)
//                       Lo:  addi  vreg2, vreg1, %lo(s)
//                       /                                  \
//                      /                                    \
//                     /                                      \
//                    /  The large offset can be of two forms: \
//  1) Offset that has non zero bits in lower      2) Offset that has non zero
//     12 bits and upper 20 bits                      bits in upper 20 bits only
//   OffseLUI: lui   vreg3, 4
// OffsetTail: addi  voff, vreg3, 188                OffsetTail: lui  voff, 128
//                    \                                        /
//                     \                                      /
//                      \                                    /
//                       \                                  /
//                         TailAdd: add  vreg4, vreg2, voff

// Detect patterns for offsets that are passed into a SHXADD instruction.
// The offset has 1, 2, or 3 trailing zeros and fits in simm13, simm14, simm15.
// The constant is created with addi voff, x0, C, and shXadd is used to
// fill insert the trailing zeros and do the addition.
// If the pattern is found, updates the offset in Hi and Lo instructions
// and deletes TailShXAdd and the instructions that produced the offset.
//
// Hi:         lui     vreg1, %hi(s)
// Lo:         addi    vreg2, vreg1, %lo(s)
// OffsetTail: addi    voff, x0, C
// TailAdd:    shXadd  vreg4, voff, vreg2
bool CPUXMergeBaseOffsetOpt::foldIntoMemoryOps(MachineInstr &Hi,
                                               MachineInstr &Lo) {
  Register DestReg = Lo.getOperand(0).getReg();

  // If all the uses are memory ops with the same offset, we can transform:
  //
  // 1. (medlow pattern):
  // Hi:   lui vreg1, %hi(foo)          --->  lui vreg1, %hi(foo+8)
  // Lo:   addi vreg2, vreg1, %lo(foo)  --->  lw vreg3, lo(foo+8)(vreg1)
  // Tail: lw vreg3, 8(vreg2)
  //
  // 2. (medany pattern):
  // Hi: 1:auipc vreg1, %pcrel_hi(s)         ---> auipc vreg1, %pcrel_hi(foo+8)
  // Lo:   addi  vreg2, vreg1, %pcrel_lo(1b) ---> lw vreg3, %pcrel_lo(1b)(vreg1)
  // Tail: lw vreg3, 8(vreg2)

  std::optional<int64_t> CommonOffset;
  for (const MachineInstr &UseMI : MRI->use_instructions(DestReg)) {
    switch (UseMI.getOpcode()) {
    default:
      LLVM_DEBUG(dbgs() << "Not a load or store instruction: " << UseMI);
      return false;
    case CPUX::LW:
    case CPUX::FLW:
    case CPUX::SW:
    case CPUX::FSW: {
      if (UseMI.getOperand(1).isFI())
        return false;
      // Register defined by Lo should not be the value register.
      if (DestReg == UseMI.getOperand(0).getReg())
        return false;
      assert(DestReg == UseMI.getOperand(1).getReg() &&
             "Expected base address use");
      // All load/store instructions must use the same offset.
      int64_t Offset = UseMI.getOperand(2).getImm();
      if (CommonOffset && Offset != CommonOffset)
        return false;
      CommonOffset = Offset;
    }
    }
  }

  // We found a common offset.
  // Update the offsets in global address lowering.
  // We may have already folded some arithmetic so we need to add to any
  // existing offset.
  int64_t NewOffset = Hi.getOperand(1).getOffset() + *CommonOffset;
  // RV32 ignores the upper 32 bits.
  NewOffset = SignExtend64<32>(NewOffset);
  // We can only fold simm32 offsets.
  if (!isInt<32>(NewOffset))
    return false;

  Hi.getOperand(1).setOffset(NewOffset);
  MachineOperand &ImmOp = Lo.getOperand(2);
  ImmOp.setOffset(NewOffset);

  // Update the immediate in the load/store instructions to add the offset.
  for (MachineInstr &UseMI :
       llvm::make_early_inc_range(MRI->use_instructions(DestReg))) {
    UseMI.removeOperand(2);
    UseMI.addOperand(ImmOp);
    // Update the base reg in the Tail instruction to feed from LUI.
    // Output of Hi is only used in Lo, no need to use MRI->replaceRegWith().
    UseMI.getOperand(1).setReg(Hi.getOperand(0).getReg());
  }

  Lo.eraseFromParent();
  return true;
}

bool CPUXMergeBaseOffsetOpt::runOnMachineFunction(MachineFunction &Fn) {
  if (skipFunction(Fn.getFunction()))
    return false;

  ST = &Fn.getSubtarget<CPUXSubtarget>();

  bool MadeChange = false;
  MRI = &Fn.getRegInfo();
  for (MachineBasicBlock &MBB : Fn) {
    LLVM_DEBUG(dbgs() << "MBB: " << MBB.getName() << "\n");
    for (MachineInstr &Hi : MBB) {
      MachineInstr *Lo = nullptr;
      if (!detectFoldable(Hi, Lo))
        continue;
      MadeChange |= foldIntoMemoryOps(Hi, *Lo);
    }
  }

  return MadeChange;
}

/// Returns an instance of the Merge Base Offset Optimization pass.
FunctionPass *llvm::createCPUXMergeBaseOffsetOptPass() {
  return new CPUXMergeBaseOffsetOpt();
}
