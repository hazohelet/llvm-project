#include "MCTargetDesc/CPUXTargetStreamer.h"
#include "CPUXMCTargetDesc.h"
#include "CPUXTargetObjectFile.h"
#include "MCTargetDesc/CPUXInstPrinter.h"

#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCSectionELF.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCSymbolELF.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/FormattedStream.h"

using namespace llvm;

CPUXTargetStreamer::CPUXTargetStreamer(MCStreamer &S) : MCTargetStreamer(S) {}

CPUXTargetAsmStreamer::CPUXTargetAsmStreamer(MCStreamer &S,
                                             formatted_raw_ostream &OS)
    : CPUXTargetStreamer(S), OS(OS) {}
