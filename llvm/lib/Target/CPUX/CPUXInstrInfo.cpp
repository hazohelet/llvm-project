#include "CPUXInstrInfo.h"

#include "CPUXMachineFunction.h"
#include "CPUXTargetMachine.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

#define GET_INSTRINFO_CTOR_DTOR
#include "CPUXGenInstrInfo.inc"

void CPUXInstrInfo::anchor() {}

CPUXInstrInfo::CPUXInstrInfo() {}

unsigned CPUXInstrInfo::GetInstSizeInBytes(const MachineInstr &MI) const {
  switch (MI.getOpcode()) {
  default:
    return MI.getDesc().getSize();
  }
}
