<font face=Tahoma>

# 1 前言

本次课题主要利用本科阶段所学的知识，从工程实践的角度出发，设计并实现一个32位的模型机。该模型机能够在Basys3或ZNYQ系列的FPGA平台上正确运行，同时能够利用LLVM开源系统完成从C语言（子集）编写的高级语言程序到该模型机所支持的汇编代码的翻译过程。

## 1.1 实践背景

随着我国计算机技术的发展，“自主可控”芯片的设计与应用引起人们的广泛关注。目前所有处理器可分为RISC（Reduced Instruction Set Computing）处理器和CISC（Complex Instruction Set Computing）处理器这两大类，其中CISC处理器意为复杂指令集处理器，它强调通过单条指令实现复杂功能，主要利用微架构来进行指令调度的优化，如Intel公司x86体系下支持算术运算指令进行访存操作；而RISC处理器意为精简指令集处理器，它侧重于使单条指令实现的功能更加简短细化，可以让编译器承担更多优化指令调度的任务，其代表为ARM指令集架构。RISC技术在近几十年得到迅速发展，得益于其开发周期短、效率高，目前越来越多的处理器厂商都会引入RISC技术来进行优化。我国“龙芯”处理器就采用了基于RISC理念的MIPS指令集，目前它在MIPS64指令集的基础上修改并扩展出了上千条指令形成了LISA（LoongISA），但它使用的微架构完全由我国自主设计，因此它是完全自主可控的。除此之外，MIPS指令集目前已开源，非常适合用于高校教学与学习研究，也促进了其自身的发展。

当指令集不断更新迭代或者有新的指令集出现时，如何让应用程序运行在支持新一代指令集的处理器上就需要编译后端移植技术。编译器负责将适合人们编写和维护的高级语言转化成目标平台支持的机器语言，其流程包括词法分析、语法分析、语义分析、中间代码生成与优化以及目标代码生成，其中目标代码生成之前流程可与目标机器无关，而目标代码生成便需要目标机器的相关描述，同时这部分也称之为编译后端。目前主流的后端移植工具有GCC和LLVM，前者通过编译前端生成的暂存器传递语言生成目标代码，而LLVM主要利用TableGen技术完成目标机器的后端移植工作。相较于GCC晦涩难懂的后端架构体系，LLVM编译后端在技术上有着模块化设计的优势，它将寄存器分配、汇编码以及机器码的生成等操作全部以接口的形式呈现出来，对于后续移植工作提供了巨大的便利。

## 1.2 实践目的

本次课题重点在于指令集的微架构设计与实现以及编译后端移植技术的实现，介绍并分析编译后端的技术原理，为有相同需求的人员提供实例。同时该课题完成的模型机亦可用于高校实践教学，指导学生学习计算机组成原理、体系结构和编译原理等知识。

## 1.3 实践环境

OS: ``Windows 10`` Tools: ``Vivado 2018.3``

OS: ``Unbuntu 2016.6`` Tools: ``llvm 3.9.0``

## 1.4 文件说明

**sys**: 包含Chinx模型机的Verilog HDL源文件以及仿真文件

**backend**: 包含Chinx ISA的LLVM后端移植源文件

**pics**: 说明手册用图

**README.md**: 英文版说明手册

**README_CHS.md**: 中文版说明手册

# 2 Chinx模型机设计

为了构建一个完整的模型机系统，主要需要实现硬件电路和编译后端这两部分的内容。针对于硬件电路，如果从焊板子做起，那么开发效率过低，并且也不是本次课题所侧重的内容，因此可以从软件方式实现硬件电路的角度出发。利用Xilinx所提供的FPGA平台以及开发套件，通过Verilog HDL硬件描述语言，可以帮助我们快速地完成硬件电路的设计，同时用软件的方式还可便于进行仿真调试。

硬件电路是模型机的基础，而该模型机所支持的指令集体系结构则是其核心。目前本科教学中经常使用的是开源的MIPS指令集以及经典五段流水线架构，因此我们可以从MIPS指令集当中抽取部分指令并添加自定义的指令来构成Chinx模型机的指令集，指令集的具体内容见2.1小节。Chinx模型机对于经典五段流水线进行了调整，将译码和执行阶段合并成一个阶段，因此仅包含四段流水，其余调整的内容见2.2.3小节。

在构建完成模型机的底层电路之后，如何将易读的高级程序语言翻译成Chinx模型机所支持的汇编语言或机器语言，则需要借助编译系统。目前主流的编译器有GCC和LLVM，本次课题选择使用LLVM开源系统，因为其相较于前者可参考文献丰富、可读性更强，其后端实现代码主要为C++，因此移植工作主要是修改既定的接口函数即可，同时它设计了一套独特的TableGen工具来降低移植难度。

