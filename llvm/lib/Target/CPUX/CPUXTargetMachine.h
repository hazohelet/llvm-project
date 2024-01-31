#ifndef LLVM_LIB_TARGET_CPUX_CPUXTARGETMACHINE_H
#define LLVM_LIB_TARGET_CPUX_CPUXTARGETMACHINE_H

#include "CPUXSubtarget.h"
#include "MCTargetDesc/CPUXABIInfo.h"
#include "MCTargetDesc/CPUXMCTargetDesc.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/CodeGen/TargetFrameLowering.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {
class formatted_raw_ostream;
class CPUXRegisterInfo;

class CPUXTargetMachine : public LLVMTargetMachine {
  std::unique_ptr<TargetLoweringObjectFile> TLOF;
  CPUXABIInfo ABI;
  CPUXSubtarget DefaultSubtarget;

  mutable StringMap<std::unique_ptr<CPUXSubtarget>> SubtargetMap;

public:
  virtual void anchor();
  CPUXTargetMachine(const Target &T, const Triple &TT, StringRef CPU,
                    StringRef FS, const TargetOptions &Options,
                    std::optional<Reloc::Model> RM,
                    std::optional<CodeModel::Model> CM, CodeGenOpt::Level OL,
                    bool JIT);
  ~CPUXTargetMachine() override;

  const CPUXSubtarget *getSubtargetImpl(const Function &) const override {
    return &DefaultSubtarget;
  }

  TargetPassConfig *createPassConfig(PassManagerBase &PM) override;

  TargetLoweringObjectFile *getObjFileLowering() const override {
    return TLOF.get();
  }
  const CPUXABIInfo &getABI() const { return ABI; }

  MachineFunctionInfo *
  createMachineFunctionInfo(BumpPtrAllocator &Allocator, const Function &F,
                            const TargetSubtargetInfo *STI) const override;
};

} // namespace llvm

#endif
