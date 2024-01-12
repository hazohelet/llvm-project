#ifndef LLVM_LIB_TARGET_CPUX_MCTARGETDESC_CPUXBASEINFO_H
#define LLVM_LIB_TARGET_CPUX_MCTARGETDESC_CPUXBASEINFO_H

#include "CPUXMCTargetDesc.h"

#include "llvm/MC/MCExpr.h"
#include "llvm/Support/DataTypes.h"
#include "llvm/Support/ErrorHandling.h"

namespace llvm {
namespace CPUXII {
enum {
  MO_None,
  MO_CALL,
  MO_HI20,
  MO_LO12_I,
  MO_LO12_S,
};
}
} // namespace llvm

#endif
