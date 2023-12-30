#include "CPUXMachineFunction.h"

#include "CPUXInstrInfo.h"
#include "CPUXSubtarget.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/IR/Function.h"

using namespace llvm;

bool FixGlobalBaseReg;

CPUXFunctionInfo::~CPUXFunctionInfo() {}

void CPUXFunctionInfo::anchor() {}
