#ifndef LLVM_LIB_TARGET_CPUX_CPUXFRAMELOWERING_H
#define LLVM_LIB_TARGET_CPUX_CPUXFRAMELOWERING_H

#include "CPUX.h"
#include "llvm/CodeGen/TargetFrameLowering.h"

namespace llvm {
class CPUXSubtarget;

class CPUXFrameLowering : public TargetFrameLowering {
protected:
  const CPUXSubtarget &STI;

public:
  explicit CPUXFrameLowering(const CPUXSubtarget &sti)
      : TargetFrameLowering(StackGrowsDown, /*StackAlignment=*/Align(16),
                            /*LocalAreaOffset=*/0),
        STI(sti) {}

  static const CPUXFrameLowering *create(const CPUXSubtarget &ST);

  bool hasFP(const MachineFunction &MF) const override;

  void emitPrologue(MachineFunction &MF, MachineBasicBlock &MBB) const override;
  void emitEpilogue(MachineFunction &MF, MachineBasicBlock &MBB) const override;
};
} // namespace llvm

#endif
