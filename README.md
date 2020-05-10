Tips: If graphs can not display properly, you can try download the **Readme.md** and open it with **Typora**, https://www.typora.io/

Please contact to 1047839605@qq.com or livewithoutsacrifice@outlook.com if you have any problems about this document or design of ``Chinx``.

# Forward

This is a project about graduation thesis to design and build a custom 32-bit CPU named ``Chinx``, by using SystemVerilog HDL, with its backend design on LLVM. ``Chinx`` owns 32-bit data bus and 8-bit address bus, considering that there are not so many data or instructions needed to store, and 32-bit registers. The data storage only supports aligned ``load`` and ``store`` operations. Especially, the storage model uses Harvard architecture. 

In this project, I will emphasize on how to build the LLVM backend to support ``Chinx``, and to design and implementation the micro-architecture of ``Chinx``. 

## chinx

Include all systemverilog sources files about constructing a SoC and simulation files on it.

## backend

Include all documents about how to transfer the custom ISA on LLVM backend.

## pics

Include all description pictures used in markdown files.

## tools

**If your development is built on Linux**

Download source codes with llvm development tools from ``http://llvm.org/releases/download.html`` and compile manually.
1. llvm-7.0.0.src.tar.xz ``e.g. wget http://releases.llvm.org/7.0.0/llvm-7.0.0.src.tar.xz``
2. options
   1. cfe-7.0.0.src.tar.xz
   2. compiler-rt-7.0.0.src.tar.xz
   3. if you want to build *clang* as the front-end of llvm, untar **cfe-7.0.0.src.tar.xz**  and rename it as **clang**, then move it to **tools**, the subdirectory of the source codes root.
   4. untar **compiler-rt-7.0.0.src.tar.xz** and rename it as **compiler-rt**, then move it to **project**, the subdirectory of the source codes root.
3. use ``cmake``, like the normally steps of building, with ``configure ``, ``cmake ../`` and ``cmake --build .`` in the building directory. Detailed description referred to https://llvm.org/docs.

**If your development is built on Windows**

1. Download the source codes from http://llvm.org/releases/download.html, like the operations on **Linux**.

2. To make the back-end porting and debug easily, download and install ``visual studio``.

   1. Create a **CMake** project at the root directory, and configure the **-DLLVM_TARGETS_TO_BUILD** parameter as **Chinx** to build a new backend to support ``Chinx``.

   2. The CMake configuration and build info is described in the **CMakeSettings.json**. Like this,

      ```json
      {
        "configurations": [
          {
            "name": "x64-Debug",
            "generator": "Ninja",
            "configurationType": "Debug",
            "inheritEnvironments": [
              "msvc_x64_x64"
            ],
            "buildRoot": "$BUILDROOT",
            "installRoot": "$INSTALLROOT",
            "cmakeCommandArgs": "-DLLVM_TARGETS_TO_BUILD=Chinx",
            "buildCommandArgs": "",
            "ctestCommandArgs": ""
          }
        ]
      }
      ```

3. Download and install ``Vivado 2018.3`` and other ``Xilinx`` design tools, with ``ModelSim`` optionally, if you'd like to have a try on implementing ``Chinx`` as a complete SoC.

# Instruction Set

``Chinx`` instruction set contains part of generic instructions and one custom instruction used for IO control. The memory access instructions only support aligned load and store operations. 

There are three instruction structures in ``Chinx``, 32-bit register instruction for operating 3 register operands at most named "FR", 32-bit immediately instruction for operating one immediate value and 2 register operands at most named "FI", and 32-bit jumping instruction for operating only one address value named "FJ".

| Type | Opcode | Operand 1  | Operand 2  | Operand 3  | Reserved |
| ---- | ------ | ---------- | ---------- | ---------- | -------- |
| FR   | 6 Bits | Ra(5 Bits) | Rb(5 Bits) | Rc(5 Bits) | 11 Bits  |

| Type | Opcode | Operand 1  | Operand 2  | Operand 3          |
| ---- | ------ | ---------- | ---------- | ------------------ |
| FI   | 6 Bits | Ra(5 Bits) | Rb(5 Bits) | Immediate(16 Bits) |

| Type | Opcode | Operand          |
| ---- | ------ | ---------------- |
| FJ   | 6 Bits | Address(26 Bits) |

The details are as the following figure showing.

## References

