#include "CPUXTargetMachine.h"

#include "llvm/IR/LegacyPassManager.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/MC/TargetRegistry.h"

using namespace llvm;

#define DEBUG_TYPE "CPUX"

extern "C" void LLVMInitializeCPUXTarget() {
}
