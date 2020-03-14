set(LLVM_TARGET_DEFINITIONS CXCOther.td)

tablegen(LLVM CXCGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM CXCGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM CXCGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM CXCGenMCPseudoLowering.inc -gen-pseudo-lowering)

add_public_tablegen_target(CXCCommonTableGen)

add_llvm_target(CXCCodeGen
    CXCTargetMachine.cpp
)

add_subdirectory(TargetInfo)
add_subdirectory(MCTargetDesc)