#include "CPUX.h"
#include "llvm/IR/Module.h"
#include "llvm/MC/TargetRegistry.h"

using namespace llvm;

namespace llvm {
Target &getTheCPUXTarget() {
  static Target TheCPUXTarget;
  return TheCPUXTarget;
}
} // namespace llvm

extern "C" void LLVMInitializeCPUXTargetInfo() {
  RegisterTarget<Triple::cpux, /*HasJIT=*/true> X(getTheCPUXTarget(), "cpux",
                                                  "CPUX (32-bit)", "CPUX");
}
