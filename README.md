# Forward

This is a project about graduation thesis.

## sys/sys.src

Include all verilog sources files about constructing a SoC and simulation files on it.

## backend

Include all documents about how to transfer the user-defined ISA on llvm backend.

## pics

Include all description pictures used in markdown files.

## tools

1. Download and install ``CentOS 7``.
2. Download source codes with llvm development tools from ``http://llvm.org/releases/download.html`` and compile manually.
   1. llvm-3.9.0.src.tar.xz ``e.g. wget http://releases.llvm.org/3.9.0/llvm-3.9.0.src.tar.xz``
   2. options
      1. cfe-3.9.0.src.tar.xz
      2. clang-tools-extra-3.9.0.src.tar.xz
      3. libcxx-3.9.0.src.tar.xz
      4. libcxxabi-3.9.0.src.tar.xz
      5. libunwind-3.9.0.src.tar.xz
      6. lld-3.9.0.src.tar.xz
      7. lldb-3.9.0.src.tar.xz
      8. openmp-3.9.0.src.tar.xz
      9. polly-3.9.0.src.tar.xz
   3. use ``cmake``, like the normally steps of building, with ``cmake ../`` and ``cmake --build .`` in the building directory.
3. Download and install ``Vivado 2018.3`` and other ``Xilinx`` design tools, with ``ModelSim`` optionally.

# LLVM

