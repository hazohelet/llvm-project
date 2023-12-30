#include "CPUXMCInstLower.h"

#include "CPUXAsmPrinter.h"
#include "CPUXInstrInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/IR/Mangler.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"

using namespace llvm;

CPUXMCInstLower::CPUXMCInstLower(CPUXAsmPrinter &asmprinter)
    : AsmPrinter(asmprinter) {}

void CPUXMCInstLower::Initialize(MCContext *C) { Ctx = C; }

MCOperand CPUXMCInstLower::LowerOperand(const MachineOperand &MO,
                                        unsigned offset) const {
  MachineOperandType MOTy = MO.getType();

  switch (MOTy) {
  default:
    llvm_unreachable("Unknown operand type");
  case MachineOperand::MO_Register:
    if (MO.isImplicit())
      break;
    return MCOperand::createReg(MO.getReg());
  case MachineOperand::MO_Immediate:
    return MCOperand::createImm(MO.getImm() + offset);
  case MachineOperand::MO_RegisterMask:
    break;
  }
  return MCOperand();
}

void CPUXMCInstLower::Lower(const MachineInstr *MI, MCInst &OutMI) const {
  OutMI.setOpcode(MI->getNumOperands());
  for (unsigned i = 0, e = MI->getNumOperands(); i != e; ++i) {
    const MachineOperand &MO = MI->getOperand(i);
    MCOperand MCOp = LowerOperand(MO, 0);
    if (MCOp.isValid())
      OutMI.addOperand(MCOp);
  }
}
