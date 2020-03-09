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
[[1]] Chen Chung-Shu.TutorialLLVMBackend,Release 3.9.1,2018<br>
[[2]] Writing an LLVM Backend,https://llvm.org/docs/WritingAnLLVMBackend.html<br>
[[3]] TableGen,http://llvm.org/docs/TableGen/index.html

[1]: http://jonathan2251.github.io/lbd/
[2]: https://llvm.org/docs/WritingAnLLVMBackend.html#introduction
[3]: http://llvm.org/docs/TableGen/index.html

## TableGen
**TableGen** files consist of two key types: *class* and *definitions*, both of which are considered *records*.<sup>[[1]]<sup><br>
<font size=5>``records = unique name + list of values + list of superclasses``</font><br>


## Basic Steps
1. Create a subclass of the **TargetMachine** class that describes characteristics of my model machine. May copy and modify the existed example of **MIPS**, then start with **CXCPUTargetMachine.cpp** and **CXCPUTargetMachine.h**.
2. Describe the register set of the model machine. Use *TableGen* to generate code for register definition, register aliases, and register classes from the **CXCPURegisterInfo.td** input file. Besides, write additional code for a subclass of the **CXCPURegisterInfo** class that represents the class register file data used for register allocation and also describes the interactions between registers.
3. Describe the instruction set of CX-CPU. Use *TableGen* to generate code for target-specific instructions from target-specific versions of **CXCPUInstrFormats.td** and **CXCPUInstrInfo.td**. Besides, write additional code for a subclass of the **CXCPUInstrInfo** class to represent machine instructions supported by the model machine.
4. Describe the selection and conversion of the *LLVM IR* from a Directed Acyclic Graph``DAG`` representation of instructions to CX-CPU instructions. Use *TableGen* to generate code that matches patterns and selects instructions based on additional information in **CXCPUInstrInfo.td**. Besides, write code for **CXCPUISelDAGToDAG.cpp** to perform pattern matching and DAG-to-DAG instruction selection. Also write code in **CXCPUISelLowering.cpp** to replace or remove operations and data types that are not supported natively in a *SelectionDAG*.
5. Write code for an assembly printer that converts *LLVM IR* to a *GAS* format for the model machine. To do so, assembly strings to the instructions shuold be defined in **CXCPUInstrInfo.td** and also write code for a subclass of *AsmPrinter* that performs the LLVM-to-assembly conversion and a trivial subclass of **CXCPUAsmInfo**.

# Instructions
## references 
[[4]MIPS@32 ISA,MIPS32 Instruction Set Quick Reference v1.01](https://www.mips.com/products/architectures/mips32-2/)
## selections
![avatar](https://github.com/ilo5u/CX-CPU/blob/master/pics/ins1.png)
![avatar](https://github.com/ilo5u/CX-CPU/blob/master/pics/ins2.png)

# Micro-Architecture Design
## develops
**tool**   ``Vivado 2018.3``<br>
**lang**   ``Verilog HDL``
## design
Based on MIPS32 ISA, may choose 5-segments pipeline as the center of the design.

# Outter Devices
