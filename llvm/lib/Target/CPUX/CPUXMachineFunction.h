#ifndef LLVM_LIB_TARGET_CPUX_CPUXMACHINEFUNCTION_H
#define LLVM_LIB_TARGET_CPUX_CPUXMACHINEFUNCTION_H

#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineMemOperand.h"
#include "llvm/CodeGen/PseudoSourceValue.h"
#include "llvm/Target/TargetMachine.h"
#include <map>

namespace llvm {
class CPUXFunctionInfo : public MachineFunctionInfo {
public:
  CPUXFunctionInfo(const Function &F, const TargetSubtargetInfo *STI) {}

  ~CPUXFunctionInfo();

  int getVarArgsFrameIndex() const { return VarArgsFrameIndex; }
  void setVarArgsFrameIndex(int Index) { VarArgsFrameIndex = Index; }

  bool HasByvalArg;
  unsigned IncomingArgSize;

  void setFormalArgInfo(unsigned Size, bool HasByval) {
    IncomingArgSize = Size;
    HasByvalArg = HasByval;
  }

  unsigned getIncomingArgSize() const { return IncomingArgSize; }
  bool hasByvalArg() const { return HasByvalArg; }
  MachineFunctionInfo *
  clone(BumpPtrAllocator &Allocator, MachineFunction &DestMF,
        const DenseMap<MachineBasicBlock *, MachineBasicBlock *> &Src2DstMBB)
      const override;

private:
  int VarArgsFrameIndex;
};
} // namespace llvm

#endif
