#ifndef LLVM_LIB_TARGET_CPUX_CPUXREGISTERINFO_H
#define LLVM_LIB_TARGET_CPUX_CPUXREGISTERINFO_H

#include "CPUX.h"
#include "llvm/CodeGen/TargetRegisterInfo.h"

#define GET_REGINFO_HEADER
#include "CPUXGenRegisterInfo.inc"

namespace llvm {
class CPUXSubtarget;
class TargetInstrInfo;
class Type;

class CPUXRegisterInfo : public CPUXGenRegisterInfo {
protected:
  const CPUXSubtarget &Subtarget;

public:
  CPUXRegisterInfo(const CPUXSubtarget &STI, unsigned HwMode);

  const MCPhysReg *getCalleeSavedRegs(const MachineFunction *MF) const override;
  const uint32_t *getCallPreservedMask(const MachineFunction &MF,
                                       CallingConv::ID) const override;

  BitVector getReservedRegs(const MachineFunction &MF) const override;

  bool requiresRegisterScavenging(const MachineFunction &MF) const override;
  bool trackLivenessAfterRegAlloc(const MachineFunction &MF) const override;

  /// Stack Frame Processing Methods
  bool eliminateFrameIndex(MachineBasicBlock::iterator II, int SPAdj,
                           unsigned FIOperandNum,
                           RegScavenger *RS = nullptr) const override;
  /// Debug information queries.
  Register getFrameRegister(const MachineFunction &MF) const override;

  /// \brief Return GPR register class.
  virtual const TargetRegisterClass *intRegClass(unsigned Size) const;
};
} // namespace llvm

#endif
