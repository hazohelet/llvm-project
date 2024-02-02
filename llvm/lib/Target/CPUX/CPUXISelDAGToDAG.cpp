#include "CPUXISelDAGToDAG.h"
#include "CPUX.h"

#include "CPUXMachineFunction.h"
#include "CPUXRegisterInfo.h"
#include "CPUXTargetMachine.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/CodeGen/SelectionDAGNodes.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetMachine.h"
using namespace llvm;

#define DEBUG_TYPE "CPUX-isel"

bool CPUXDAGToDAGISel::runOnMachineFunction(MachineFunction &MF) {
  Subtarget = &MF.getSubtarget<CPUXSubtarget>();
  bool Ret = SelectionDAGISel::runOnMachineFunction(MF);

  return Ret;
}

bool CPUXDAGToDAGISel::SelectAddrFI(SDValue Addr, SDValue &Base) {
  if (auto FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
    Base = CurDAG->getTargetFrameIndex(FIN->getIndex(), MVT::i32);
    return true;
  }
  return false;
}

void CPUXDAGToDAGISel::Select(SDNode *Node) {
  unsigned Opcode = Node->getOpcode();
  MVT XLenVT = MVT::i32;
  SDLoc DL(Node);

  LLVM_DEBUG(errs() << "Selecting: "; Node->dump(CurDAG); errs() << "\n");

  if (Node->isMachineOpcode()) {
    LLVM_DEBUG(errs() << "== "; Node->dump(CurDAG); errs() << "\n");
    Node->setNodeId(-1);
    return;
  }

  switch (Opcode) {
  default:
    break;
  case ISD::FrameIndex: {
    SDValue Imm = CurDAG->getTargetConstant(0, DL, XLenVT);
    int32_t FI = cast<FrameIndexSDNode>(Node)->getIndex();
    SDValue TFI = CurDAG->getTargetFrameIndex(FI, XLenVT);
    ReplaceNode(Node, CurDAG->getMachineNode(CPUX::ADDI, DL, XLenVT, TFI, Imm));
    return;
  }
  }

  SelectCode(Node);
}

void CPUXDAGToDAGISel::processFunctionAfterISel(MachineFunction &MF) {}

FunctionPass *llvm::createCPUXISelDag(CPUXTargetMachine &TM,
                                      CodeGenOpt::Level OptLevel) {
  return new CPUXDAGToDAGISel(TM, OptLevel);
}

char CPUXDAGToDAGISel::ID = 0;
