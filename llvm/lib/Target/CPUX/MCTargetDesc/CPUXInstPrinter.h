#ifndef LLVM_LIB_TARGET_CPUX_MCTARGETDESC_CPUXINSTPRINTER_H
#define LLVM_LIB_TARGET_CPUX_MCTARGETDESC_CPUXINSTPRINTER_H

#include "llvm/MC/MCInstPrinter.h"

namespace llvm {
class TargetMachine;

class CPUXInstPrinter : public MCInstPrinter {
public:
  CPUXInstPrinter(const MCAsmInfo &MAI, const MCInstrInfo &MII,
                  const MCRegisterInfo &MRI)
      : MCInstPrinter(MAI, MII, MRI) {}

  void printInstruction(const MCInst *MI, uint64_t Address, raw_ostream &O);
  static const char *getRegisterName(MCRegister RegNo, unsigned AltIdx);
  std::pair<const char *, uint64_t> getMnemonic(const MCInst *MI) override;

  void printRegName(raw_ostream &OS, MCRegister Reg) const override;
  void printInst(const MCInst *MI, uint64_t Address, StringRef Annot,
                 const MCSubtargetInfo &STI, raw_ostream &O) override;
  bool printAliasInstr(const MCInst *MI, uint64_t Address, raw_ostream &OS);
  void printCustomAliasOperand(const MCInst *MI, uint64_t Address,
                               unsigned OpIdx, unsigned PrintMethodIdx,
                               raw_ostream &OS);

private:
  void printOperand(const MCInst *MI, unsigned OpNo, raw_ostream &O);
  inline void printOperand(const MCInst *MI, uint64_t /*Address*/,
                           unsigned OpNum, raw_ostream &O) {
    printOperand(MI, OpNum, O);
  }
  void printUnsignedImm(const MCInst *MI, int opNum, raw_ostream &O);
  void printMemOperand(const MCInst *MI, int opNum, raw_ostream &O);
};
} // namespace llvm

#endif
