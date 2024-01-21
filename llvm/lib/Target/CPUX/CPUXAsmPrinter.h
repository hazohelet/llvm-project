#ifndef LLVM_LIB_TARGET_CPUX_CPUXASMPRINTER_H
#define LLVM_LIB_TARGET_CPUX_CPUXASMPRINTER_H

#include "CPUXMCInstLower.h"
#include "CPUXMachineFunction.h"
#include "CPUXSubtarget.h"
#include "CPUXTargetMachine.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {
class MCStreamer;
class MachineInstr;
class MachineBasicBlock;
class Module;
class raw_ostream;

class LLVM_LIBRARY_VISIBILITY CPUXAsmPrinter : public AsmPrinter {
  void EmitInstrWithMacroNoAT(const MachineInstr *MI);

private:
  bool lowerOperand(const MachineOperand &MO, MCOperand &MCOp);

public:
  const CPUXFunctionInfo *CPUXFI;
  CPUXMCInstLower MCInstLowering;

  explicit CPUXAsmPrinter(TargetMachine &TM,
                          std::unique_ptr<MCStreamer> Streamer)
      : AsmPrinter(TM, std::move(Streamer)), MCInstLowering(*this) {}

  virtual StringRef getPassName() const override {
    return "CPUX Assembly Printer";
  }

  virtual bool runOnMachineFunction(MachineFunction &MF) override;

  bool emitPseudoExpansionLowering(MCStreamer &OutStreamer,
                                   const MachineInstr *MI);

  void emitInstruction(const MachineInstr *MI) override;
  void printSavedRegsBitmask(raw_ostream &O) {}
  void printHex32(unsigned int Value, raw_ostream &O);
  void emitFrameDirective(){};
  const char *getCurrentABIString() const;
  void emitStartOfAsmFile(Module &M) override;
  void emitFunctionEntryLabel() override;
  void emitFunctionBodyStart() override;
  void emitFunctionBodyEnd() override;
  void PrintDebugValueComment(const MachineInstr *MI, raw_ostream &OS);
};
} // namespace llvm

#endif
