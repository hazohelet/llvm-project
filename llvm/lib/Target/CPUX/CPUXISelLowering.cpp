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
  case CPUXISD::SELECT_CC:
    return "CPUXISD::SELECT_CC";
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

  setOperationAction(ISD::ROTL, XLenVT, Expand);
  setOperationAction(ISD::ROTR, XLenVT, Expand);
  setOperationAction(ISD::CTTZ, XLenVT, Expand);
  setOperationAction(ISD::CTPOP, XLenVT, Expand);

  setOperationAction(ISD::GlobalAddress, XLenVT, Custom);

  setOperationAction(ISD::BR_CC, XLenVT, Expand);
  setOperationAction(ISD::BR_JT, MVT::Other, Expand);
  setOperationAction(ISD::SELECT, XLenVT, Custom);
  setOperationAction(ISD::SELECT_CC, XLenVT, Expand);

  // Don't use table jump
  setMinimumJumpTableEntries(INT_MAX);
}

static unsigned addLiveIn(MachineFunction &MF, unsigned PReg,
                          const TargetRegisterClass *RC) {
  MCRegister VReg = MF.getRegInfo().createVirtualRegister(RC);
  MF.getRegInfo().addLiveIn(PReg, VReg);
  return VReg;
}

#include "CPUXGenCallingConv.inc"

SDValue CPUXTargetLowering::LowerOperation(SDValue Op,
                                           SelectionDAG &DAG) const {
  switch (Op.getOpcode()) {
  case ISD::SELECT:
    return lowerSELECT(Op, DAG);
  case ISD::GlobalAddress:
    return lowerGlobalAddress(Op, DAG);
  default:
    llvm_unreachable("unimplemented operand");
  }
}

SDValue CPUXTargetLowering::lowerGlobalAddress(SDValue Op,
                                               SelectionDAG &DAG) const {
  // Our CPU only supports static relocation model
  SDLoc DL(Op);
  EVT PtrVT = getPointerTy(DAG.getDataLayout());
  GlobalAddressSDNode *GSDN = cast<GlobalAddressSDNode>(Op);
  int64_t Offset = GSDN->getOffset();
  SDValue Addr = getAddrStatic(GSDN, PtrVT, DAG);
  if (Offset != 0) {
    return DAG.getNode(ISD::ADD, DL, PtrVT, Addr,
                       DAG.getConstant(Offset, DL, PtrVT));
  }
  return Addr;
}

SDValue CPUXTargetLowering::lowerSELECT(SDValue Op, SelectionDAG &DAG) const {
  SDValue CondV = Op.getOperand(0);
  SDValue TrueV = Op.getOperand(1);
  SDValue FalseV = Op.getOperand(2);
  SDLoc DL(Op);

  SDValue Zero = DAG.getRegister(CPUX::ZERO, MVT::i32);
  SDValue SetNE = DAG.getConstant(ISD::SETNE, DL, MVT::i32);

  SDVTList VTs = DAG.getVTList(Op.getValueType(), MVT::Glue);
  SDValue Ops[] = {CondV, Zero, SetNE, TrueV, FalseV};
  return DAG.getNode(CPUXISD::SELECT_CC, DL, VTs, Ops);
}

SDValue CPUXTargetLowering::getTargetNode(GlobalAddressSDNode *N, EVT Ty,
                                          SelectionDAG &DAG,
                                          unsigned Flag) const {
  return DAG.getTargetGlobalAddress(N->getGlobal(), SDLoc(N), Ty, 0, Flag);
}

unsigned CPUXTargetLowering::getBranchOpcodeForIntCondCode(ISD::CondCode CC) {
  switch (CC) {
  default:
    llvm_unreachable("Invalid integer condition!");
  case ISD::SETEQ:
    return CPUX::BEQ;
  case ISD::SETNE:
    return CPUX::BNE;
  case ISD::SETLT:
    return CPUX::BLT;
  case ISD::SETGE:
    return CPUX::BGE;
  case ISD::SETULT:
    return CPUX::BLTU;
  case ISD::SETUGE:
    return CPUX::BGEU;
  }
}

