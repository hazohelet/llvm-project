#include "CPUXRegisterInfo.h"
#include "CPUX.h"
#include "CPUXMachineFunction.h"
#include "CPUXSubtarget.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define DEBUG_TYPE "CPUX-reg-info"

#define GET_REGINFO_TARGET_DESC
#include "CPUXGenRegisterInfo.inc"

CPUXRegisterInfo::CPUXRegisterInfo(const CPUXSubtarget &ST, unsigned HwMode)
    : CPUXGenRegisterInfo(CPUX::RA, /*DwarfFlavour=*/0, /*EHFlavour=*/0,
                          /*PC=*/0, HwMode),
      Subtarget(ST) {}

const TargetRegisterClass *CPUXRegisterInfo::intRegClass(unsigned Size) const {
  return &CPUX::GPRRegClass;
}

const MCPhysReg *
CPUXRegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
  return CSR_LP32_SaveList;
}

const uint32_t *
CPUXRegisterInfo::getCallPreservedMask(const MachineFunction &MF,
                                       CallingConv::ID) const {
  return CSR_LP32_RegMask;
}

BitVector CPUXRegisterInfo::getReservedRegs(const MachineFunction &MF) const {
  static const std::array<uint16_t, 6> ReservedCPURegs = {
      CPUX::ZERO, CPUX::RA, CPUX::SP, CPUX::FP, CPUX::GP, CPUX::TP,
  };
  BitVector Reserved(getNumRegs());

  for (unsigned I = 0; I < ReservedCPURegs.size(); ++I)
    Reserved.set(ReservedCPURegs[I]);

  return Reserved;
}

bool CPUXRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
                                           int SPAdj, unsigned FIOperandNum,
                                           RegScavenger *RS) const {
  MachineInstr &MI = *II;
  MachineFunction &MF = *MI.getParent()->getParent();
  MachineFrameInfo &MFI = MF.getFrameInfo();

  unsigned I = 0;
  while (!MI.getOperand(I).isFI()) {
    ++I;
    assert(I < MI.getNumOperands() && "Instr doesn't have FrameIndex operand!");
  }

  LLVM_DEBUG(errs() << "\nFunction : " << MF.getFunction().getName() << "\n";
             errs() << "<--------->\n"
                    << MI);

  int FrameIndex = MI.getOperand(I).getIndex();

  uint64_t StackSize = MFI.getStackSize();
  int64_t SPOffset = MFI.getObjectOffset(FrameIndex);

  LLVM_DEBUG(errs() << "FrameIndex : " << FrameIndex << "\n"
                    << "StackSize : " << StackSize << "\n"
                    << "SPOffset  : " << SPOffset << "\n");

  unsigned FrameReg = CPUX::SP;
  int64_t Offset = SPOffset + StackSize + MI.getOperand(I + 1).getImm();

  LLVM_DEBUG(errs() << "FrameReg  : " << FrameReg << "\n"
                    << "Offset    : " << Offset << "\n");

  if (!MI.isDebugValue() && !isInt<12>(Offset)) {
    assert(!MI.isDebugValue() && !isInt<16>(Offset));
  }

  MI.getOperand(I).ChangeToRegister(FrameReg, false);
  MI.getOperand(I + 1).ChangeToImmediate(Offset);

  return true;
}

bool CPUXRegisterInfo::requiresRegisterScavenging(
    const MachineFunction &MF) const {
  return true;
}

bool CPUXRegisterInfo::trackLivenessAfterRegAlloc(
    const MachineFunction &MF) const {
  return true;
}

Register CPUXRegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  const TargetFrameLowering *TFI = MF.getSubtarget().getFrameLowering();
  return TFI->hasFP(MF) ? CPUX::FP : CPUX::SP;
}
