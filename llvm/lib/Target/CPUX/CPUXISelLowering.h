#ifndef LLVM_LIB_TARGET_CPUX_CPUXISELLOWERING_H
#define LLVM_LIB_TARGET_CPUX_CPUXISELLOWERING_H

#include "CPUX.h"
#include "MCTargetDesc/CPUXABIInfo.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/CodeGen/TargetLowering.h"
#include "llvm/IR/Function.h"
#include <deque>

namespace llvm {
namespace CPUXISD {
enum NodeType : unsigned {
  FIRST_NUMBER = ISD::BUILTIN_OP_END,
  TailCall,
  // Obtain higher 16 bits - not related to %hi
  Hi,
  // Obtain lower 16 bits - not related to %lo
  Lo,

  GPRel,
  ThreadPointer,
  // Return
  Ret,
  EH_RETURN,

  DivRem,
  DivRemU,

  Wrapper,
  DynAlloc,
  Sync
};
} // namespace CPUXISD

class CPUXFunctionInfo;
class CPUXSubtarget;

class CPUXTargetLowering : public TargetLowering {
public:
  explicit CPUXTargetLowering(const CPUXTargetMachine &TM,
                              const CPUXSubtarget &STI);
  static const CPUXTargetLowering *create(const CPUXTargetMachine &TM,
                                          const CPUXSubtarget &STI);
  const char *getTargetNodeName(unsigned Opcode) const override;

protected:
  struct ByValArgInfo {
    unsigned FirstIdx; // Index of the first register used.
    unsigned NumRegs;  // Number of registers used for this argument.
    unsigned Address;  // Offset of the stack area used to pass this argument.

    ByValArgInfo() : FirstIdx(0), NumRegs(0), Address(0) {}
  };

protected:
  const CPUXSubtarget &Subtarget;
  const CPUXABIInfo &ABI;

private:
  SDValue lowerGlobalAddress(SDValue Op, SelectionDAG &DAG) const;

  SDValue LowerFormalArguments(SDValue Chain, CallingConv::ID CallConv,
                               bool IsVarArg,
                               const SmallVectorImpl<ISD::InputArg> &Ins,
                               const SDLoc &DL, SelectionDAG &DAG,
                               SmallVectorImpl<SDValue> &InVals) const override;

  SDValue LowerReturn(SDValue Chain, CallingConv::ID CallConv, bool IsVarArg,
                      const SmallVectorImpl<ISD::OutputArg> &Outs,
                      const SmallVectorImpl<SDValue> &OutVals, const SDLoc &DL,
                      SelectionDAG &DAG) const override;
};
} // namespace llvm

#endif
