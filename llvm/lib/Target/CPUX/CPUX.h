#ifndef LLVM_LIB_TARGET_CPUX_CPUX_H
#define LLVM_LIB_TARGET_CPUX_CPUX_H

#include "MCTargetDesc/CPUXMCTargetDesc.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {
class CPUXTargetMachine;
class FunctionPass;
FunctionPass *createCPUXMergeBaseOffsetOptPass();
} // namespace llvm

#endif
