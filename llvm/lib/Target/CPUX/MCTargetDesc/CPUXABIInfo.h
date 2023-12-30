#ifndef LLVM_LIB_TARGET_CPUX_MCTARGETDESC_CPUXABIINFO_H
#define LLVM_LIB_TARGET_CPUX_MCTARGETDESC_CPUXABIINFO_H

#include "llvm/ADT/ArrayRef.h"
#include "llvm/IR/CallingConv.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/TargetParser/Triple.h"

namespace llvm {
class MCTargetOptions;
class StringRef;
class TargetRegisterClass;

class CPUXABIInfo {
public:
  enum class ABI { Unknown, LP, STACK };

protected:
  ABI ThisABI;

public:
  CPUXABIInfo(ABI ThisABI) : ThisABI(ThisABI) {}

  static CPUXABIInfo Unknown() { return CPUXABIInfo(ABI::Unknown); }
  static CPUXABIInfo LP() { return CPUXABIInfo(ABI::LP); }
  static CPUXABIInfo STACK() { return CPUXABIInfo(ABI::STACK); }

  static CPUXABIInfo computeTargetABI(StringRef ABIName);

  bool IsKnown() const { return ThisABI != ABI::Unknown; }
  bool IsLP() const { return ThisABI == ABI::LP; }
  bool IsSTACK() const { return ThisABI == ABI::STACK; }
  ABI GetEnumValue() const { return ThisABI; }

  /// regs for byval args
  ArrayRef<MCPhysReg> GetByValArgRegs() const;

  /// regs for varargs
  ArrayRef<MCPhysReg> GetVarArgRegs() const;

  /// size of the area allocated by the callee for args
  /// CallingConv::FastCall affects the value for O32
  unsigned GetCalleeAllocdArgSizeInBytes(CallingConv::ID CC) const;

  /// Ordering of ABI's
  /// CPUXGenSubtargetInfo.inc will use this to resolve conflicts when given
  /// multiple ABI options
  bool operator<(const CPUXABIInfo Other) const {
    return ThisABI < Other.GetEnumValue();
  }

  unsigned GetStackPtr() const;
  unsigned GetFramePtr() const;
  unsigned GetNullPtr() const;

  unsigned GetEhDataReg(unsigned I) const;
  int EhDataRegSize() const;
};

} // namespace llvm

#endif
