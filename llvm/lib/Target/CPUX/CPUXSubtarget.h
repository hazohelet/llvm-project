#ifndef LLVM_LIB_TARGET_CPUX_CPUXSUBTARGET_H
#define LLVM_LIB_TARGET_CPUX_CPUXSUBTARGET_H

#include "CPUXFrameLowering.h"
#include "CPUXISelLowering.h"
#include "CPUXInstrInfo.h"
#include "llvm/CodeGen/SelectionDAGTargetInfo.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/MC/MCInstrItineraries.h"
#include "llvm/Target/TargetMachine.h"
#include <string>

#define GET_SUBTARGETINFO_HEADER
#include "CPUXGenSubtargetInfo.inc"

namespace llvm {
class StringRef;
class CPUXTargetMachine;
class CPUXSubtarget : public CPUXGenSubtargetInfo {
  virtual void anchor();

public:
protected:
  InstrItineraryData InstrItins;
  const CPUXTargetMachine &TM;

  Triple TargetTriple;

  const SelectionDAGTargetInfo TSInfo;

  CPUXInstrInfo InstrInfo;
  CPUXFrameLowering FrameLowering;
  CPUXTargetLowering TLInfo;
  CPUXRegisterInfo RegInfo;

public:
  bool enablePostRAScheduler() const override;
  CodeGenOpt::Level getOptLevelToEnablePostRAScheduler() const override;
  bool isPositionIndependent() const;
  const CPUXABIInfo &getABI() const;

  constexpr unsigned getGPRSizeInBytes() const { return 4; }
  CPUXSubtarget(const Triple &TT, StringRef CPU, StringRef TuneCPU,
                StringRef FS, const CPUXTargetMachine &TM);

  void ParseSubtargetFeatures(StringRef CPU, StringRef TuneCPU, StringRef FS);

  bool abiUsesSoftFloat() const;

  unsigned stackAlignment() const { return 8; }

  CPUXSubtarget &initializeSubtargetDependencies(StringRef CPU,
                                                 StringRef TuneCPU,
                                                 StringRef FS,
                                                 const TargetMachine &TM);
  const SelectionDAGTargetInfo *getSelectionDAGInfo() const override {
    return &TSInfo;
  }
  const CPUXInstrInfo *getInstrInfo() const override { return &InstrInfo; }
  const TargetFrameLowering *getFrameLowering() const override {
    return &FrameLowering;
  }
  const CPUXRegisterInfo *getRegisterInfo() const override { return &RegInfo; }
  const CPUXTargetLowering *getTargetLowering() const override {
    return &TLInfo;
  }
  const InstrItineraryData *getInstrItineraryData() const override {
    return &InstrItins;
  }
};
} // namespace llvm

#endif
