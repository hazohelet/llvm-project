#ifndef LLVM_LIB_TARGET_CPUX_CPUXISELDAGTODAG_H
#define LLVM_LIB_TARGET_CPUX_CPUXISELDAGTODAG_H

#include "CPUX.h"
#include "CPUXSubtarget.h"
#include "CPUXTargetMachine.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/Debug.h"

namespace llvm {
class CPUXDAGToDAGISel : public SelectionDAGISel {
public:
  static char ID;
  explicit CPUXDAGToDAGISel(CPUXTargetMachine &TM, CodeGenOpt::Level OL)
      : SelectionDAGISel(ID, TM, OL), Subtarget(nullptr) {}

  StringRef getPassName() const override {
    return "CPUX DAG->DAG Pattern Instruction Selection";
  }

  bool runOnMachineFunction(MachineFunction &MF) override;

protected:
  const CPUXSubtarget *Subtarget;

private:
#include "CPUXGenDAGISel.inc"

  const CPUXTargetMachine &getTargetMachine() {
    return static_cast<const CPUXTargetMachine &>(TM);
  }

  void Select(SDNode *N) override;

  bool SelectAddrFI(SDValue Addr, SDValue &Base);

  inline SDValue getImm(const SDNode *Node, unsigned Imm) {
    return CurDAG->getTargetConstant(Imm, SDLoc(Node), Node->getValueType(0));
  }

  void processFunctionAfterISel(MachineFunction &MF);
};

FunctionPass *createCPUXISelDag(CPUXTargetMachine &TM,
                                CodeGenOpt::Level OptLevel);
} // namespace llvm

#endif
