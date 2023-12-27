add_llvm_component_group(CPUX)

set(LLVM_TARGET_DEFINITIONS CPUX.td)

tablegen(LLVM CPUXGenRegisterInfo.inc -gen-register-info)

add_public_tablegen_target(CPUXCommonTableGen)

add_llvm_target(CPUXCodeGen
  CPUXTargetMachine.cpp
  )

add_subdirectory(MCTargetDesc)
add_subdirectory(TargetInfo)
