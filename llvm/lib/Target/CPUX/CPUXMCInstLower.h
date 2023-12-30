#ifndef LLVM_LIB_TARGET_CPUX_CPUXMCINSTLOWER_H
#define LLVM_LIB_TARGET_CPUX_CPUXMCINSTLOWER_H

#include "llvm/ADT/SmallVector.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/Support/Compiler.h"

namespace llvm {
class MCContext;
class MCInst;
class MCOperand;
class MachineInstr;
class MachineFunction;
class CPUXAsmPrinter;

class LLVM_LIBRARY_VISIBILITY CPUXMCInstLower {
  typedef MachineOperand::MachineOperandType MachineOperandType;
  MCContext *Ctx;
  CPUXAsmPrinter &AsmPrinter;

public:
  CPUXMCInstLower(CPUXAsmPrinter &asmprinter);
  void Initialize(MCContext *C);
  void Lower(const MachineInstr *MI, MCInst &OutMI) const;
  MCOperand LowerOperand(const MachineOperand &MO, unsigned offset = 0) const;
};
} // namespace llvm

#endif