[[4]MIPS@32 ISA,MIPS32 Instruction Set Quick Reference v1.01](https://www.mips.com/products/architectures/mips32-2/)

## Instruction

![avatar](https://github.com/ilo5u/CX-CPU/blob/master/pics/ins.png)

# Micro-Architecture

**Tool**   ``Vivado 2018.3``

**Language**  ``SystemVerilog HDL``

If you find that the editor in ``Vivado`` is not convenient for use, try ``Visual Studio Code`` with extension on SystemVerilog.

## Design

We will focus on how to design and implement pipeline to build the micro-architecture of ``Chinx``. 5-segments pipeline is the most classic design, but in my model, the number of stages is not fixed. Cause pipeline is driven by register at each stage, consider that we need one cycle to fetch the next instruction, one cycle for decoding and executing arithmetic or logic operation, two cycles to access memory or IO ports and one cycle for writing data back to register bank or PC. 

"Two cycles" in above means that the frequency of generation clock in memory or IO ports is 25Khz while 50Khz used in each stages of pipeline, thus the pipeline needs at most two cycles to wait for the load operation or keep the data for storage active. These four stages are marked as "IF", "EMIT", "MEM" and "WB" in order. Take the ideal situation for example,

![avatar](https://github.com/ilo5u/CX-CPU/blob/master/pics/running_example.png)

Since the fifth instruction "LW $4, 0($0)" and the next arithmetic instruction do not have conflict, the next instruction execute parallelly with the load operation. The jump instruction "JR $0" will occupy one cycle to push the correct PC value into "ID" stage, thus the next instruction can be fetched over, but it would not be emitted and this one slot is abandoned.

 ### Top Module

Besides the pipeline as kernel, there needs more IO controller and outer clock for timing. 

![avatar](https://github.com/ilo5u/CX-CPU/blob/master/pics/top.png)

1. CU

   This unit would generate current PC value to fetch instruction from ROM at the posedge of system clock(50Khz). Actually, it would select the PC from EPC(recorded PC when the pipeline is stalled for one cycle), IPC(PC used for interruption service), RPC(recorded the next PC when function call or interruption occurs) or BPC(calculated by ALU when BNE, BLE, BEQ, CALL, or JUMP instruction executed) and then preserve the selected value in register to ensure that the ROM module can fetch the correct instruction.

2. C0

   The coprocessor unit is mainly responsible for interrupt control and PC control. When outer device sends a interrupt request, this unit must holds the request signal active till the "EMIT" stage accepts this request and responses. Besides, it would preserve stalled PC(EPC), and returned PC(RPC) at the posedge of system clock(50Khz). This module supports at most two unique interrupt request, cause it can only pre-store two unique address for interruption services. 

3. Regfiles

   It holds 32 32-bit registers in total, and the $0 register keeps constant zero, besides, value in $31 can be used default branch and $29 used for indexing the top of stack in memory. Only at the posedge of system clock with the write-enable signal active, the data can be written into the indexed register except $0. However, data can be read at any time, without control of clock. Due to that ``Chinx`` support tasks swapping, like interrupt service, the register bank must keep consistent before and after the swapping. Thus, there are several registers used for backup specially, like backups for $28-$31. It must be noted that the backup enable signal is conflict with write enable signal.

4. ROM

   The instruction rom contains 256 blocks of 32-bit, since each instruction is 32-bit. The address width is 8-bit since ``Chinx`` is just a model machine and we need not implement so many instructions to complete the tests on it. To shrink the scale of storage block can also improve the simulation performance. To fetch an instruction does not need to be driven by clock, but it would increase the time delay and lower the frequency of system clock passively.

5. RAM

   The data ram contains 256 blocks of 8-bit, combined by 4 chips of 64x8 Bits. Its front 4 bytes are used for IO ports. Directions of IO ports are controlled by SET instruction. This unit is driven by memory clock(25Khz), which is double divided by system clock, thus all memory access operations executed in pipeline need to handle the delay correctly.

6. Pipeline

   Although the pipeline contains 5 segments, this module only needs to implement one of them, "EMIT". CU is responsible for "IF" stage. RAM would handle "MEM" stage. Regfiles is responsible for "WB" stage. Thus, the instruction decoding and arithmetic or logic instruction executing will be handled in "EMIT" stage. And this stage would also control the stall and run of pipeline, as a center unit to generate all control signals sending to other units.

7. CLOCK

   This unit is used for timing. Every 10ms, it would overturn its output electrical level and this output signal is connected with the 0th interrupt request pin of C0.

8. PORTS

   Four 8-bit ports are connected with the front 4-bytes of RAM in order. Each port is bidirectional.

### Pipeline Foundation

#### IF

![avatar](https://github.com/ilo5u/CX-CPU/blob/master/pics/if.png)

#### EMIT

![avatar](https://github.com/ilo5u/CX-CPU/blob/master/pics/emit.png)

#### MEM

![avatar](https://github.com/ilo5u/CX-CPU/blob/master/pics/mem.png)

#### WB

![avatar](https://github.com/ilo5u/CX-CPU/blob/master/pics/wb.png)

### RAM Access Timing

#### Load

![avatar](https://github.com/ilo5u/CX-CPU/blob/master/pics/load.png)

#### Store

![avatar](https://github.com/ilo5u/CX-CPU/blob/master/pics/store.png)

## Implementation

TODO.

# LLVM

Since the LLVM compilation tools support the techniques that by writing compiler backends to convert the LLVM Intermediate Representation``IR`` to code for a specified machine, this project would follow its [Document: 'Writing an LLVM Backend'](https://llvm.org/docs/WritingAnLLVMBackend.html#introduction) to convert the c language(subset of it) to assembly code fitted with Chinx.

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

*TableGen definitions* are marked with the **def** keyword. For example, <font size=4>```def Obj : Base<"param1", "param2">;```</font> **Obj** is **Base** record initialised with values **param1** and **param2**. Especially, most target *TableGen* files include the generic ones in **"include/llvm/Target"**.

*TableGen classes* are abstract records that are used to build and describe other records. They are marked with the **class** keyword.


The power in *TableGen* is to interpret the source files into an internal representation that can be generated into anything you want.<sup>[[3]]</sup>

## Basic Steps

1. Create a subclass of the **TargetMachine** class that describes characteristics of my model machine. May copy and modify the existed example of **MIPS**, then start with **ChinxTargetMachine.cpp** and **ChinxTargetMachine.h**.
2. Describe the register set of the model machine. Use *TableGen* to generate code for register definition, register aliases, and register classes from the **ChinxRegisterInfo.td** input file. Besides, write additional code for a subclass of the **ChinxRegisterInfo** class that represents the class register file data used for register allocation and also describes the interactions between registers.
3. Describe the instruction set of Chinx. Use *TableGen* to generate code for target-specific instructions from target-specific versions of **ChinxInstrFormats.td** and **ChinxInstrInfo.td**. Besides, write additional code for a subclass of the **ChinxInstrInfo** class to represent machine instructions supported by the model machine.
4. Describe the selection and conversion of the *LLVM IR* from a Directed Acyclic Graph``DAG`` representation of instructions to Chinx instructions. Use *TableGen* to generate code that matches patterns and selects instructions based on additional information in **ChinxInstrInfo.td**. Besides, write code for **ChinxISelDAGToDAG.cpp** to perform pattern matching and DAG-to-DAG instruction selection. Also write code in **ChinxISelLowering.cpp** to replace or remove operations and data types that are not supported natively in a *SelectionDAG*.
5. Write code for an assembly printer that converts *LLVM IR* to a *GAS* format for the model machine. To do so, assembly strings to the instructions shuold be defined in **ChinxInstrInfo.td** and also write code for a subclass of *AsmPrinter* that performs the LLVM-to-assembly conversion and a trivial subclass of **ChinxAsmInfo**.

## Registration

To register for ``Chinx`` and build a new compiler supports it, these modified files are the least requirements:

```cpp
src
--> cmake
    --- config-ix.cmake
--> include
    --> llvm
        --> ADT
            --- Triple.h
        --> Object
            --- ELFObjectFile.h
        --> BinaryFormat
            --- ELF.h
            --> ELFRelocs
                --- Chinx.def
--> lib
    --> MC
        --- MCSubtargetInfo.cpp
        --- SubtargetFeature.cpp
    --> Object
        --- ELF.cpp
    --> Support
        --- Triple.cpp
--- CMakeLists.txt
```

### src/cmake/config-ix.cmake

LLVM uses string to match the target machine, thus we need to add an identification ``chinx`` in the source code.

```cmake
elseif (LLVM_NATIVE_ARCH MATCHES "chinx")
	set(LLVM_NATIVE_ARCH Chinx)
```

### src/include/llvm/ADT/Triple.h

The unique enumeration **Triple::chinx** will identify ``Chinx`` as an unique target machine in the later design of LLVM backend.

```cpp
#undef chinx // avoid identification conflict
class Triple {
    public:
    enum ArchType {
        chinx
    }
}
```

### src/inclue/llvm/Object/ELFObjectFile.h

*ELFXXX.h* and *ELFXXX.cpp* are used to describe the ELF(Executable and Linkable Format) file generation.

```cpp
template <class ELFT> StringRef ELFOjectFile<ELFT>::getFileFormatName() const {
    switch (EF.getHeader()->e_ident[ELF::EI_CLASS]) {
        case ELF::ELFCLASS32:
            switch (EF.getHeader()->e_machine) {
                case ELF::EM_CHINX:
                    return "ELF32-chinx";
            }
    }
}
```

### src/include/llvm/BinaryFormats/ELF.h

Set the **e_flags** of program header table in the ``Chinx`` ELF file.

| ELF Header | Program Header Table | Segment 1 | Segment 2 | ... |

```cpp
enum {
    EM_CHINX = 404 // a new enumeration constant without ambiguity
}
// e_flags
enum : unsigned {
    // if you do not have the demand to specify this word
    // ignore it
    EF_CHINX_PIC = 0x00000002 // position independent code
}
enum {
    #include "ELFRelocs/Chinx.def"
}
```

### src/include/llvm/BinaryFormats/ELFRelocs/Chinx.def

Describe some info about relocation, used for generating ELF file.

```cmake
#ifndef ELF_RELOC
#error "ELF_RELOC must be defined"
#endif
ELF_RELOC(R_CHINX_NONE,                0)
ELF_RELOC(R_CHINX_32,                  2)
...
ELF_RELOC(R_CHINX_TLS_TPREL_LO16,     50)
ELF_RELOC(R_CHINX_GLOB_DAT,           51)
ELF_RELOC(R_CHINX_JUMP_SLOT,          127)
```

Actually, this ***.def** file will be replaced by definition of **enum**. The keyword **ELF_RELOC** is a macro as below

```cpp
#define ELF_RELOC(name, value) name = value,
```

Thus, if you do not need to specify such information in ELF files, ignore it.

### src/lib/Object/ELF.cpp

```cpp
StringRef llvm::object::getELFRelocationTypeName(uint32_t Machine, uin32_t Type) {
    switch (Machine) {
        case ELF::EM_CHINX:
            switch (Type){
                    #include "llvm/BinaryFormat/ELFRelocas/Chinx.def"
                default:
                    break;
            }
    }
}
```

### src/lib/Support/Triple.cpp

Define string of each unique target machine for all enumerations represented unique architecture. e.g.  Unique architecture``chinx`` identified by string ``"chinx"``, and this string will be matched in serval CMake files.

Clarify that the architecture of ``Chinx`` as 32-bit. All the codes added in the registration stage are aimed for providing some machine associated descriptions on ``Chinx``.

```cpp
StringRef Tripe::getArchTypeName(ArchType Kind) {
    switch (Kind){
        case chinx:
            return "chinx";
    }
}
StringRef Triple::getArchTypePrefix(ArchType Kind) {
    switch (Kind) {
        case chinx:
            return "chinx";
    }
}
Triple::ArchType Triple::getArchTypeForLLVMName(StringRef Name) {
    return StringSwitch<Triple::ArchType>(Name).Case("chinx", chinx);
}
static Triple::ArchType parseArch(StringRef ArchName) {
    auto AT = StringSwitch<Triple::ArchType>(ArchName).Case("chinx", Triple::chinx);
}
static Triple::ObjectFormatType getDefaultFormat(const Triple& T) {
    switch (T.getArch()) {
        case Triple::chinx:
            return Triple::ELF;
    }
}
static unsigned getArchPointerBitWidth(llvm::Triple::ArchType Arch) {
    switch (Arch) {
        case llvm::Triple::chinx:
            return 32;
    }
}
Triple Triple::get32BitArchVariant() const {
    switch (getArch()) {
        case Triple::chinx:
            // Already 32-bit.
            break;
    }
}
```

After modifications above, we have done the configuration of ELF support and some architecture descriptions on ``Chinx``, like that we clarify ``Chinx`` as a 32-bit machine and declare that to generate executable file as position independent code.

If you do not want to fail to compile C program for ``Chinx`` and see error messages of unrecognized of ``Chinx`` when run the modified compiler, you may try to add some codes to mask these messages as below.

### src/lib/MC/MCSubtargetInfo.cpp

```cpp
bool ChinxDisableUnrecognizedMessage = false;
void MCSubtargetInfo::InitMCProcessorInfo(StringRef CPU, StringRef FS) {
  if (TargetTriple.getArch() == llvm::Triple::chinx)
    ChinxDisableUnrecognizedMessage = true;
}
const MCSchedModel &MCSubtargetInfo::getSchedModelForCPU(StringRef CPU) const {
    if (TargetTriple.getArch() != llvm::Triple::chinx)
        errs() << "'" << CPU
               << "' is not a recognized processor for this target"
               << " (ignoring processor)\n";
}
```

### src/lib/MC/SubtargetFeature.cpp

```cpp
extern bool ChinxDisableUnrecognizedMessage;
void SubtargetFeatures::ToggleFeature(FeatureBitset &Bits, StringRef Feature, 
                                      ArrayRef<SubtargetFeatureKV> FeatureTable) {
    if (!ChinxDisableUnrecognizedMessage)
    errs() << "'" << Feature << "' is not a recognized feature for this target"
           << " (ignoring feature)\n";
}
void SubtargetFeatures::ApplyFeatureFlag(FeatureBitset &Bits, StringRef Feature,
                                         ArrayRef<SubtargetFeatureKV> FeatureTable) {
  if (!ChinxDisableUnrecognizedMessage)
	assert(hasFlag(Feature));
  if (!ChinxDisableUnrecognizedMessage)
    errs() << "'" << Feature << "' is not a recognized feature for this target"
           << " (ignoring feature)\n";
}
FeatureBitset SubtargetFeatures::getFeatureBits(StringRef CPU,
                                                ArrayRef<SubtargetFeatureKV> CPUTable,
                                                ArrayRef<SubtargetFeatureKV> FeatureTable) {
    if (!ChinxDisableUnrecognizedMessage)
        errs() << "'" << CPU << "' is not a recognized processor for this target"
               << " (ignoring processor)\n";
}
```

To make and build the new backend correctly, we need to modify some CMake and LLVMBuild files. Obviously, we need to add ``Chinx`` identifier in the CMakeLists.txt at the source root.

### src/CMakeLists.txt

```cmake
set(LLVM_ALL_TARGETS
Chinx
)
```

But if you would like to give the parameter **TARGETS_TO_BUILD=Chinx** manually every time running cmake, there is no need to add such description in the CMakeLists.txt. I suggest that remove other targets in the CMakeLists.txt except ``Chinx``, and ``Chinx`` will be the only default target to build.

### src/lib/Target/LLVMBuild.txt

```cmake
subdirectories = 
	Chinx
```

## Implementation

Only codes added for registration on ``Chinx`` are not enough,  more implementation codes are needed.

Before starting the implementation, we need to understand the focus of the back-end porting.

```mermaid
graph LR
CP[C/C++] --> FE[Front End]
JP[Java] --> FE
OT[...] --> FE
FE --> OP[Optimizer]
OP --> BE[Backend]
BE --> M[MIPS]
BE --> C[CHINX]
BE --> OTT[...]
```

Front-end would build **AST**(Abstract Syntax Tree) to represent the source code, and convert it as IR for the coming optimization. Usually, LLVM uses **Clang** as the front end to generate the **IR**(Intermediate Representation) code. After that, machine-independent optimization on IR is essential. The most important work of backend is to transfer the IR code to machine-dependent code, called assembly code or machine code. To write the backend, we will focus on **DAG**, the converted form of AST, and we will see that the lowering operation is aimed for conversion. Based on DAG, the backend will select instruction for each node in a basic block. After instruction selection, the backend would schedule instructions based on architecture info provided by the target machine. Then, serial passes like register allocation, prologue and epilogue insertion, peephole optimization and assembly printing will run in order.

```mermaid
graph LR
IR[IR] --> DAG[DAG] --> L[Legalized DAG] --> IS[Instruction Selection] --> ISC[Scheduling] --> RA[Register Allocation] --> OT[...] --> AP[Assembly]
```

Now, we have had a brief look of the architecture of LLVM and how does the backend work, then we will follow steps to build the backend to support ``Chinx``.

Before starting, there is a suggestion that you could better to have a glance over the official document here https://llvm.org/docs/WritingAnLLVMBackend.html

Obviously, writing a backend to support new target machine needs a lot of time and coding work. Fortunately, some processors, like MIPS, have been supported by LLVM. Due to that, we can use them for reference, thanking for the open LLVM and MIPS.

Let's have a overlook on the structure of the implementation coding files.

```cpp
--> lib/Target/Chinx/
    --- Chinx.h --- Chinx.td
    --- ChinxAsmPrinter.cpp
    --- ChinxCallingConv.td
    --- ChinxFrameLowering.cpp ChinxFrameLowering.h
    --- ChinxISelDAGToDAG.cpp ChinxISelDAGToDAG.h
    --- ChinxISelLowring.cpp ChinxISelLowering.h
    --- ChinxInstrFormats.td
    --- ChinxInstrInfo.cpp ChinxInstrInfo.h ChinxInstrInfo.td
    --- ChinxMCInstLower.cpp ChinxMCInstLower.h
    --- ChinxMachineFunctionInfo.cpp ChinxMachineFunctionInfo.h
    --- ChinxRegisterInfo.cpp ChinxRegisterInfo.h ChinxRegisterInfo.td
    --- ChinxSubtarget.cpp ChinxSubtarget.h
    --- ChinxTargetMachine.cpp ChinxTargetMachine.h
    --- ChinxTargetObjectFile.cpp  ChinxTargetObjectFile.h
    --- CMakeLists.txt LLVMBuild.txt
------> InstPrinter/
        --- ChinxInstPrinter.cpp ChinxInstPrinter.h
        --- CMakeLists.txt LLVMBuild.txt
    --- LLVMBuild.txt
------> MCTargetDesc/
        --- ChinxABIInfo.cpp ChinxABIInfo.h
    	--- ChinxBaseInfo.h
        --- ChinxMCAsmInfo.cpp ChinxMCAsmInfo.h
        --- ChinxMCTargetDesc.cpp ChinxMCTargerDesc.h
        --- CMakeLists.txt LLVMBuild.txt
------> TargetInfo/
        --- ChinxTargetInfo.cpp
        --- CMakeLists.txt LLVMBuild.txt
```

### ChinxTargetMachine

Since the LLVM is written by C++, implementing kinds of classes, especially inherited classes, is the center issue. **LLVMTargetMachine** is designed as a base for targets implemented with the LLVM target-independent code generator<sup>[[2]]</sup>. Thus, the entry of writing backends is implementing class **ChinxTargetMachine** inherited from **LLVMTargetMachine** in *ChinxTargetMachine.cpp* and *ChinxTargetMachine.h*. If you do not have any idea to write the details of the virtual methods in **ChinxTargetMachine**, you can easily copy the present codes in MIPS or SPARC or others and rewrite them. For example, some code fragments need to be modified as below

```cpp
// ---------------------------- //
//    ChinxTargetMachine.cpp    //
// ---------------------------- //
extern "C" void LLVMInitializeChinxTarget() {
    // Register the target.
    RegisterTargetMachine<ChinxTargetMachine>
            X(getTheChinxTarget());
    // getTheChinxTarget can fetch the unique instance
    // of class Target
}
```

If your custom CPU supports both little-endian and big-endian, you could implement a class **XXXTargetMachine** inherited from **LLVMTargetMachine**, then create a class **XXXelTargetMachine** inherited from **XXTargetMachine** to support little-endian and a class **XXXebTargetMachine** inherited from **XXTargetMachine** to support big-endian, like what MIPS has done. The initialization method would be modified as below,

```cpp
extern "C" void LLVMInitializeXXXTarget() {
    // Register the target.
    RegisterTargetMachine<XXXelTargetMachine>
            X(getTheXXXelTarget()); // little-endian
    RegisterTargetMachine<XXXebTargetMachine>
            Y(getTheXXXebTarget()); // big-endian
}
```

```mermaid
graph RL
A0[XXXelTargetMachine] --> B[XXXTargetMachine]
A1[XXXebTargetMachine] --> B
B --> C[LLVMTargetMachine]
```

cause **LLVMTargetMachine** will accept a parameter to determine whether the specific machine is little-endian or big-endian.

### ChinxTargetInfo

**ChinxTargetMachine** holds all the sources that would be used during the compiling time, especially the instance of **ChinxSubtarget** as below,

```cpp
class ChinxTargetMachine : public LLVMTargetMachine {
  ChinxSubtarget Subtarget;
}
```

But before building an instance of **ChinxTargetMachine**, LLVM needs to create a generic object of class **Target**, and inserts the object into the lists consisting of all the supported CPUs. 

```mermaid
graph TB
M[0: main] --> A[1: llvm::InitializeAllTargets] --> B[2: llvm::InitializeAllTargetInfos] --> C[3: LLVMInitializeChinxTargetInfo] -.-> A --> D[4: LLVMInitializeChinxTarget]
```

From the call graph we can see that the initialization of **ChinxTargetMachine**(4) is behind the call of **LLVMInitializeChinxTargetInfo**, cause we need to register ``Chinx`` first, but not use **ChinxTargetMachine**.

```cpp
// ------------------------------ //
//  TargetInfo/ChinxTargetInfo.cpp
// ------------------------------ //
using namespace llvm;
Target &llvm::getTheChinxTarget() {
  static Target TheChinxTarget;
  return TheChinxTarget;
}
extern "C" void LLVMInitializeChinxTargetInfo() {
    RegisterTarget<Triple::chinx, true>
            X(getTheChinxTarget(), "chinx", "Chinx", "Chinx");
}
```

In the method *LLVMInitializeChinxTargetInfo*, LLVM would bind the instance named **TheChinxTarget** with string "chinx" which will be used when specify the CPU as ``Chinx`` compiling *.bc files or match the target to build like what mentioned before, and the third string "Chinx" represents the backend name, just like the *ChinxRegisterInfo* or *ChinxInstrInfo* and so on. 

Besides, this allows the **TargetRegistry** to look up the target by name or by target triple<sup>[[2]]</sup>.

After creating an instance representing ``Chinx``, the registration is done, then the method *LLVMInitializeChinxTarget* will be called to initialize this instance, or supplement other critical info of ``Chinx`` by pass the type template **ChinxTargetMachine**.

### Register Definition

Virtual registers would be used in generating IR codes, so there are infinite registers can be allocated. But any CPU would have finite registers, thus we need to describe the register information in the source by TableGen tool.

```c++
// ---------------------------- //
//     ChinxRegisterInfo.td     //
// ---------------------------- //
class ChinxReg<bits<16> Enc, string n> : Register<n> {
    let HWEncoding = Enc;
    let Namespace = "Chinx";
}
class ChinxGPRReg<bits<16> Enc, string n> : ChinxReg<Enc, n>;
```

Cause ``Chinx`` only holds 32 registers, 16-bit encoding is enough.

```cpp
// ---------------------------- //
//     ChinxRegisterInfo.td     //
// ---------------------------- //
let Namespace = "Chinx" in {
    def ZERO : ChinxGPRReg<0, "zero">, DwarfRegNum<[0]>;
    def AT : ChinxGPRReg<1, "1">, DwarfRegNum<[1]>;
    def V0 : ChinxGPRReg<2, "2">, DwarfRegNum<[2]>;
    ...
    def FP : ChinxGPRReg<30, "fp">, DwarfRegNum<[30]>;
    def RA : ChinxGPRReg<31, "ra">, DwarfRegNum<[31]>;
}
```

The keyword **def** will define a list of registers from 0 to 31. The first parameter passed to **ChinxGPRReg** is the encoding of each register, different from the parameter in **DwarfRegNum**, which is the index of each register used in the backend. The second parameter passed to **ChinxGPRReg** will be used in assembly printing. For example, when print the register indexed 0, the string "$zero" will be printed, and the same for others.

If you want to combine some registers together for special purpose, you can define a new group, which will actually be a class after handled by tablegen. For example,

```cpp
// ---------------------------- //
//     ChinxRegisterInfo.td     //
// ---------------------------- //
def CPURegs : RegisterClass<"Chinx", [i32], 32, (add
    ZERO, AT,
    V0, V1, A0, A1, A2, A3,
    T0, T1, T2, T3, T4, T5, T6, T7, T8, T9,
    S0, S1, S2, S3, S4, S5, S6, S7,
    K0, K1,
    GP, SP, FP, RA)>;
def DstRegs : RegisterClass<"Chinx", [i32], 32, (add (sub CPURegs, ZERO, K0, K1))>;
def MEMRegs : RegisterClass<"Chinx", [i32], 32, (add (sub CPURegs, ZERO, K0, K1, RA))>;
```

**CPURegs** contains all the 32 registers, and **MEMRegs** contains all registers except "ZERO; K0; K1; RA", cause load and store operations would not use these four registers.  The "i32" parameter means its type, which is defined by the LLVM, 32-bit integer.

Since all available registers in ``Chinx`` defined, you can refer them in other source files if needed. Besides register definitions in *ChinxRegisterInfo.td*, we need to implement a class providing interfaces for accessing these resources.

In *ChinxRegisterInfo.h* and *ChinxRegisterInfo.cpp*,  special purpose for each register will be defined, like reserved registers. For example,

```cpp
// ----------------------------- //
//        ChinxRegisterInfo.h    //
// ----------------------------- //
class ChinxRegisterInfo : public ChinxGenRegisterInfo {
public:
  const MCPhysReg *getCalleeSavedRegs(const MachineFunction *MF) const override; // sprcify which register must be saved when function call occurs
  BitVector getReservedRegs(const MachineFunction &MF) const override; // specify which register can not be writable
  unsigned getFrameRegister(const MachineFunction &MF) const override; // specify which register to be the frame register
};
// ----------------------------- //
//      ChinxRegisterInfo.cpp    //
// ----------------------------- //
const MCPhysReg *
ChinxRegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
  return CSR_O32_SaveList; 
  // CSR_O32_SaveList will be explained
  // in talking about file ChinxCallingConv.td
}
BitVector ChinxRegisterInfo::
getReservedRegs(const MachineFunction &MF) const {
  static const MCPhysReg ReservedCPURegs[] = {
      Chinx::ZERO, Chinx::AT, Chinx::K0, Chinx::K1, Chinx::SP,
      Chinx::RA // compatible with declarations in ChinxRegisterInfo.td
  };
  BitVector Reserved(getNumRegs());
  for (unsigned I = 0; I < array_lengthof(ReservedCPURegs); ++I)
      Reserved.set(ReservedCPURegs[I]);
  return Reserved;
}
unsigned ChinxRegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  const TargetFrameLowering *TFI = MF.getSubtarget().getFrameLowering();
  return TFI->hasFP(MF) ? Chinx::FP : Chinx::SP;
}
```

The above three methods rewrite its virtual interfaces in class **ChinxGenRegisterInfo**, which is inherited from the base provided by LLVM, to let the backend run in a compatible way. Most works are like the above showed to rewrite the present methods. 

The superclass **ChinxGenRegisterInfo** is automatically created by tablengen tool after processing *ChinxRegisterInfo.td*. The file structure is as below,

```mermaid
graph LR
A[ChinxRegisterInfo.td] --tablegen--> B[ChinxGenRegisterInfo.inc]
C[ChinxRegisterInfo.h] --> D[ChinxRegisterInfo.o]
B --> D
B -.inline.-> C
E[ChinxRegisterInfo.cpp] --> D
```

### Instruction Definition

Besides the necessary register information mainly used for register allocation, we need to describe the instruction structure to let the backend select compatible instructions for each IR statement. Like what has done for adding register info, we need to write *.td, *.cpp and *.h files for instruction description. 

In *ChinxInstrFormats.td*, we can define kinds of instruction structures. There are three structures in ``Chinx``, register instruction for operating 3 register operands at most named "FR", immediately instruction for operating one immediate value and 2 register operands at most named "FI", and jumping instruction for operating only one address value named "FJ".

| Type | Opcode | Operand 1  | Operand 2  | Operand 3  | Reserved |
| ---- | ------ | ---------- | ---------- | ---------- | -------- |
| FR   | 6 Bits | Ra(5 Bits) | Rb(5 Bits) | Rc(5 Bits) | 11 Bits  |

| Type | Opcode | Operand 1  | Operand 2  | Operand 3          |
| ---- | ------ | ---------- | ---------- | ------------------ |
| FI   | 6 Bits | Ra(5 Bits) | Rb(5 Bits) | Immediate(16 Bits) |

| Type | Opcode | Operand          |
| ---- | ------ | ---------------- |
| FJ   | 6 Bits | Address(26 Bits) |

Take the definition of "FR" for example,

```cpp
class ChinxInst<dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin, Format f> :
    Instruction {
        field bits<32> Inst;
        let Namespace = "Chinx";
        bits<6> Opcode = 0;
        let Inst{31-26} = Opcode;
        let OutOperandList = outs;
        let InOperandList = ins;
        let AsmString = asmstr;
        let Pattern = pattern;
        let Itinerary = itin;
        bits<4> FormBits = Form.Value;
        ...
    }
class FR<bits<6> op, dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin> :
    ChinxInst<outs, ins, asmstr, pattern, itin, FrmR>
    {
        bits<5> ra;
        bits<5> rb;
        bits<5> rc;
        bits<11> reserved;
        let Opcode = op;
        let Inst{25-21} = ra;
        let Inst{20-16} = rb;
        let Inst{15-11} = rc;
        let Inst{10-0} = reserved;
    }
```

From above, we need to define a custom base of instruction structure named **ChinxInst**, which inherited from **Instruction** provided by LLVM. We need to notice that the "ins" and "outs" parameters are the same type named "dag", cause they are described by DAG which converted from IR, or AST for sure.

```mermaid
graph TB
subgraph DAG
D1[+] --> D[a]
D1 --> D2[-]
D2 --> D[a]
D2 --> E[b]
end
subgraph AST
P1[+] --> A0[a]
P1 --> P2[-]
P2 --> A1[a]
P2 --> C[b]
end
```

Actually, the structure of DAG in LLVM backend is so complicated, you can use ``llc -view-isel-dags ...`` to have a detail look on each DAG node. In brief, the DAG node is constructed by node type, input and output operands list and additional descriptions.

Based on the defined instruction structures, we can define kinds of instructions, like ADD, SUB, and so on. Let's have a brief look on it,

```cpp
// Arithmetic and logical instructions with 3 register operands.
class ArithLogicR<bits<6> op, string instr_asm, SDNode OpNode,
	InstrItinClass itin, RegisterClass RC, bit isComm = 0> :
	FR<op, (outs DstRegs:$ra), (ins RC:$rb, RC:$rc),
		!strconcat(instr_asm, "\t$ra, $rb, $rc"),
		[(set DstRegs:$ra, (OpNode RC:$rb, RC:$rc))], itin> {
	let reserved = 0;
	let isCommutable = isComm; // e.g. add rb rc =  add rc rb
	let isReMaterializable = 1;
}
```

**ArithLogicR** is defined as a matching rule for instruction operating 3 register operands. It can be used for catching instructions like ADD, SUB, OR, AND. But this class is only a declaration, we need to define instances for instruction selection.

```cpp
def ADD : ArithLogicR<0x02, "add", add, IIAlu, CPURegs, 1>;
def SUB : ArithLogicR<0x03, "sub", sub, IIAlu, CPURegs>;
```

The first parameter "0x02" in the definition of "ADD" represents its 6-bit opcode encoding. The second parameter string "add" will be used for assembly printing and the next "add" is an identity for the generic instruction selection pre-defined by LLVM. In fact, the "add" identity represents a DAG node structure, and for nodes with the same structure will select instruction "ADD" to replace it, that means instruction selection is essentially mapping each DAG node or nodes to custom instruction or instructions. The "IIAlu" parameter identifies the cost of "ADD" operation, and this is defined in *ChinxSchedule.td* mainly for instruction scheduling to optimize pipeline.

```cpp
// ------------------------------- //
//        ChinxSchedule.td         //
// ------------------------------- //
def ALU : FuncUnit;
def IIAlu    : InstrItinClass;
def IILoad   : InstrItinClass;
def IIStore  : InstrItinClass;
def IIBranch : InstrItinClass;
def IIPseudo : InstrItinClass;
def ChinxGenericItineraries : ProcessorItineraries<[ALU], [], [
    InstrItinData<IIAlu,    [InstrStage<1, [ALU]>]>,
    InstrItinData<IILoad,   [InstrStage<3, [ALU]>]>,
    InstrItinData<IIStore,  [InstrStage<3, [ALU]>]>,
    InstrItinData<IIBranch, [InstrStage<2, [ALU]>]>
]>;
```

Considering that there are so many instruction definitions, you can refer them in *backend/src/lib/Target/Chinx/ChinxInstrInfo.td* to look the details.

Similarly, *ChinxInstrInfo.cpp* and *ChinxInstrInfo.h* will supplement some methods on instructions defined in *ChinxInstrInfo.td*. For example, how to load and store the stack to handle the local variables are defined as below,

```cpp
// --------------------------------------------- //
//             ChinxInstrInfo.h                  //
// --------------------------------------------- //
class ChinxInstrInfo : public ChinxGenInstrInfo {
  ...
  void storeRegToStackSlot(MachineBasicBlock &MBB,
    MachineBasicBlock::iterator MBBI,
    unsigned SrcReg, bool isKill, int FrameIndex,
    const TargetRegisterClass *RC,
    const TargetRegisterInfo *TRI) const override {
    storeRegToStack(MBB, MBBI, SrcReg, isKill, FrameIndex, RC, TRI, 0);
  }
  void loadRegFromStackSlot(MachineBasicBlock &MBB,
    MachineBasicBlock::iterator MBBI,
    unsigned DestReg, int FrameIndex,
    const TargetRegisterClass *RC,
    const TargetRegisterInfo *TRI) const override {
    loadRegFromStack(MBB, MBBI, DestReg, FrameIndex, RC, TRI, 0);
  }
  ...
}
// --------------------------------------------- //
//              ChinxInstrInfo.cpp               //
// --------------------------------------------- //
void ChinxInstrInfo::storeRegToStack(MachineBasicBlock &MBB,
	MachineBasicBlock::iterator I, unsigned SrcReg, bool isKill, int FI,
	const TargetRegisterClass *RC, const TargetRegisterInfo *TRI, int64_t Offset) const {
	DebugLoc DL;
	MachineMemOperand *MMO = GetMemOperand(MBB, FI, MachineMemOperand::MOStore);
	unsigned Opc = Chinx::SW;
	BuildMI(MBB, I, DL, get(Opc)).addReg(SrcReg, getKillRegState(isKill))
		.addFrameIndex(FI).addImm(Offset).addMemOperand(MMO);
}
void ChinxInstrInfo::loadRegFromStack(MachineBasicBlock &MBB,
	MachineBasicBlock::iterator I, unsigned DestReg, int FI,
	const TargetRegisterClass *TRC,
	const TargetRegisterInfo *TRI, int64_t Offset) const {
	DebugLoc DL;
	if (I != MBB.end()) DL = I->getDebugLoc();
	MachineMemOperand *MMO = GetMemOperand(MBB, FI, MachineMemOperand::MOLoad);
	unsigned Opc = Chinx::LW;
	BuildMI(MBB, I, DL, get(Opc), DestReg).addFrameIndex(FI).addImm(Offset)
		.addMemOperand(MMO);
}
```

Local variables are stored in the stack, how to allocate space for them needs to rewrite the virtual methods *storeRegToSlockSlot* and *loadRegToSlockSlot*. By calling method *BuildMI*, we can build a compatible machine instruction with ``Chinx``, noticing that the local variable "Opc" is assigned with "Chinx::SW" or "Chinx::LW", which is defined in *ChinxInstrInfo.td* by "def : LW ..." or "def : SW ...". For example,

```mermaid
graph TB
subgraph ASM
B0["addi $1, $0, 0"] --> B1["sw $1, 4($0)"]
end
subgraph Function
A0["int a = 0;"] --> A1["int b = 0;"]
end
A0 -.-> B0
B1 -.-> A1
```



Besides local variables, parameters passed by function call are also stored in stack, and how to handle this situation is defined in *ChinxCallingConv.td*, *ChinxFrameLowering.h* and *ChinxFrameLowering.cpp*. When execute function call, parameters and return values will be saved into registers in priority and the rest will be saved into the stack. Once registers are needed, we must make sure that the value would be restored correctly when the callee returned.

```cpp
// ----------------------- //
//    ChinxCallingConv.td  //
// ----------------------- //
def CSR_O32 : CalleeSavedRegs<(add FP, RA,
    (sequence "S%u", 7, 0))>;
def RetCC_ChinxEABI : CallingConv<[
    // i32 are returned in registers V0, V1, A0, A1, A2, A3
    CCIfType<[i32], CCAssignToReg<[V0, V1, A0, A1, A2, A3]>>
]>;
```

From above, ``Chinx`` rules that $s0-$s7, $fp, and $ra must be saved when function call occurs, and the return values are stored into $v0-$v1, $a0-$a3 in priority. Besides, insertions of prologue and epilogue are necessary to ensure the environments would not be damaged due to function call. They are the critical methods designed in class **ChinxFrameLowering** as below,

```cpp
// ------------------------ //
//  ChinxFrameLowering.h    //
// ------------------------ //
class ChinxFrameLowering : public TargetFrameLowering {
  /// emitProlog/emitEpilog - These methods insert prolog and epilog code into
  /// the function.
  void emitPrologue(MachineFunction &MF, MachineBasicBlock &MBB) const override;
  void emitEpilogue(MachineFunction &MF, MachineBasicBlock &MBB) const override;
  ...
}
```

### Instruction Selection

If the custom instructions are all designed from the generic instructions, like ADD, it is easy to select the compatible instructions, just with the help of the default matching rules pre-defined by LLVM. I will focus on how to port an instruction that designed for special purpose.

"SET" is an instruction of "FI" type, to some degree, resemble to "SB" instruction. This instruction would set the 8-bit data unit, indexed by the specified address, as an input port or output port, thus it is an instruction used for control but not memory storage. For example,

```c
// test.c
#define CTRL *((volatile unsigned char *)0x3)
int main() {
  CTRL = 24;
  char a = 4;
}
```

After this c source file compiled, it would be like this,

```assembly
# test.s
...
addi $2, $0, 24
addi $3, $0, 3
set  $2, 0($3)   # use set to replace sb
addi $2, $0, 4
sb   $2, 0($sp)  # use sb normally
...
```

Since IO ports are fixed in address, writing or reading the IO ports will send the absolute address without using $sp or $gp, which only used for local variables or global variables. Thus, we can differentiate the IO control instruction and the memory storage instruction. But how we implement this feature in backends?

Let's have a look on the difference between this two IR statements, converting from "CTRL = 24" and "a = 4", with the help of debug-info by ``llc -debug -march=chinx -relocation-model=pic -filetype=asm test.bc -o test.s``, where "test.bc" is generated by ``clang -target x86_64-pc-windows-msvc -c test.c -emit-llvm -o test.bc``.

```cpp
// test.bc viewed by llvm-dis test.bc -o -
store volatile i8 24, i8* inttoptr (i64 3 to i8*), align 1 // CTRL = 24
...
store i8 4, i8* %2, align 1 // a = 4
// debug-info of instruction selection from DAG
ch = store<(volatile store 1 into `i8* inttoptr (i64 3 to i8*)`), trunc to i8> t4, Constant:i32<24>, Constant:i32<3>, undef // CTRL = 24
...
store<(store 1 into %ir.2), trunc to i8> t32, Constant:i32<4>, FrameIndex:i32<1>, undef:i32 // a = 4
```

Obviously, these two operations are both storage instruction generally, both marked as "store" type of these two DAG nodes. We need to find out the differences  between the description of the two nodes, and fortunately, the third operand of "CTRL = 24" is "Constant:i32<3>" while that of "a = 4" is "FrameIndex:i32<1>", cause variable "a" is located on stack using $sp. Due to this difference, we can reconsider the matching rules written in *ChinxInstrInfo.td*. Let's have a quick view,

```cpp
// --------------------------- //
//      ChinxInstrInfo.td      //
// --------------------------- //
def ADDRls : ComplexPattern<iPTR, 2, "SelectADDRls", [frameindex], [SDNPWantParent]>;
...
class StoreM<bits<6> op, string instr_asm, PatFrag OpNode,
	RegisterClass RC, Operand MemOpnd, bit Pseudo> :
    FMem<op, (outs), (ins RC:$ra, MemOpnd:$addr),
        !strconcat(instr_asm, "\t$ra, $addr"),
        [(OpNode RC:$ra, ADDRls:$addr)], IIStore> { // ADDRls is the key
    let isPseudo = Pseudo;
}
...
multiclass StoreMemory<bits<6> op, string instr_asm, PatFrag OpNode, bit Pseudo = 0> {
    def #NAME# : StoreM<op, instr_asm, OpNode, CPURegs, mem, Pseudo>;
}
...
defm SB : StoreMemory<0x3B, "sb", truncstorei8>;
```

The storage instruction declaration "StoreM" uses an address value with its type as "ADDRls", and this type is defined as a complex pattern which would call function "SelectADDRls" to do the matching work. In this complex pattern description, the second parameter describes the number of parameters after the parameter represented function "SelectADDRls", and the following parameters describe the types of parameters that accepted by function "SelectADDRls". You have to remember that the *.td files are related to c++ source files, thus these string descriptions probably represent functions defined in other c++ source files. Let's have a look in class **ChinxDAGToDAGISel**, where defines the method "SelectADDRls",

```cpp
// -------------------------- //
//   ChinxISelDAGToDAG.cpp    //
// -------------------------- //
/// ComplexPattern used on ChinxInstrInfo
/// Used on Chinx Load/Store instructions
bool ChinxDAGToDAGISel::SelectADDRls(SDNode *Parent, SDValue Addr, SDValue &Base, SDValue &Offset) { 
	...
	// if Address is FI, get the TargetFrameIndex.
	if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
        Base = CurDAG->getTargetFrameIndex(FIN->getIndex(), ValTy);
        Offset = CurDAG->getTargetConstant(0, DL, ValTy);
        return true; // matched by this pattern
    }
	...
}
```

The first parameter "Parent" of SDNode type is the result of "[SDNPWantParent]" described in complex pattern written in *ChinxInstrInfo.td*, and the "[frameindex]" parameter describes the "Addr" parameter in "SelectADDRls" can be casted in frame structure. Thus, the frame index address expression of DAG node representing "a = 4" can be matched to "StoreM" structure, and then the "SB" instruction would be selected.

Local and global variables storage operations would be matched to "StoreMemory" since there are all frame indexed by either $sp or $gp. But how about the absolute addressing？ From above, we can easily rewrite the complex pattern to make it match to the absolute addressing.

```cpp
// --------------------------- //
//      ChinxInstrInfo.td      //
// --------------------------- //
def ADDRio : ComplexPattern<iPTR, 2, "SelectADDRio",
				   [], []>; // no frameindex cause the base is not $sp, $gp, $fp
...
class SetPort<bits<6> op, string instr_asm, PatFrag OpNode,
	RegisterClass RC, Operand MemOpnd, bit Pseudo> :
	FMem<op, (outs), (ins RC:$ra, MemOpnd:$addr),
		!strconcat(instr_asm, "\t$ra, $addr"),
		[(OpNode RC:$ra, ADDRio:$addr)], IIStore> {
	let isPseudo = Pseudo;
}
...
multiclass SetIO<bits<6> op, string instr_asm, PatFrag OpNode, bit Pseudo = 0> {
	def #NAME# : SetPort<op, instr_asm, OpNode, CPURegs, mem, Pseudo>;
}
...
defm SET : SetIO<0x3E, "set", truncstorei8>;
```

The absolute addressing model does not need frame-index structure, and we do not need the parent DAG node, thus we dismiss the two parameters "[frameindex]" and "[SDNPWantParent]". Then declare a class "SetPort" using the new defined address matching pattern "ADDRio". Add the matching function in class **ChinxDAGToDAGISel** as below,

```cpp
// -------------------------- //
//   ChinxISelDAGToDAG.cpp    //
// -------------------------- //
bool ChinxDAGToDAGISel::SelectADDRio(SDValue Addr, SDValue &Base, SDValue &Offset) {
  EVT ValTy = Addr.getValueType();
  SDLoc DL(Addr);
  // if Address is FI, get the TargetFrameIndex.
  if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
    return false;
  }
  Base = Addr;
  Offset = CurDAG->getTargetConstant(0, DL, ValTy);
  return true;
}
```

And you need to notice that the definition of "SET" must be putted before the definition of "SB", cause the backend matches instructions in order of the sequence of definitions. If you need to generate more complex and custom instructions, you could try to add custom operations in "trySelect" function in class **ChinxDAGToDAGISel** as below,

```cpp
// -------------------------- //
//   ChinxISelDAGToDAG.cpp    //
// -------------------------- //
bool ChinxDAGToDAGISel::trySelect(SDNode *Node) {
  unsigned Opcode = Node->getOpcode();
  SDLoc DL(Node);
  EVT NodeTy = Node->getValueType(0);
  // Instruction Selection not handled by the auto-generated
  // tablegen selection should be handled here.
  switch (Opcode) {
  case ISD::MUL:
    // add your custom operations to handle the MUL DAG node
    // replace the node type by Chinx::NodeType, for example, Chinx::MULT
    // where MULT is defined in ChinxInstrInfo.td by def MULT : ...
  default:
    break;
  }
  return false;
}
```

To summarize this part, instruction selection will be done is *ChinxDAGToDAGISel.h* and *ChinxDAGToDAGISel.cpp*, completing the work to transfer DAG nodes to machine instruction. Actually, you can do optimization before the selection and after the selection, that means you can adjust instructions like combing several instructions to one instruction after selection. The concrete steps referred to https://llvm.org/docs.

The DAG nodes will be generated by class **ChinxTargetLowering** defined in *ChinxISelLowering.h* and *ChinxISelLowering.cpp*, if you do not have special needs, you can simply copy them and cut down some unnecessary code fragments from present MIPS or other CPUs.

### Subtarget

An instruction set can be parted to several subsets to make the back-end porting easy and efficient. Consider that ``Chinx`` is designed and implemented completely for two types, ``ChinxI`` and ``ChinxII``, and the latter one can support instruction "SET" while the former one can not. Need I generate two different compilers for them? Obviously, it is impracticable for that. Thus, the LLVM backend uses predicate to control the target instruction set by ``-mcpu=chinxI`` or ``-mcpu=chinxII``. To enable this function, we need to create predicating descriptions, and **ChinxSubtarget** is just like a version controller to manage current features of target machine.

```cpp
// --------------------- //
//      Chinx.td         //
// --------------------- //
def FeatureChinxI : SubtargetFeature<"chinxI", "ChinxArchVersion", 
	"ChinxI", "ChinxI ISA Support",[Feature_All]>;
def FeatureChinxII : SubtargetFeature<"chinxII", "ChinxArchVersion", 
	"ChinxII", "ChinxII ISA Support",[Feature_All, FeatureSet]>;
def : Proc<"chinxI", [FeatureChinxI]>; // enable the command paramters "-mcpu=chinxI"
def : Proc<"chinxII", [FeatureChinxII]>; // enable the command paramters "-mcpu=chinxII"
// ------------------------ // 
//     ChinxSubtarget.h     //
// ------------------------ //
class ChinxSubtarget : public ChinxGenSubtargetInfo {
public:
  enum ArchEnum { ChinxDefault, ChinxI, ChinxII };
protected:
  ArchEnum ChinxArchVersion;
public: // compatible with the tablegen descriptions
  bool hasChinxI() const { return ChinxArchVersion >= ChinxI; }
  bool isChinxI() const { return ChinxArchVersion == ChinxI; }
  bool hasChinxII() const { return ChinxArchVersion >= ChinxII; }
  bool isChinxII() const { return ChinxArchVersion == ChinxII; }
}
```

```mermaid
graph LR
A["ChinxTargetMachine"] --> B(("ChinxSubtargert"))
A --> C["ChinxABIInfo"]
B --> D["ChinxInstrInfo"] --> E["ChinxRegisterInfo"]
B --> F["ChinxFrameLowering"]
G["ChinxAsmPrinter"] --> B
G --> H["ChinxMCInstLower"]
```

### Assembly

The last stage of back-end porting is assembly printing, and it is easy to understand compared with the stages before. Since instruction selection and scheduling finished, this module only needs to translate each instruction as the comparable string, almost like string concatenation using substring described in *ChinxRegisterInfo.td* and *ChinxInstrInfo.td*. There are several source files we need to focus on.

```cpp
// -------------------- //
//   ChinxAsmPrinter.h  //
// -------------------- //
class LLVM_LIBRARY_VISIBILITY ChinxAsmPrinter : public AsmPrinter {
  void EmitInstruction(const MachineInstr *MI) override;
  void EmitFunctionEntryLabel() override;
  void EmitFunctionBodyStart() override;
  void EmitFunctionBodyEnd() override;
  void EmitStartOfAsmFile(Module &M) override;
}
```

Except method *EmitInstruction*, the other virtual methods are optional to describe the function info or assembly file info. *EmitInstruction* is necessary to rewrite to print each instructions. Some operands may need special display formats, and that can be done by **ChinxInstPrinter**, for example,

```cpp
// ------------------------- //
//      ChinxInstPrinter.h   //
// ------------------------- //
class ChinxInstPrinter : public MCInstPrinter {
private:
  void printMemOperand(const MCInst *MI, int opNum, raw_ostream &O);
};
// ------------------------- //
//    ChinxInstPrinter.cpp   //
// ------------------------- //
void ChinxInstPrinter::printMemOperand(const MCInst *MI, int opNum, raw_ostream &O) {
  // Load/Store memory operands -- imm($reg)
  printOperand(MI, opNum + 1, O);
  O << "(";
  printOperand(MI, opNum, O);
  O << ")";
}
```

For address operand, method *printMemOperand* would build format like "offset($register)". Actually this is a custom method not inherited, thus you should point out  the caller. In *ChinxInstrInfo.td*,

```cpp
// Load/Store and IO Address Operand
def mem : Operand<iPTR> {
    let PrintMethod = "printMemOperand";
    let MIOperandInfo = (ops MEMRegs, simm16);
    let EncoderMethod = "getMemEncoding";
}
```

bind the type "mem", which represents the memory address operand, and the printing method together. You should notice that "(ops MEMRegs, simm16)" points out that the first value represents the base register and the second is the offset, thus, the implementation of *printMemOperand* would print the value of "opNum + 1" first.

## Building

**Linux**

After untar the ``llvm-7.0.0.src.tar.xz``, rename the ``llvm-7.0.0.src`` directory as ``src`` and copy the untarred ``cfe-7.0.0.src.tar.xz`` directory, renamed as ``clang``, to ``src/tools``.

When these source files are already prepared, use ``cmake`` to build Makefiles and then build the clang and the llvm. You can run a bash like this,W

```bash
# in the directory where 'src' is
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCLANG_BUILD_EXAMPLES=ON -DLLVM_BUILD_EXAMPLES=ON -G "Unix Makefiles" ../src/
# -jn : n based on the number of processes on your computer
make -j4 -l4
```

After that, you can add ``build/bin`` to ``PATH``, then add all modified source files into ``src``, like ``src/CMakeLists.txt``, ``src/cmake/config-ix.cmake`` and so on. The rebuild the llvm by command ``cmake -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang -DCAMEK_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD=Chinx -G "Unix Makefiles" ../src/`` and ``make -j4 -l4`` to get the llvm compiler supporting ``Chinx``.

**Windows**

If you use ``visual studio`` as the development tool, can easily create a **CMake** project and write the configuration file like this,

```cmake
{
  "configurations": [
    {
      "name": "x64-Debug",
      "generator": "Ninja",
      "configurationType": "Debug",
      "inheritEnvironments": [
        "msvc_x64_x64"
      ],
      "buildRoot": "$BUILDROOT",
      "installRoot": "$INSTALLROOT",
      "cmakeCommandArgs": "-DLLVM_TARGETS_TO_BUILD=Chinx",
      "buildCommandArgs": "",
      "ctestCommandArgs": ""
    }
  ]
}
```

then generate cmake.

## Compilation and Test
We can use clang first transfer the ``*.c`` file to ``*.bc`` file, which described by LLVM IR, using command ``clang -target x86_64-pc-windows-msvc -c *.c -emit-llvm -o *.bc``. You can use ``llvm-dis`` tools to check the ``*.bc`` file by command ``llvm-dis *.bc -o -``. Finally, run command ``llc -march=chinx -relocation-model=pic -filetype=asm *.bc -o *.s`` and you will get the assembly description of ``*.cpp`` on the model machine which used the processor ``Chinx``.

Suppose that your input c source file is like this,

```c
// test.c
#define CTRL *((volatile char *)0x3)
int main() {
    CTRL = 4;
    char a = 5;
    char b = 6;
    int  c = a * b;
    int  d = 7;
    int  e = d + c;
    return 0;
}
```

Run **Clang** to generate the IR file,

```bash
# clang -v
# to check your target of host machine
clang -v
# my computer is
# clang version 7.0.0 (tags/RELEASE_700/final)
# Target: x86_64-pc-windows-msvc
# then generate IR code
clang -target x86_64-pc-windows-msvc -c test.c -emit-llvm -o test.bc
# the *.bc is binary file, you can check the details with the help of
# llvm-dis tool
llvm-dis test.bc -o -
# and the human-readable text will be displayed
# on your screen like this
# ...
# ; Function Attrs: noinline nounwind optnone uwtable
# define dso_local i32 @main() #0 {
#   %1 = alloca i32, align 4
#   %2 = alloca i8, align 1
#   %3 = alloca i8, align 1
#   %4 = alloca i32, align 4
#   %5 = alloca i32, align 4
#   %6 = alloca i32, align 4
#   store i32 0, i32* %1, align 4
#   store volatile i8 4, i8* inttoptr (i64 3 to i8*), align 1
#   store i8 5, i8* %2, align 1
#   store i8 6, i8* %3, align 1
#   %7 = load i8, i8* %2, align 1
#   %8 = sext i8 %7 to i32
#   %9 = load i8, i8* %3, align 1
#   %10 = sext i8 %9 to i32
#   %11 = mul nsw i32 %8, %10
#   store i32 %11, i32* %4, align 4
#   store i32 7, i32* %5, align 4
#   %12 = load i32, i32* %5, align 4
#   %13 = load i32, i32* %4, align 4
#   %14 = add nsw i32 %12, %13
#   store i32 %14, i32* %6, align 4
#   ret i32 0
# }
# ...
```

Before compiling the IR codes, we need check our supported target CPUs of LLVM.

```bash
llc --version
# you would get thes infos at least
#   LLVM version 7.0.0
#   Registered Targets:
#     chinx    - Chinx
# if the registered targets contain chinx, it would be ok
# we can use chinxI instruction set first, to see the difference
# with chinxII. chinxII supports SET instruction while chinxI does not
llc -march=chinx -mcpu=chinxI -relocation-model=pic -filetype=asm test.bc -o test.s
# you would get the following assembly codes
#         addi    $sp, $sp, -24
#         .cfi_def_cfa_offset 24
#         addi    $2, $zero, 0
#         sw      $2, 20($sp)
#         addi    $3, $zero, 3
#         addi    $4, $zero, 4
#         sb      $4, 0($3)
#         addi    $3, $zero, 5
#         sb      $3, 16($sp)
#         addi    $3, $zero, 6
#         sb      $3, 12($sp)
#         lb      $3, 16($sp)
#         lb      $4, 12($sp)
#         mul     $3, $3, $4
#         sw      $3, 8($sp)
#         addi    $3, $zero, 7
#         sw      $3, 4($sp)
#         lw      $3, 4($sp)
#         lw      $4, 8($sp)
#         add     $3, $3, $4
#         sw      $3, 0($sp)
#         addi    $sp, $sp, 24
#         ret     $ra
# now we set the -mcpu as chinxII
llc -march=chinx -mcpu=chinxII -relocation-model=pic -filetype=asm test.bc -o test.s
#         addi    $sp, $sp, -24
#         .cfi_def_cfa_offset 24
#         addi    $2, $zero, 0
#         sw      $2, 20($sp)
#         addi    $3, $zero, 3
#         addi    $4, $zero, 4
#         set     $4, 0($3)
#         addi    $3, $zero, 5
#         sb      $3, 16($sp)
#         addi    $3, $zero, 6
#         sb      $3, 12($sp)
#         lb      $3, 16($sp)
#         lb      $4, 12($sp)
#         mul     $3, $3, $4
#         sw      $3, 8($sp)
#         addi    $3, $zero, 7
#         sw      $3, 4($sp)
#         lw      $3, 4($sp)
#         lw      $4, 8($sp)
#         add     $3, $3, $4
#         sw      $3, 0($sp)
#         addi    $sp, $sp, 24
#         ret     $ra
```

To understand how the DAG nodes transferred to machine instructions, you should look the DAGs generated by LLVM, like this,

```bash
llc -view-isel-dags -march=chinx -mcpu=chinxII -relocation-model=pic -filetype=asm test.bc -o test.s
```

**Graphviz** application is needed, you can download and install it here: http://www.graphviz.org/download/.

The generated graph is a too large, and it can be checked here: https://github.com/ilo5u/CX-CPU/blob/master/pics/isel.pdf.
