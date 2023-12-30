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

  /// Return the number of bytes of code the specified instruction may be
  unsigned GetInstSizeInBytes(const MachineInstr &MI) const;
};
} // namespace llvm

#endif
