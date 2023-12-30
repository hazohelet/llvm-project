#ifndef LLVM_LIB_TARGET_CPUX_CPUXTARGETOBJECTFILE_H
#define LLVM_LIB_TARGET_CPUX_CPUXTARGETOBJECTFILE_H

#include "CPUXTargetMachine.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"

namespace llvm {
class CPUXTargetMachine;

class CPUXTargetObjectFile : public TargetLoweringObjectFileELF {
  const CPUXTargetMachine *TM;

public:
  void Initialize(MCContext &Ctx, const TargetMachine &TM) override;
};
} // namespace llvm

#endif
