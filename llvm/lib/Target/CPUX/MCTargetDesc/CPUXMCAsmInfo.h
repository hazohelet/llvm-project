#ifndef LLVM_LIB_TARGET_CPUX_MCTARGETDESC_CPUXMCASMINFO_H
#define LLVM_LIB_TARGET_CPUX_MCTARGETDESC_CPUXMCASMINFO_H

#include "llvm/MC/MCAsmInfoELF.h"

namespace llvm {
class Triple;

class CPUXMCAsmInfo : public MCAsmInfoELF {
  void anchor() override;

public:
  explicit CPUXMCAsmInfo(const Triple &TT);
};
} // namespace llvm

#endif
