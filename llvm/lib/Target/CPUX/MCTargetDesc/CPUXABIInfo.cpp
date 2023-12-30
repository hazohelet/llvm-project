#include "CPUXABIInfo.h"
#include "CPUXRegisterInfo.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/MC/MCTargetOptions.h"
#include "llvm/Support/CommandLine.h"

using namespace llvm;

static cl::opt<bool> EnableCPUXLPCalls(
    "CPUX-lp32-calls", cl::Hidden,
    cl::desc("CPUX LP call: Default Integer Calling Convention"),
    cl::init(false));

namespace {
static const MCPhysReg LPIntRegs[8] = {CPUX::A0, CPUX::A1, CPUX::A2, CPUX::A3,
                                       CPUX::A4, CPUX::A5, CPUX::A6, CPUX::A7};
};

ArrayRef<MCPhysReg> CPUXABIInfo::GetByValArgRegs() const {
  if (IsLP())
    return makeArrayRef(LPIntRegs);
  llvm_unreachable("Unhandled ABI");
}

ArrayRef<MCPhysReg> CPUXABIInfo::GetVarArgRegs() const {
  if (IsLP())
    return makeArrayRef(LPIntRegs);
  llvm_unreachable("Unhandled ABI");
}

unsigned CPUXABIInfo::GetCalleeAllocdArgSizeInBytes(CallingConv::ID CC) const {
  if (IsLP())
    return CC != 0;
  llvm_unreachable("Unhandled ABI");
}

CPUXABIInfo CPUXABIInfo::computeTargetABI(StringRef ABIName) {
  CPUXABIInfo abi(ABI::Unknown);
  if (ABIName.empty()) {
    return ABI::LP;
  }
  if (ABIName == "lp") {
    return ABI::LP;
  }
  if (ABIName == "stack") {
    return ABI::STACK;
  }
  errs() << "Unknown ABI : " << ABIName << "\n";
  return abi;
}

unsigned CPUXABIInfo::GetStackPtr() const { return CPUX::SP; }

unsigned CPUXABIInfo::GetFramePtr() const { return CPUX::FP; }

unsigned CPUXABIInfo::GetNullPtr() const { return CPUX::ZERO; }

unsigned CPUXABIInfo::GetEhDataReg(unsigned I) const {
  static const unsigned EhDataReg[] = {CPUX::A0, CPUX::A1, CPUX::A2, CPUX::A3,
                                       CPUX::A4, CPUX::A5, CPUX::A6, CPUX::A7};
  return EhDataReg[I];
}

int CPUXABIInfo::EhDataRegSize() const { return sizeof(LPIntRegs); }
