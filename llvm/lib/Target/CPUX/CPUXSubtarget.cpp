#include "CPUXSubtarget.h"

#include "CPUX.h"
#include "CPUXMachineFunction.h"
#include "CPUXRegisterInfo.h"

#include "CPUXTargetMachine.h"
#include "llvm/IR/Attributes.h"
#include "llvm/IR/Function.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

#define DEBUG_TYPE "CPUX-subtarget"

#define GET_SUBTARGETINFO_TARGET_DESC
#define GET_SUBTARGETINFO_CTOR
#define None std::nullopt
#include "CPUXGenSubtargetInfo.inc"
#undef None

extern bool FixGlobalBaseReg;

void CPUXSubtarget::anchor() {}

CPUXSubtarget::CPUXSubtarget(const Triple &TT, StringRef CPU, StringRef TuneCPU,
                             StringRef FS, const CPUXTargetMachine &_TM)
    : CPUXGenSubtargetInfo(TT, CPU, TuneCPU, FS), TM(_TM), TargetTriple(TT),
      TSInfo(), InstrInfo(),
      FrameLowering(initializeSubtargetDependencies(CPU, TuneCPU, FS, TM)),
      TLInfo(TM, *this), RegInfo(*this, getHwMode()) {}

bool CPUXSubtarget::isPositionIndependent() const {
  return TM.isPositionIndependent();
}

CPUXSubtarget &CPUXSubtarget::initializeSubtargetDependencies(
    StringRef CPU, StringRef TuneCPU, StringRef FS, const TargetMachine &TM) {
  if (CPU.empty() || CPU == "generic")
    CPU = "cpux-rv32";

  ParseSubtargetFeatures(CPU, TuneCPU, FS);
  InstrItins = getInstrItineraryForCPU(CPU);

  return *this;
}

bool CPUXSubtarget::abiUsesSoftFloat() const { return false; }

const CPUXABIInfo &CPUXSubtarget::getABI() const { return TM.getABI(); }

bool CPUXSubtarget::enablePostRAScheduler() const { return true; }

CodeGenOpt::Level CPUXSubtarget::getOptLevelToEnablePostRAScheduler() const {
  return CodeGenOpt::Aggressive;
}
