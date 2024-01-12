#ifndef LLVM_LIB_TARGET_CPUX_MCTARGETDESC_CPUXMCEXPR_H
#define LLVM_LIB_TARGET_CPUX_MCTARGETDESC_CPUXMCEXPR_H

#include "llvm/MC/MCAsmLayout.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCValue.h"

namespace llvm {
class CPUXMCExpr : public MCTargetExpr {
public:
  enum CPUXExprKind {
    VK_CPUX_None,

    VK_CPUX_CALL,
    VK_CPUX_HI20,
    VK_CPUX_LO12_I,
    VK_CPUX_LO12_S,
  };

private:
  const CPUXExprKind Kind;
  const MCExpr *Expr;

  explicit CPUXMCExpr(CPUXExprKind Kind, const MCExpr *Expr)
      : Kind(Kind), Expr(Expr) {}

public:
  static const CPUXMCExpr *create(CPUXExprKind Kind, const MCExpr *Expr,
                                  MCContext &Ctx);
  static const CPUXMCExpr *create(const MCSymbol *Symbol, CPUXExprKind Kind,
                                  MCContext &Ctx);

  CPUXExprKind getKind() const { return Kind; }
  const MCExpr *getSubExpr() const { return Expr; }

  void printImpl(raw_ostream &OS, const MCAsmInfo *MAI) const override;
  bool evaluateAsRelocatableImpl(MCValue &Res, const MCAsmLayout *Layout,
                                 const MCFixup *Fixup) const override;
  void visitUsedExpr(MCStreamer &Streamer) const override;
  MCFragment *findAssociatedFragment() const override {
    return Expr->findAssociatedFragment();
  }
  void fixELFSymbolsInTLSFixups(MCAssembler &Asm) const override;

  static bool classof(const MCExpr *E) {
    return E->getKind() == MCExpr::Target;
  }
};
} // namespace llvm

#endif