Since the LLVM compilation tools support the techniques that by writing compiler backends to convert the LLVM Intermediate Representation``IR`` to code for a specified machine, this project would follow its [Document: 'Writing an LLVM Backend'](https://llvm.org/docs/WritingAnLLVMBackend.html#introduction) to convert the c language(subset of it) to assembly code fitted with CX-CPU.

## References

[[1]] Chen Chung-Shu.TutorialLLVMBackend,Release 3.9.1,2018,http://jonathan2251.github.io/lbd/<br>
[[2]] Writing an LLVM Backend,https://llvm.org/docs/WritingAnLLVMBackend.html<br>
[[3]] TableGen,http://llvm.org/docs/TableGen/index.html<br>
[[4]] The Design of a Custom 32-bit RISC CPU and LLVM Compiler Backend,http://scholarworks.rit.edu/thesis

[1]: http://jonathan2251.github.io/lbd/
[2]: https://llvm.org/docs/WritingAnLLVMBackend.html
[3]: http://llvm.org/docs/TableGen/index.html
[4]: http://scholarworks.rit.edu/thesis

## TableGen

*TableGen* files consist of two key types: *class* and *definitions*, both of which are considered *records*.<sup>[[3]]</sup><font size=4>``Records = Unique Name + List of Values + List of Superclasses``</font>


*TableGen definitions* are marked with the **def** keyword. For example, <font size=4>```def Obj : Base<"param1", "param2">;```</font> **Obj** is **Base** record initialised with values **param1** and **param2**. Especially, most target *TableGen* files include the generic ones in **"include//llvm//Target"**.


*TableGen classes* are abstract records that are used to build and describe other records. They are marked with the **class** keyword.


The power in *TableGen* is to interpret the source files into an internal representation that can be generated into anything you want.<sup>[[3]]</sup>

## Basic Steps

1. Create a subclass of the **TargetMachine** class that describes characteristics of my model machine. May copy and modify the existed example of **MIPS**, then start with **CXCPUTargetMachine.cpp** and **CXCPUTargetMachine.h**.
2. Describe the register set of the model machine. Use *TableGen* to generate code for register definition, register aliases, and register classes from the **CXCPURegisterInfo.td** input file. Besides, write additional code for a subclass of the **CXCPURegisterInfo** class that represents the class register file data used for register allocation and also describes the interactions between registers.
3. Describe the instruction set of CX-CPU. Use *TableGen* to generate code for target-specific instructions from target-specific versions of **CXCPUInstrFormats.td** and **CXCPUInstrInfo.td**. Besides, write additional code for a subclass of the **CXCPUInstrInfo** class to represent machine instructions supported by the model machine.
4. Describe the selection and conversion of the *LLVM IR* from a Directed Acyclic Graph``DAG`` representation of instructions to CX-CPU instructions. Use *TableGen* to generate code that matches patterns and selects instructions based on additional information in **CXCPUInstrInfo.td**. Besides, write code for **CXCPUISelDAGToDAG.cpp** to perform pattern matching and DAG-to-DAG instruction selection. Also write code in **CXCPUISelLowering.cpp** to replace or remove operations and data types that are not supported natively in a *SelectionDAG*.
5. Write code for an assembly printer that converts *LLVM IR* to a *GAS* format for the model machine. To do so, assembly strings to the instructions shuold be defined in **CXCPUInstrInfo.td** and also write code for a subclass of *AsmPrinter* that performs the LLVM-to-assembly conversion and a trivial subclass of **CXCPUAsmInfo**.

## Preliminaries

1. Create a subdirectory named ``CXCPU`` under ``lib/Target`` to hold all the files related to the model machine, **CXCPU** target.
2. Create a ``CMakeLists.txt`` in ``lib/Target/CXCPU``, may easily copy and modify an existed file like the ``CMakeLists.txt`` of **MIPS**. It must also be noted that the ``CMakeLists.txt`` contains the ``LLVM_TARGET_DEFINITIONS`` variable.
3. Create a ``CXCPUTargetMachine.cpp`` in ``lib/Target/CXCPU``, and implement a sublcass of ``LLVMTargetMachine``.
4. Run ``cmake`` with ``DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=CXCPU``.

## Target Machine

1. Create a concrete target-specific subclass of ``LLVMTargetMachine`` in ``CXCPUTargetMachine.h`` and ``CXCPUTargetMachine.cpp``. Especially, ``getInstrInfo(); getRegisterInfo(); getFrameInfo(); getDataLayout(); getSubtargetImpl();`` methods must be implemented. 

## Files

This directory tree is modified by the reference [[4]], Guides I-12.

```cpp
--> lib/Target/CXCPU/
    --- CXCPU.h
    --- CXCPU.td
    --- CXCPUAsmPrinter.cpp
    --- CXCPUCallingConv.td
    --- CXCPUFrameLowering.cpp
    --- CXCPUFrameLowering.h
    --- CXCPUISelDAGToDAG.cpp
    --- CXCPUISelLowring.cpp
    --- CXCPUISelLowering.h
    --- CXCPUInstrFormats.td
    --- CXCPUInstrInfo.cpp
    --- CXCPUInstrInfo.h
    --- CXCPUInstrInfo.td
    --- CXCPUMCInstLower.cpp
    --- CXCPUMCInstLower.h
    --- CXCPUMachineFunctionInfo.cpp
    --- CXCPUMachineFunctionInfo.h
    --- CXCPURegisterInfo.cpp
    --- CXCPURegisterInfo.h
    --- CXCPUSubtarget.cpp
    --- CXCPUSubtarget.h
    --- CXCPUTargetMachine.cpp
    --- CXCPUTargetMachine.h
    --- CMakeLists.txt
------> InstPrinter/
        --- CXCPUInstPrinter.cpp
        --- CXCPUInstPrinter.h
        --- CMakeLists.txt
        --- LLVMBuild.txt
    --- LLVMBuild.txt
------> MCTargetDesc/
        --- CXCPUAsmBackend.cpp
        --- CXCPUELFObjectWriter.cpp
        --- CXCPUFixupKinds.h
        --- CXCPUMCAsmInfo.cpp
        --- CXCPUMCAsmInfo.h
        --- CXCPUMCCodeEmitter.cpp
        --- CXCPUMCTargetDesc.cpp
        --- CXCPUMCTargerDesc.h
        --- CMakeLists.txt
        --- LLVMBuild.txt
------> TargetInfo/
        --- CXCPUTargetInfo.cpp
        --- CMakeLists.txt
        --- LLVMBuild.txt
```

## Registration and Building

After untar the ``llvm-3.9.0.src.tar.xz``, rename the ``llvm-3.9.0.src`` directory as ``src`` and copy the untared ``cfe-3.9.0.src.tar.xz`` directory, renamed as ``clang``, to ``src/tools``.

When these source files are already prepared, use ``cmake`` to build makefiles and then build the clang and the llvm. You can run a bash like this,

```bash
# in the directory where 'src' is
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCLANG_BUILD_EXAMPLES=ON -DLLVM_BUILD_EXAMPLES=ON -G "Unix Makefiles" ../src/
# -jn : n based on the number of processes on your computer
make -j4 -l4
```

After that, you can add ``build/bin`` to ``PATH``, then add all modified source files into ``src``, like ``src/CMakeLists.txt``, ``src/cmake/config-ix.cmake`` and so on. The rebuild the llvm by command ``cmake -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang -DCAMEK_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD=CXCPU -G "Unix Makefiles" ../src/`` and ``make -j4 -l4`` to get the llvm compiler supporting ``CXCPU``.

## Compilation
We can use clang first transfer the ``*.cpp`` file to ``*.bc`` file, which described by LLVM IR, using command ``clang -target mips-unknown-linux-gnu -c *.cpp -emit-llvm -o *.bc``. You can use ``llvm-dis`` tools to check the ``*.bc`` file by command ``llvm-dis *.bc -o -``. Finally, run command ``llc -march=CXCPU -relocation-model=pic -filetype=asm *.bc -o *.s`` and you will get the assemby description of ``*.cpp`` on the model machine which used the processor ``CXCPU``.

**The parameter after ``-target`` is ``mips-unknown-linux-gnu`` because ``CXCPU`` borrows the ABI from Mips.**

# Instructions

## references 

[[4]MIPS@32 ISA,MIPS32 Instruction Set Quick Reference v1.01](https://www.mips.com/products/architectures/mips32-2/)

## selections

![avatar](https://github.com/ilo5u/CX-CPU/blob/master/pics/ins1.png)
![avatar](https://github.com/ilo5u/CX-CPU/blob/master/pics/ins2.png)

# Micro-Architecture Design

## develops

**tool**   ``Vivado 2018.3``

**lang**   ``Verilog HDL``

## design

Based on MIPS32 ISA, may choose 5-segments pipeline as the center of the design.

# Outter Devices
