#include "CPUXInstPrinter.h"

#include "CPUXInstrInfo.h"
using namespace llvm;

#define DEBUG_TYPE "asm-printer"

#define PRINT_ALIAS_INSTR
#include "CPUXGenAsmWriter.inc"

void CPUXInstPrinter::printRegName(raw_ostream &OS, MCRegister Reg) const {
  OS << getRegisterName(Reg);
}

void CPUXInstPrinter::printInst(const MCInst *MI, uint64_t Address,
                                StringRef Annot, const MCSubtargetInfo &STI,
                                raw_ostream &O) {
  if (!printAliasInstr(MI, Address, O))
    printInstruction(MI, Address, O);
  printAnnotation(O, Annot);
}

void CPUXInstPrinter::printOperand(const MCInst *MI, unsigned OpNo,
                                   raw_ostream &O) {
  const MCOperand &Op = MI->getOperand(OpNo);
  if (Op.isReg()) {
    printRegName(O, Op.getReg());
    return;
  }

  if (Op.isImm()) {
    O << Op.getImm();
    return;
  }
  assert(Op.isExpr() && "unknown operand kind in printOperand");
  Op.getExpr()->print(O, &MAI, /*InParenss=*/true);
}

void CPUXInstPrinter::printUnsignedImm(const MCInst *MI, int opNum,
                                       raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(opNum);
  if (MO.isImm()) {
    O << (unsigned short)MO.getImm();
  } else {
    printOperand(MI, opNum, O);
  }
}

void CPUXInstPrinter::printMemOperand(const MCInst *MI, int opNum,
                                      raw_ostream &O) {
  printOperand(MI, opNum + 1, O);
  O << "(";
  printOperand(MI, opNum, O);
  O << ")";
}
