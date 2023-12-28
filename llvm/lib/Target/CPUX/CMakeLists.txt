add_llvm_component_group(CPUX)

set(LLVM_TARGET_DEFINITIONS CPUX.td)

tablegen(LLVM CPUXGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM CPUXGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM CPUXGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM CPUXGenMCPseudoLowering.inc -gen-pseudo-lowering)

add_public_tablegen_target(CPUXCommonTableGen)

add_llvm_target(CPUXCodeGen
  CPUXTargetMachine.cpp
  )

add_subdirectory(MCTargetDesc)
add_subdirectory(TargetInfo)
