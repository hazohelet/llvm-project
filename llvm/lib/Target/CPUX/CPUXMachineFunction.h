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
  CPUXFunctionInfo(MachineFunction &MF) : MF(MF), VarArgsFrameIndex(0) {}

  ~CPUXFunctionInfo();

  int getVarArgsFrameIndex() const { return VarArgsFrameIndex; }
  void setVarArgsFrameIndex(int Index) { VarArgsFrameIndex = Index; }

private:
  virtual void anchor();

  MachineFunction &MF;

  int VarArgsFrameIndex;
};
} // namespace llvm

#endif
