#ifndef LLVM_LIB_TARGET_CPUX_CPUXINSTRINFO_H
#define LLVM_LIB_TARGET_CPUX_CPUXINSTRINFO_H

#include "CPUX.h"
#include "CPUXRegisterInfo.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/TargetInstrInfo.h"

#define GET_INSTRINFO_HEADER
#include "CPUXGenInstrInfo.inc"

namespace llvm {
class CPUXInstrInfo : public CPUXGenInstrInfo {
  virtual void anchor();

public:
  explicit CPUXInstrInfo();

  static const CPUXInstrInfo *create(CPUXSubtarget &STI);

  void copyPhysReg(MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI,
                   const DebugLoc &DL, MCRegister DstReg, MCRegister SrcReg,
                   bool KillSrc) const override;

  /// Return the number of bytes of code the specified instruction may be
  unsigned GetInstSizeInBytes(const MachineInstr &MI) const;

  void expandRetRA(MachineBasicBlock &MBB, MachineBasicBlock::iterator I) const;
  bool expandPostRAPseudo(MachineInstr &MI) const override;

  void adjustStackPtr(unsigned SP, int64_t Amount, MachineBasicBlock &MBB,
                      MachineBasicBlock::iterator I) const;
  void loadImmediate(int32_t Imm, MachineBasicBlock &MBB,
                     MachineBasicBlock::iterator II, const DebugLoc &DL,
                     MCRegister DstReg) const;
  void storeRegToStackSlot(MachineBasicBlock &MBB,
                           MachineBasicBlock::iterator MBBI, Register SrcReg,
                           bool IsKill, int FI, const TargetRegisterClass *RC,
                           const TargetRegisterInfo *TRI,
                           Register VReg) const override;
  void loadRegFromStackSlot(MachineBasicBlock &MBB,
                            MachineBasicBlock::iterator I, Register DestReg,
                            int FI, const TargetRegisterClass *RC,
                            const TargetRegisterInfo *TRI,
                            Register VReg) const override;
};
} // namespace llvm

#endif
