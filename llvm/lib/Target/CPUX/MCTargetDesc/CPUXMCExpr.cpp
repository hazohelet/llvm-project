#include "CPUX.h"

#include "CPUXMCExpr.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCObjectStreamer.h"
#include "llvm/MC/MCSymbolELF.h"

using namespace llvm;

#define DEBUG_TYPE "CPUXmcexpr"

const CPUXMCExpr *CPUXMCExpr::create(CPUXExprKind Kind, const MCExpr *Expr,
                                     MCContext &Ctx) {
  return new (Ctx) CPUXMCExpr(Kind, Expr);
}

const CPUXMCExpr *CPUXMCExpr::create(const MCSymbol *Symbol, CPUXExprKind Kind,
                                     MCContext &Ctx) {
  const MCSymbolRefExpr *MCSym =
      MCSymbolRefExpr::create(Symbol, MCSymbolRefExpr::VK_None, Ctx);
  return new (Ctx) CPUXMCExpr(Kind, MCSym);
}

void CPUXMCExpr::printImpl(raw_ostream &OS, const MCAsmInfo *MAI) const {
  int64_t AbsVal;

  switch (Kind) {
  case VK_CPUX_None:
    llvm_unreachable("Invalid kind!");
  case VK_CPUX_HI20:
    OS << "%hi";
    break;
  case VK_CPUX_LO12_I:
  case VK_CPUX_LO12_S:
    OS << "%lo";
    break;
  }

  OS << '(';
  if (Expr->evaluateAsAbsolute(AbsVal))
    OS << AbsVal;
  else
    Expr->print(OS, MAI, true);
  OS << ')';
}

bool CPUXMCExpr::evaluateAsRelocatableImpl(MCValue &Res,
                                           const MCAsmLayout *Layout,
                                           const MCFixup *Fixup) const {
  return Expr->evaluateAsRelocatable(Res, Layout, Fixup);
}

void CPUXMCExpr::visitUsedExpr(MCStreamer &Streamer) const {
  Streamer.visitUsedExpr(*getSubExpr());
}

void CPUXMCExpr::fixELFSymbolsInTLSFixups(MCAssembler &Asm) const {
  Asm.getContext().reportError(getLoc(), "TLS not supported");
}
