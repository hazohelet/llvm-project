#include "CPUXMCTargetDesc.h"
#include "CPUXMCAsmInfo.h"
#include "CPUXTargetStreamer.h"
#include "MCTargetDesc/CPUXInstPrinter.h"

#include "llvm/MC/MCELFStreamer.h"
#include "llvm/MC/MCInstPrinter.h"
#include "llvm/MC/MCInstrAnalysis.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/MC/MachineLocation.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/FormattedStream.h"

#include "MCTargetDesc/CPUXInstPrinter.h"
#include "MCTargetDesc/CPUXMCAsmInfo.h"

using namespace llvm;

#define GET_INSTRINFO_MC_DESC
#include "CPUXGenInstrInfo.inc"

#define None std::nullopt
#define GET_SUBTARGETINFO_MC_DESC
#include "CPUXGenSubtargetInfo.inc"
#undef None

#define GET_REGINFO_MC_DESC
#include "CPUXGenRegisterInfo.inc"

static MCInstrInfo *createCPUXMCInstrInfo() {
  MCInstrInfo *X = new MCInstrInfo();
  InitCPUXMCInstrInfo(X);
  return X;
}

static MCRegisterInfo *createCPUXMCRegisterInfo(const Triple &TT) {
  MCRegisterInfo *X = new MCRegisterInfo();
  InitCPUXMCRegisterInfo(X, CPUX::RA);
  return X;
}

static MCSubtargetInfo *createCPUXMCSubtargetInfo(const Triple &TT,
                                                  StringRef CPU, StringRef FS) {
  std::string CPUName = std::string(CPU);
  if (CPU.empty())
    CPU = "cpux-rv32";
  return createCPUXMCSubtargetInfoImpl(TT, CPU, /*TuneCPU=*/CPUName, FS);
}

static MCAsmInfo *createCPUXMCAsmInfo(const MCRegisterInfo &MRI,
                                      const Triple &TT,
                                      const MCTargetOptions &Options) {
  MCAsmInfo *MAI = new CPUXMCAsmInfo(TT);
  unsigned SP = MRI.getDwarfRegNum(CPUX::SP, true);
  MCCFIInstruction Inst = MCCFIInstruction::cfiDefCfa(nullptr, SP, 0);
  MAI->addInitialFrameState(Inst);

  return MAI;
}

static MCInstPrinter *createCPUXInstPrinter(const Triple &T,
                                            unsigned SyntaxVariant,
                                            const MCAsmInfo &MAI,
                                            const MCInstrInfo &MII,
                                            const MCRegisterInfo &MRI) {
  return new CPUXInstPrinter(MAI, MII, MRI);
}

namespace {
class CPUXMCInstrAnalysis : public MCInstrAnalysis {
public:
  CPUXMCInstrAnalysis(const MCInstrInfo *Info) : MCInstrAnalysis(Info) {}
};
} // namespace

static MCInstrAnalysis *createCPUXInstrAnalysis(const MCInstrInfo *Info) {
  return new CPUXMCInstrAnalysis(Info);
}

static MCTargetStreamer *createCPUXAsmTargetStreamer(MCStreamer &S,
                                                     formatted_raw_ostream &OS,
                                                     MCInstPrinter *InstPrint,
                                                     bool isVerboseAsm) {
  return new CPUXTargetAsmStreamer(S, OS);
}

extern "C" void LLVMInitializeCPUXTargetMC() {
  Target *T = &getTheCPUXTarget();
  RegisterMCAsmInfoFn X(getTheCPUXTarget(), createCPUXMCAsmInfo);

  TargetRegistry::RegisterMCInstrInfo(*T, createCPUXMCInstrInfo);
  TargetRegistry::RegisterMCRegInfo(*T, createCPUXMCRegisterInfo);
  TargetRegistry::RegisterMCSubtargetInfo(*T, createCPUXMCSubtargetInfo);
  TargetRegistry::RegisterMCInstrAnalysis(*T, createCPUXInstrAnalysis);
  TargetRegistry::RegisterMCInstPrinter(*T, createCPUXInstPrinter);
  TargetRegistry::RegisterAsmTargetStreamer(*T, createCPUXAsmTargetStreamer);
}
