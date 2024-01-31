#include "CPUXMachineFunction.h"

#include "CPUXInstrInfo.h"
#include "CPUXSubtarget.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/IR/Function.h"

using namespace llvm;

bool FixGlobalBaseReg;

CPUXFunctionInfo::~CPUXFunctionInfo() {}

MachineFunctionInfo *
CPUXFunctionInfo::clone(BumpPtrAllocator &Allocator, MachineFunction &DestMF,
                        const DenseMap<MachineBasicBlock *, MachineBasicBlock *>
                            &Src2DstMBB) const {
  return DestMF.cloneInfo<CPUXFunctionInfo>(*this);
}