如上所述，实现Chinx模型机包含三个步骤：设计Chinx ISA（Instruction Set Architecture，指令集体系结构）、实现支持Chinx ISA的硬件电路和输入输出外围系统、完成Chinx ISA在LLVM的后端移植工作。

## 2.1 Chinx ISA

### 2.1.1 指令集

Chinx指令中的算数逻辑运算、访存、跳转和乘法指令的汇编格式参照MIPS32指令集快速参考手册<sup>[[5]]</sup>进行设计，而其编码格式由自己定义，除此之外的堆栈和函数调用指令全为自定义指令。

**指令类型**

**R型**：指令字长32位、操作码、最多三个寄存器操作数

| OP(6) | Ra(5) | Rb(5) | Rc(5) | Reserved(11) |
| ----- | ----- | ----- | ----- | ------------ |

**I型**：指令字长32位、操作码、最多两个寄存器操作数、一个立即数

| OP(6) | Ra(5) | Rb(5) | Imm(16)              |
| ----- | ----- | ----- | -------------------- |

**J型**：指令字长32位、操作码、地址码

| OP(6) | Address(26)                          |
| ----- | ------------------------------------ |

**指令格式**

1. 算术指令

|OP|Type|Fommat|Function|
|:-:|:-:|:-|:-|
|01|R|ADD  Ra, Rb, Rc|Ra = Rb + Rc|
|02|I|ADDI Ra, Rb, Imm16|Ra = Rb + Imm16|
|03|I|LUI  Ra, Imm16|Ra = (Imm16 << 16) &#124; 0xFFFF|

2. 移位指令

|OP|Type|Fommat|Function|
|:-:|:-:|:-|:-|
|04|I|SLL  Ra, Rb, Imm5|Ra = Rb << Imm5|

3. 逻辑指令

|OP|Type|Fommat|Function|
|:-:|:-:|:-|:-|
|00|R|NOP|No operation|
|05|I|ORI Ra, Rb, Imm16|Ra = Rb &#124; SignedExt32(Imm16)|

4. 跳转指令

|OP|Type|Fommat|Function|
|:-:|:-:|:-|:-|
|06|R|JR Ra|PC = Ra|

5. 访存指令

|OP|Type|Fommat|Function|
|:-:|:-:|:-|:-|
|07|I|LW Ra,Imm16(Rb)|Ra = MEM32(Rb + SignedExt32(Imm16))|
|08|I|SW Ra,Imm16(Rb)|MEM32(Rb + SignedExt32(Imm16)) = Ra|

6. 函数调用指令

|OP|Type|Fommat|Function|
|:-:|:-:|:-|:-|
|09|R|RET|PC = RA|

### 2.1.2 流水线

流水线的思想旨在并行执行，将一条指令完整的执行过程划分为K段，每一段用相互独立的功能单元执行特定的任务，那么K<sub>i</sub>和K<sub>j</sub>(i≠j)段的器件便能在空间和时间上同时运行。这样在执行连续的N条指令时，将大幅度缩短N条指令执行完毕所需要的时间。

![avatar](https://github.com/ilo5u/CX-CPU/blob/master/pics/ntask1.png)

<center>
    <font size=2>*图2.1.2.1 N条指令串行执行所用时间*</font>
</center>

经典五段流水线包含取指(IF)、译码(ID)、执行或有效地址(EX)、访存(MEM)和写回(WB)这五个阶段。

## 2.2 FPGA电路设计

### 2.2.1 顶层设计

### 2.2.2 模块化设计

## 2.3 LLVM编译后端设计

# 3 Chinx模型机实现

## 3.1 电路实现

## 3.2 编译后端实现

# 4 Chinx模型机测试

## 4.1 电路测试

## 4.2 编译后端测试

# 3 参考文献

[[1]] Chen Chung-Shu.TutorialLLVMBackend,Release 3.9.1,2018,<http://jonathan2251.github.io/lbd/>

[[2]] Writing an LLVM Backend,<https://llvm.org/docs/WritingAnLLVMBackend.html>

[[3]] TableGen,<http://llvm.org/docs/TableGen/index.html>

[[4]] The Design of a Custom 32-bit RISC CPU and LLVM Compiler Backend,<http://scholarworks.rit.edu/thesis>

[[5]]MIPS@32 ISA,MIPS32 Instruction Set Quick Reference v1.01,<https://www.mips.com/products/architectures/mips32-2/>

[1]: http://jonathan2251.github.io/lbd/
[2]: https://llvm.org/docs/WritingAnLLVMBackend.html
[3]: http://llvm.org/docs/TableGen/index.html
[4]: http://scholarworks.rit.edu/thesis
[5]: https://www.mips.com/products/architectures/mips32-2/

</font>