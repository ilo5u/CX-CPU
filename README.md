# Forward
This is a project about graduation thesis.

## sys/sys.src
Include all verilog sources files about constructing a SoC and simulation files on it.

## backend
Include all documents about how to transfer the user-defined ISA on llvm backend.

## pics
Include all description pictures used in markdown files.

# LLVM
Since the LLVM compilation tools support the techniques that by writing compiler backends to convert the LLVM Intermediate Representation``IR`` to code for a specified machine, this project would follow its [Document: 'Writing an LLVM Backend'](https://llvm.org/docs/WritingAnLLVMBackend.html#introduction) to convert the c language(subset of it) to assembly code fitted with CX-CPU.

## References
[[1]Chen Chung-Shu.TutorialLLVMBackend,Release 3.9.1,2018](http://jonathan2251.github.io/lbd/)<br>
[[2]Writing an LLVM Backend,https://llvm.org/docs/WritingAnLLVMBackend.html](https://llvm.org/docs/WritingAnLLVMBackend.html#introduction)

## Basic Steps
1. Create a subclass of the **TargetMachine** class that describes characteristics of my model machine. May copy and modify the existed example of **MIPS**, then start with **CXCPUTargetMachine.cpp** and **CXCPUTargetMachine.h**.
2. Describe the register set of the model machine. Use *TableGen* to generate code for register definition, register aliases, and register classes from the **CXCPURegisterInfo.td** input file. Besides, write additional code for a subclass of the **CXCPURegisterInfo** class that represents the class register file data used for register allocation and also describes the interactions between registers.

# Instructions
## selection 
[[3]MIPS@32 ISA,MIPS32 Instruction Set Quick Reference v1.01](https://www.mips.com/products/architectures/mips32-2/)
![avatar](https://github.com/ilo5u/CX-CPU/blob/master/pics/ins1.png)
![avatar](https://github.com/ilo5u/CX-CPU/blob/master/pics/ins2.png)

# Micro-Architecture Design
Based on MIPS32 ISA, may choose 5-segments pipeline as the center of the design.

# Outter Devices
