#ifndef LLVM_LIB_TARGET_CPUX_CPUXTARGETSTREAMER_H
#define LLVM_LIB_TARGET_CPUX_CPUXTARGETSTREAMER_H

#include "llvm/MC/MCELFStreamer.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCStreamer.h"

namespace llvm {
class formatted_raw_ostream;

class CPUXTargetStreamer : public MCTargetStreamer {
public:
  CPUXTargetStreamer(MCStreamer &S);
};

class CPUXTargetAsmStreamer : public CPUXTargetStreamer {
  formatted_raw_ostream &OS;

public:
  CPUXTargetAsmStreamer(MCStreamer &S, formatted_raw_ostream &OS);
};
} // namespace llvm

#endif
