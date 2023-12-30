#ifndef LLVM_LIB_TARGET_CPUX_CPUXTARGETDESC_CPUXMCTARGETDESC_H
#define LLVM_LIB_TARGET_CPUX_CPUXTARGETDESC_CPUXMCTARGETDESC_H

#include "llvm/Support/DataTypes.h"

namespace llvm {
class MCAsmBackend;
class MCCodeEmitter;
class MCContext;
class MCInstrInfo;
class MCObjectTargetWriter;
class MCRegisterInfo;
class MCSubtargetInfo;
class StringRef;
class Target;
class Triple;
class raw_ostream;
class raw_pwrite_stream;

Target &getTheCPUXTarget();

} // namespace llvm
#define GET_REGINFO_ENUM
#include "CPUXGenRegisterInfo.inc"

#define GET_INSTRINFO_ENUM
#include "CPUXGenInstrInfo.inc"

#define GET_SUBTARGETINFO_ENUM
#include "CPUXGenSubtargetInfo.inc"

#endif
