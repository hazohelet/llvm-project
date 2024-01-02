#include "CPUXISelLowering.h"

#include "CPUXMachineFunction.h"
#include "CPUXSubtarget.h"
#include "CPUXTargetMachine.h"
#include "CPUXTargetObjectFile.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/IR/CallingConv.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define DEBUG_TYPE "CPUX-lower"

const char *CPUXTargetLowering::getTargetNodeName(unsigned Opcode) const {
  switch (Opcode) {
  case CPUXISD::TailCall:
    return "CPUXISD::TailCall";
  case CPUXISD::Hi:
    return "CPUXISD::Hi";
  case CPUXISD::Lo:
    return "CPUXISD::Lo";
  case CPUXISD::GPRel:
    return "CPUXISD::GPRel";
  case CPUXISD::Ret:
    return "CPUXISD::Ret";
  case CPUXISD::EH_RETURN:
    return "CPUXISD::EH_RETURN";
  case CPUXISD::DivRem:
    return "CPUXISD::DivRem";
  case CPUXISD::DivRemU:
    return "CPUXISD::DivRemU";
  case CPUXISD::Wrapper:
    return "CPUXISD::Wrapper";
  default:
    return NULL;
  }
}

CPUXTargetLowering::CPUXTargetLowering(const CPUXTargetMachine &TM,
                                       const CPUXSubtarget &STI)
    : TargetLowering(TM), Subtarget(STI), ABI(TM.getABI()) {
  MVT XLenVT = MVT::i32;

  addRegisterClass(XLenVT, &CPUX::GPRRegClass);

  setMinFunctionAlignment(Align(4));
  computeRegisterProperties(STI.getRegisterInfo());
}

#include "CPUXGenCallingConv.inc"

SDValue CPUXTargetLowering::LowerFormalArguments(
    SDValue Chain, CallingConv::ID CallConv, bool IsVarArg,
    const SmallVectorImpl<ISD::InputArg> &Ins, const SDLoc &DL,
    SelectionDAG &DAG, SmallVectorImpl<SDValue> &InVals) const {
  // TODO: Implement this
  return Chain;
}

SDValue
CPUXTargetLowering::LowerReturn(SDValue Chain, CallingConv::ID CallConv,
                                bool IsVarArg,
                                const SmallVectorImpl<ISD::OutputArg> &Outs,
                                const SmallVectorImpl<SDValue> &OutVals,
                                const SDLoc &DL, SelectionDAG &DAG) const {
  SmallVector<CCValAssign, 16> RVLocs;
  MachineFunction &MF = DAG.getMachineFunction();

  CCState CCInfo(CallConv, IsVarArg, MF, RVLocs, *DAG.getContext());
  CCInfo.AnalyzeReturn(Outs, RetCC_CPUX);

  SDValue Flag;
  SmallVector<SDValue, 4> RetOps(1, Chain);

  for (unsigned I = 0; I != RVLocs.size(); ++I) {
    SDValue Val = OutVals[I];
    CCValAssign &VA = RVLocs[I];
    assert(VA.isRegLoc() && "Can only return in registers!");

    if (RVLocs[I].getValVT() != RVLocs[I].getLocVT())
      Val = DAG.getNode(ISD::BITCAST, DL, RVLocs[I].getLocVT(), Val);

    Chain = DAG.getCopyToReg(Chain, DL, VA.getLocReg(), Val, Flag);

    Flag = Chain.getValue(1);

    RetOps.push_back(DAG.getRegister(VA.getLocReg(), VA.getLocVT()));
  }

  RetOps[0] = Chain;

  if (Flag.getNode()) {
    RetOps.push_back(Flag);
  }

  return DAG.getNode(CPUXISD::Ret, DL, MVT::Other, RetOps);
}
