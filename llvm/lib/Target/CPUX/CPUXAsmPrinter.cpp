#include "CPUXAsmPrinter.h"

#include "CPUX.h"
#include "CPUXInstrInfo.h"
#include "MCTargetDesc/CPUXInstPrinter.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/ADT/Twine.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineMemOperand.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Mangler.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetLoweringObjectFile.h"
#include "llvm/Target/TargetOptions.h"

using namespace llvm;

#define DEBUG_TYPE "CPUX-asm-printer"

bool CPUXAsmPrinter::runOnMachineFunction(MachineFunction &MF) {
  CPUXFI = MF.getInfo<CPUXFunctionInfo>();
  AsmPrinter::runOnMachineFunction(MF);
  return true;
}

void CPUXAsmPrinter::emitInstruction(const MachineInstr *MI) {
  if (MI->isDebugValue()) {
    SmallString<128> Str;
    raw_svector_ostream OS(Str);

    PrintDebugValueComment(MI, OS);
    return;
  }

  MCInst TmpInstO;
  MCInstLowering.Lower(MI, TmpInstO);
  OutStreamer->emitInstruction(TmpInstO, getSubtargetInfo());
}

const char *CPUXAsmPrinter::getCurrentABIString() const {
  switch (static_cast<CPUXTargetMachine &>(TM).getABI().GetEnumValue()) {
  case CPUXABIInfo::ABI::LP:
    return "abilp";
  case CPUXABIInfo::ABI::STACK:
    return "abistack";
  default:
    llvm_unreachable("Unknown CPUX ABI");
  }
}

void CPUXAsmPrinter::emitFunctionEntryLabel() {
  OutStreamer->emitLabel(CurrentFnSym);
}

void CPUXAsmPrinter::emitFunctionBodyStart() {
  MCInstLowering.Initialize(&MF->getContext());

  emitFrameDirective();

  if (OutStreamer->hasRawTextSupport()) {
    SmallString<128> Str;
    raw_svector_ostream OS(Str);
    printSavedRegsBitmask(OS);
    OutStreamer->emitRawText(OS.str());
  }
}

void CPUXAsmPrinter::emitFunctionBodyEnd() {}

void CPUXAsmPrinter::emitStartOfAsmFile(Module &M) {
  if (OutStreamer->hasRawTextSupport()) {
    OutStreamer->emitRawText("\t.section .mdebug." +
                             Twine(getCurrentABIString()));
  }

  if (OutStreamer->hasRawTextSupport()) {
    OutStreamer->emitRawText("\t.previous");
  }
}

void CPUXAsmPrinter::PrintDebugValueComment(const MachineInstr *MI,
                                            raw_ostream &OS) {
  // TODO: implement
  OS << "PrintDebugValueComment()";
}

extern "C" void LLVMInitializeCPUXAsmPrinter() {
  RegisterAsmPrinter<CPUXAsmPrinter> X(getTheCPUXTarget());
}
