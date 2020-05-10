set (LLVM_TARGET_DEFINITIONS Chinx.td)

tablegen(LLVM ChinxGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM ChinxGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM ChinxGenCodeEmitter.inc -gen-emitter)
tablegen(LLVM ChinxGenMCCodeEmitter.inc -gen-emitter)

tablegen(LLVM ChinxGenAsmWriter.inc -gen-asm-writer)
tablegen(LLVM ChinxGenDAGISel.inc -gen-dag-isel)
tablegen(LLVM ChinxGenCallingConv.inc -gen-callingconv)
tablegen(LLVM ChinxGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM ChinxGenMCPseudoLowering.inc -gen-pseudo-lowering)

add_public_tablegen_target(ChinxCommonTableGen)

add_llvm_target(ChinxCodeGen
        ChinxAsmPrinter.cpp
        ChinxMCInstLower.cpp
        ChinxFrameLowering.cpp
        ChinxInstrInfo.cpp
        ChinxISelLowering.cpp
        ChinxMachineFunction.cpp
        ChinxRegisterInfo.cpp
        ChinxSubtarget.cpp
        ChinxTargetObjectFile.cpp
        ChinxTargetMachine.cpp
        ChinxISelDAGToDAG.cpp
        )

add_subdirectory(InstPrinter)
add_subdirectory(TargetInfo)
add_subdirectory(MCTargetDesc)
