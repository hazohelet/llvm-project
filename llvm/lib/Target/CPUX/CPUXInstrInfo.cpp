#include "CPUXInstrInfo.h"

#include "CPUXMachineFunction.h"
#include "CPUXTargetMachine.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

#define GET_INSTRINFO_CTOR_DTOR
#include "CPUXGenInstrInfo.inc"

void CPUXInstrInfo::anchor() {}

CPUXInstrInfo::CPUXInstrInfo() {}

unsigned CPUXInstrInfo::GetInstSizeInBytes(const MachineInstr &MI) const {
  switch (MI.getOpcode()) {
  default:
    return MI.getDesc().getSize();
  }
}

void CPUXInstrInfo::copyPhysReg(MachineBasicBlock &MBB,
                                MachineBasicBlock::iterator MBBI,
                                const DebugLoc &DL, MCRegister DstReg,
                                MCRegister SrcReg, bool KillSrc) const {
  // For integer registers,
  // mv rd, rs -> addi rd, rs, 0
  if (CPUX::GPRRegClass.contains(DstReg, SrcReg)) {
    BuildMI(MBB, MBBI, DL, get(CPUX::ADDI), DstReg)
        .addReg(SrcReg, getKillRegState(KillSrc))
        .addImm(0);
    return;
  }
  llvm_unreachable("Floating point yet to be implemented");
}
bool CPUXInstrInfo::expandPostRAPseudo(MachineInstr &MI) const {
  MachineBasicBlock &MBB = *MI.getParent();

  switch (MI.getDesc().getOpcode()) {
  default:
    return false;
  case CPUX::RetRA:
    expandRetRA(MBB, MI);
    break;
  }
  MBB.erase(MI);
  return true;
}

void CPUXInstrInfo::adjustStackPtr(unsigned SP, int64_t Amount,
                                   MachineBasicBlock &MBB,
                                   MachineBasicBlock::iterator I) const {
  DebugLoc DL = I != MBB.end() ? I->getDebugLoc() : DebugLoc();

  unsigned ADD = CPUX::ADD;
  unsigned ADDI = CPUX::ADDI;

  if (isInt<12>(Amount)) {
    BuildMI(MBB, I, DL, get(ADDI), SP).addReg(SP).addImm(Amount);
  } else {
    MachineFunction &MF = *MBB.getParent();
    MachineRegisterInfo &MRI = MF.getRegInfo();
    MCRegister Reg = MRI.createVirtualRegister(&CPUX::GPRRegClass);

    loadImmediate(Amount, MBB, I, DL, Reg);
    BuildMI(MBB, I, DL, get(ADD), SP).addReg(SP).addReg(Reg, RegState::Kill);
  }
}

void CPUXInstrInfo::expandRetRA(MachineBasicBlock &MBB,
                                MachineBasicBlock::iterator I) const {
  BuildMI(MBB, I, I->getDebugLoc(), get(CPUX::JALR))
      .addReg(CPUX::ZERO)
      .addReg(CPUX::RA)
      .addImm(0);
}

void CPUXInstrInfo::loadImmediate(int32_t Imm, MachineBasicBlock &MBB,
                                  MachineBasicBlock::iterator II,
                                  const DebugLoc &DL, MCRegister DstReg) const {
  uint32_t Hi20 = ((Imm + 0x800) >> 12) & 0xfffff;
  uint32_t Lo12 = SignExtend32<12>(Imm);

  BuildMI(MBB, II, DL, get(CPUX::LUI), DstReg).addImm(Hi20);
  BuildMI(MBB, II, DL, get(CPUX::ADDI), DstReg).addReg(DstReg).addImm(Lo12);
}
