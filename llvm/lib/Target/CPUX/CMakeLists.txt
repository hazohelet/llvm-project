add_llvm_component_group(CPUX)

set(LLVM_TARGET_DEFINITIONS CPUX.td)

tablegen(LLVM CPUXGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM CPUXGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM CPUXGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM CPUXGenMCPseudoLowering.inc -gen-pseudo-lowering)
tablegen(LLVM CPUXGenDAGISel.inc -gen-dag-isel)

tablegen(LLVM CPUXGenCallingConv.inc -gen-callingconv)

tablegen(LLVM CPUXGenCodeEmitter.inc -gen-emitter)
tablegen(LLVM CPUXGenMCCodeEmitter.inc -gen-emitter)

tablegen(LLVM CPUXGenAsmWriter.inc -gen-asm-writer)

add_public_tablegen_target(CPUXCommonTableGen)

add_llvm_target(CPUXCodeGen
  CPUXAsmPrinter.cpp
  CPUXFrameLowering.cpp
  CPUXInstrInfo.cpp
  CPUXISelDAGToDAG.cpp
  CPUXISelLowering.cpp
  CPUXMergeBaseOffset.cpp
  CPUXMachineFunction.cpp
  CPUXMCInstLower.cpp
  CPUXRegisterInfo.cpp
  CPUXSubtarget.cpp
  CPUXTargetMachine.cpp
  CPUXTargetObjectFile.cpp

  ADD_TO_COMPONENT
  CPUX
  )

add_subdirectory(MCTargetDesc)
add_subdirectory(TargetInfo)