MachineBasicBlock *CPUXTargetLowering::emitSelectPseudo(MachineInstr &MI,
                                                        MachineBasicBlock *BB) {
  const TargetInstrInfo &TII = *BB->getParent()->getSubtarget().getInstrInfo();
  const BasicBlock *LLVM_BB = BB->getBasicBlock();
  DebugLoc DL = MI.getDebugLoc();
  auto I = ++BB->getIterator();

  MachineBasicBlock *HeadMBB = BB;
  MachineFunction *F = BB->getParent();
  MachineBasicBlock *TailMBB = F->CreateMachineBasicBlock(LLVM_BB);
  MachineBasicBlock *IfFalseMBB = F->CreateMachineBasicBlock(LLVM_BB);

  F->insert(I, IfFalseMBB);
  F->insert(I, TailMBB);

  TailMBB->splice(TailMBB->begin(), HeadMBB,
                  std::next(MachineBasicBlock::iterator(MI)), HeadMBB->end());

  TailMBB->transferSuccessorsAndUpdatePHIs(HeadMBB);
  HeadMBB->addSuccessor(IfFalseMBB);
  HeadMBB->addSuccessor(TailMBB);

  unsigned LHS = MI.getOperand(1).getReg();
  unsigned RHS = MI.getOperand(2).getReg();
  auto CC = static_cast<ISD::CondCode>(MI.getOperand(3).getImm());
  unsigned Opcode = getBranchOpcodeForIntCondCode(CC);

  BuildMI(HeadMBB, DL, TII.get(Opcode)).addReg(LHS).addReg(RHS).addMBB(TailMBB);

  IfFalseMBB->addSuccessor(TailMBB);

  BuildMI(*TailMBB, TailMBB->begin(), DL, TII.get(CPUX::PHI),
          MI.getOperand(0).getReg())
      .addReg(MI.getOperand(4).getReg())
      .addMBB(HeadMBB)
      .addReg(MI.getOperand(5).getReg())
      .addMBB(IfFalseMBB);
  MI.eraseFromParent();
  return TailMBB;
}

MachineBasicBlock *
CPUXTargetLowering::EmitInstrWithCustomInserter(MachineInstr &MI,
                                                MachineBasicBlock *BB) const {
  switch (MI.getOpcode()) {
  default:
    llvm_unreachable("Unexpected instr type to insert");
  case CPUX::Select_GPR_Using_CC_GPR:
    return emitSelectPseudo(MI, BB);
  }
}

SDValue CPUXTargetLowering::LowerFormalArguments(
    SDValue Chain, CallingConv::ID CallConv, bool IsVarArg,
    const SmallVectorImpl<ISD::InputArg> &Ins, const SDLoc &DL,
    SelectionDAG &DAG, SmallVectorImpl<SDValue> &InVals) const {
  MachineFunction &MF = DAG.getMachineFunction();
  MachineFrameInfo &MFI = MF.getFrameInfo();
  CPUXFunctionInfo *CPUXFI = MF.getInfo<CPUXFunctionInfo>();

  // CPUXFI->setVarArgsFrameIndex(0);

  SmallVector<CCValAssign, 16> ArgLocs;
  CCState CCInfo(CallConv, IsVarArg, MF, ArgLocs, *DAG.getContext());
  CCInfo.AnalyzeFormalArguments(Ins, CC_CPUX);

  auto FuncArg = DAG.getMachineFunction().getFunction().arg_begin();

  std::vector<SDValue> OutChains;

  unsigned CurArgIdx = 0;
  CCInfo.rewindByValRegsInfo();

  for (unsigned I = 0, E = ArgLocs.size(); I != E; ++I) {
    CCValAssign &VA = ArgLocs[I];

    if (Ins[I].isOrigArg()) {
      std::advance(FuncArg, Ins[I].getOrigArgIndex() - CurArgIdx);
      CurArgIdx = Ins[I].getOrigArgIndex();
    }

    EVT ValVT = VA.getValVT();

    bool IsRegLoc = VA.isRegLoc();

    if (IsRegLoc) {
      MVT RegVT = VA.getLocVT();
      MCRegister ArgReg = VA.getLocReg();
      const TargetRegisterClass *RC = getRegClassFor(RegVT);

      unsigned Reg = addLiveIn(MF, ArgReg, RC);
      SDValue ArgValue = DAG.getCopyFromReg(Chain, DL, Reg, RegVT);

      if (VA.getLocInfo() != CCValAssign::Full) {
        unsigned Opcode = 0;
        if (VA.getLocInfo() == CCValAssign::SExt)
          Opcode = ISD::AssertSext;
        else if (VA.getLocInfo() == CCValAssign::ZExt)
          Opcode = ISD::AssertZext;
        if (Opcode != 0)
          ArgValue =
              DAG.getNode(Opcode, DL, RegVT, ArgValue, DAG.getValueType(ValVT));

        ArgValue = DAG.getNode(ISD::TRUNCATE, DL, ValVT, ArgValue);
      }
      InVals.push_back(ArgValue);
    } else {
      MVT LocVT = VA.getLocVT();
      assert(VA.isMemLoc() && "Argument not register or memory");

      int FI = MFI.CreateFixedObject(LocVT.getSizeInBits() / 8,
                                     VA.getLocMemOffset(), true);

      SDValue FIN = DAG.getFrameIndex(FI, getPointerTy(DAG.getDataLayout()));
      SDValue Load = DAG.getLoad(LocVT, DL, Chain, FIN,
                                 MachinePointerInfo::getFixedStack(MF, FI));
      InVals.push_back(Load);
      OutChains.push_back(Load.getValue(1));
    }
  }

  if (!OutChains.empty()) {
    OutChains.push_back(Chain);
    Chain = DAG.getNode(ISD::TokenFactor, DL, MVT::Other, OutChains);
  }

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
