#include "CPUXTargetMachine.h"
#include "CPUX.h"
#include "CPUXISelDAGToDAG.h"
#include "CPUXMachineFunction.h"
#include "CPUXTargetObjectFile.h"

#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/MC/TargetRegistry.h"

using namespace llvm;

extern "C" void LLVMInitializeCPUXTarget() {
  RegisterTargetMachine<CPUXTargetMachine> X(getTheCPUXTarget());
}

static std::string computeDataLayout(const Triple &TT, StringRef CPU,
                                     const TargetOptions &Options) {
  // riscv-32 has S128 at the end
  return "e-m:e-p:32:32-i8:8:32-i16:16:32-i64:64-n32-S64";
}

static Reloc::Model getEffectiveRelocModel(bool JIT,
                                           std::optional<Reloc::Model> RM) {
  if (!RM || JIT)
    return Reloc::Static;
  return *RM;
}

CPUXTargetMachine::CPUXTargetMachine(const Target &T, const Triple &TT,
                                     StringRef CPU, StringRef FS,
                                     const TargetOptions &Options,
                                     std::optional<Reloc::Model> RM,
                                     std::optional<CodeModel::Model> CM,
                                     CodeGenOpt::Level OL, bool JIT)
    : LLVMTargetMachine(T, computeDataLayout(TT, CPU, Options), TT, CPU, FS,
                        Options, getEffectiveRelocModel(JIT, RM),
                        getEffectiveCodeModel(CM, CodeModel::Small), OL),
      TLOF(std::make_unique<CPUXTargetObjectFile>()),
      ABI(CPUXABIInfo::computeTargetABI(Options.MCOptions.getABIName())),
      DefaultSubtarget(TT, CPU, /*TuneCPU=*/CPU, FS, *this) {
  initAsmInfo();
}

CPUXTargetMachine::~CPUXTargetMachine() {}
void CPUXTargetMachine::anchor() {}

namespace {
class CPUXPassConfig : public TargetPassConfig {
public:
  CPUXPassConfig(CPUXTargetMachine &TM, PassManagerBase &PM)
      : TargetPassConfig(TM, PM) {}

  CPUXTargetMachine &getCPUXTargetMachine() const {
    return getTM<CPUXTargetMachine>();
  }

  bool addInstSelector() override;
  void addPreRegAlloc() override;
};
} // namespace

TargetPassConfig *CPUXTargetMachine::createPassConfig(PassManagerBase &PM) {
  return new CPUXPassConfig(*this, PM);
}

bool CPUXPassConfig::addInstSelector() {
  addPass(createCPUXISelDag(getCPUXTargetMachine(), getOptLevel()));
  return false;
}

MachineFunctionInfo *CPUXTargetMachine::createMachineFunctionInfo(
    BumpPtrAllocator &Allocator, const Function &F,
    const TargetSubtargetInfo *STI) const {
  return CPUXFunctionInfo::create<CPUXFunctionInfo>(Allocator, F, STI);
}

void CPUXPassConfig::addPreRegAlloc() {
  addPass(createCPUXMergeBaseOffsetOptPass());
}
