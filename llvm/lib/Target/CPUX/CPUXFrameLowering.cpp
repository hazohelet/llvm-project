#include "CPUXFrameLowering.h"

#include "CPUXInstrInfo.h"
#include "CPUXMachineFunction.h"
#include "CPUXSubtarget.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Target/TargetOptions.h"

using namespace llvm;

void CPUXFrameLowering::emitPrologue(MachineFunction &MF,
                                     MachineBasicBlock &MBB) const {
  assert(&MF.front() == &MBB && "Shrink-wrapping not yet supported");
  MachineFrameInfo &MFI = MF.getFrameInfo();

  const CPUXInstrInfo &TII =
      *static_cast<const CPUXInstrInfo *>(STI.getInstrInfo());

  MachineBasicBlock::iterator MBBI = MBB.begin();
  DebugLoc dl = MBBI != MBB.end() ? MBBI->getDebugLoc() : DebugLoc();
  unsigned SP = CPUX::SP;

  uint64_t StackSize = MFI.getStackSize();

  if (StackSize == 0 && !MFI.adjustsStack())
    return;

  MachineModuleInfo &MMI = MF.getMMI();
  const MCRegisterInfo *MRI = MMI.getContext().getRegisterInfo();

  TII.adjustStackPtr(SP, -StackSize, MBB, MBBI);

  unsigned CFIIndex = MF.addFrameInst(
      MCCFIInstruction::cfiDefCfaOffset(/*L=*/nullptr, -StackSize));

  BuildMI(MBB, MBBI, dl, TII.get(CPUX::CFI_INSTRUCTION)).addCFIIndex(CFIIndex);

  const std::vector<CalleeSavedInfo> &CSI = MFI.getCalleeSavedInfo();

  if (CSI.size() > 0) {
    for (unsigned I = 0; I < CSI.size(); ++I)
      ++MBBI;

    for (auto &CS : CSI) {
      int64_t Offset = MFI.getObjectOffset(CS.getFrameIdx());
      unsigned Reg = CS.getReg();

      unsigned CFIIndex = MF.addFrameInst(MCCFIInstruction::createOffset(
          /*L=*/nullptr, MRI->getDwarfRegNum(Reg, /*isEH=*/true), Offset));
      BuildMI(MBB, MBBI, dl, TII.get(TargetOpcode::CFI_INSTRUCTION))
          .addCFIIndex(CFIIndex);
    }
  }
}

void CPUXFrameLowering::emitEpilogue(MachineFunction &MF,
                                     MachineBasicBlock &MBB) const {
  MachineBasicBlock::iterator MBBI = MBB.getLastNonDebugInstr();
  MachineFrameInfo &MFI = MF.getFrameInfo();

  const CPUXInstrInfo &TII =
      *static_cast<const CPUXInstrInfo *>(STI.getInstrInfo());

  DebugLoc dl = MBBI->getDebugLoc();

  unsigned SP = CPUX::SP;

  uint64_t StackSize = MFI.getStackSize();

  if (StackSize == 0)
    return;

  TII.adjustStackPtr(SP, StackSize, MBB, MBBI);
}

/// hasFP - Return true if the specified function should have a dedicated frame
/// pointer register, especially in case of vararg functions (In our use case,
/// this does not hold)
bool CPUXFrameLowering::hasFP(const MachineFunction &MF) const {
  const MachineFrameInfo &MFI = MF.getFrameInfo();
  const TargetRegisterInfo *TRI = STI.getRegisterInfo();

  return MF.getTarget().Options.DisableFramePointerElim(MF) ||
         MFI.hasVarSizedObjects() || MFI.isFrameAddressTaken() ||
         TRI->hasStackRealignment(MF);
}
