//===-- ChinxInstrInfo.td - Target Description for Chinx Target -----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file describes the Chinx instructions in TableGen format.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Chinx profiles and nodes
//===----------------------------------------------------------------------===//
def SDT_ChinxRet : SDTypeProfile<0, 1, [SDTCisInt<0>]>;

def ChinxRet : SDNode<"ChinxISD::Ret", SDTNone, [
	SDNPHasChain, SDNPOptInGlue, SDNPVariadic
]>; // Return Node of Chinx [-view-sched-dags]

//===----------------------------------------------------------------------===//
// Feature predicates
//===----------------------------------------------------------------------===//
def Fe_1 :
	Predicate<"Subtarget->hasFeature_1()">,
	AssemblerPredicate<"Feature_1">; // add, addi, ret, lw, sw, jr
def Fe_2 :
	Predicate<"Subtarget->hasFeature_2()">,
	AssemblerPredicate<"Feature_2">; // sub, subi, or, ori, and, andi, xor, xori
def Fe_3 :
	Predicate<"Subtarget->hasFeature_3()">,
	AssemblerPredicate<"Feature_3">; // lh, lb, sh, sb, sll
def Fe_All :
	Predicate<"Subtarget->hasFeature_All()">,
	AssemblerPredicate<"Feature_All">; // mul

def EnableOverflow :
	Predicate<"Subtarget->enableOverflow()">; // link to ChinxSubtarget.h
def DisableOverflow :
	Predicate<"Subtarget->disableOverflow()">; // link to ChinxSubtarget.h
def HasSet :
	Predicate<"Subtarget->hasSet()">; // set, link to ChinxSubtarget.h

class ChinxInstAlias<string Asm, dag Result, bit Emit = 0b1> :
	InstAlias<Asm, Result, Emit>;

//===----------------------------------------------------------------------===//
// Instruction format superclass
//===----------------------------------------------------------------------===//

include "ChinxInstrFormats.td"

//===----------------------------------------------------------------------===//
// Chinx Operand, Complex Patterns and Transformations Definitions.
//===----------------------------------------------------------------------===//
// Instruction operand types
def simm16 : Operand<iPTR> {
    let DecoderMethod = "DecodeSimm16";
}
// Unsigned Operand
def uimm16 : Operand<i32> {
    let PrintMethod = "printUImm";
}
// Load/Store and IO Address Operand
def mem : Operand<iPTR> {
    let PrintMethod = "printMemOperand";
    let MIOperandInfo = (ops MEMRegs, simm16);
    let EncoderMethod = "getMemEncoding";
}

// Transformation Function - get the lower 16 bits.
def LO16 : SDNodeXForm<imm, [{
	return getImm(N, N->getZExtValue() & 0xFFFF);
}]>;
// Transformation Function - get the higher 16 bits.
def HI16 : SDNodeXForm<imm, [{
	return getImm(N, (N->getZExtValue() >> 16) & 0xFFFF);
}]>;

// Node immediate fits as 16-bit sign extended on target immediate.
// e.g. addi, andi
def immSExt16 : PatLeaf<(imm), [{ return isInt<16>(N->getSExtValue()); }]>;
// Node immediate fits as 16-bit unsign extended on target immediate.
// e.g. andi, ori
def immUExt16  : PatLeaf<(imm), [{
	if (N->getValueType(0) == MVT::i32)
		return (uint32_t)N->getZExtValue() == (uint16_t)N->getZExtValue();
	else
		return (uint64_t)N->getZExtValue() == (uint16_t)N->getZExtValue();
}], LO16>;
// imm field must fit in 5 bits.
def immUExt5 : ImmLeaf<i32, [{return Imm == (Imm & 0x1F);}]>;
// Immediate can be loaded with LUI (32-bit int with lower 16-bit cleared).
def immLow16Zero : PatLeaf<(imm), [{
	int64_t Val = N->getSExtValue();
	return isInt<32>(Val) && !(Val & 0xFFFF);
}]>;

// Chinx Address Mode! SDNode frameindex could possibily be a match
// since load and store instructions from stack used it.
def ADDRls :
	ComplexPattern<iPTR, 2, "SelectADDRls",
				   [frameindex], [SDNPWantParent]>;
// since io instructions used it.
def ADDRio :
	ComplexPattern<iPTR, 2, "SelectADDRio",
				   [], []>; // no frameindex cause the base is not $sp, $gp, $fp

//===----------------------------------------------------------------------===//
// Pattern fragment for load/store and io
//===----------------------------------------------------------------------===//

class AlignedLoad<PatFrag Node> :
    PatFrag<(ops node:$ptr), (Node node:$ptr), [{
        LoadSDNode *LD = cast<LoadSDNode>(N);
        return LD->getMemoryVT().getSizeInBits()/8 <= LD->getAlignment();
}]>;
class AlignedStore<PatFrag Node> :
    PatFrag<(ops node:$val, node:$ptr), (Node node:$val, node:$ptr), [{
        StoreSDNode *SD = cast<StoreSDNode>(N);
        return SD->getMemoryVT().getSizeInBits()/8 <= SD->getAlignment();
}]>;
def load32 : AlignedLoad<load>;
def loads16 : AlignedLoad<sextloadi16>;
def loadu16 : AlignedLoad<zextloadi16>;
def store32 : AlignedStore<store>;
def store16 : AlignedStore<truncstorei16>;

//===----------------------------------------------------------------------===//
// Instructions specific format
//===----------------------------------------------------------------------===//

let Predicates = [Fe_1] in {
// Arithmetic and logical instructions with 3 register operands.
class ArithLogicR<bits<6> op, string instr_asm, SDNode OpNode,
	InstrItinClass itin, RegisterClass RC, bit isComm = 0> :
	FR<op, (outs GPROut:$ra), (ins RC:$rb, RC:$rc),
		!strconcat(instr_asm, "\t$ra, $rb, $rc"),
		[(set GPROut:$ra, (OpNode RC:$rb, RC:$rc))], itin> {
	let reserved = 0;
	let isCommutable = isComm; // e.g. add rb rc =  add rc rb
	let isReMaterializable = 1;
}

// Arithmetic and logical instructions with 2 register operands and 1 immediate operand.
class ArithLogicI<bits<6> op, string instr_asm, SDNode OpNode, 
	Operand Od, PatLeaf imm_type, RegisterClass RC> :
	FI<op, (outs GPROut:$ra), (ins RC:$rb, Od:$imm16),
        !strconcat(instr_asm, "\t$ra, $rb, $imm16"),
        [(set GPROut:$ra, (OpNode RC:$rb, imm_type:$imm16))], IIAlu> {
	let isReMaterializable = 1;
}
// Feature_1
}

let Predicates = [Fe_2] in {
// Shifts
class ShiftI<bits<6> op, string instr_asm, SDNode OpNode,
	PatFrag PF, Operand ImmOpnd, RegisterClass RC> :
	FI<op, (outs GPROut:$ra), (ins RC:$rb, ImmOpnd:$imm16),
		!strconcat(instr_asm, "\t$ra, $rb, $imm16"),
		[(set GPROut:$ra, (OpNode RC:$rb, PF:$imm16))], IIAlu> {
}

// 32-bit shift instructions. e.g. sll $ra, $rb, imm5
class ShiftImm32<bits<6> op, string instr_asm, SDNode OpNode> :
	ShiftI<op, instr_asm, OpNode, immUExt5, uimm16, CPURegs>;

// Load Upper Imediate e.g. lui $ra, imm16
class LoadUpperI<bits<6> op, string instr_asm, RegisterClass RC, Operand Imm>:
	FI<op, (outs RC:$ra), (ins Imm:$imm16),
		!strconcat(instr_asm, "\t$ra, $imm16"), [], IIAlu> {
	let rb = 0;
	let isReMaterializable = 1;
}
// Feature_2
}

// Load/Store and IO specific instruction formats
class FMem<bits<6> op, dag outs, dag ins, string asmstr,
	list<dag> pattern, InstrItinClass itin> :
    FI<op, outs, ins, asmstr, pattern, itin> {
		bits<21> addr;
		let Inst{20-16} = addr{20-16};
		let Inst{15-0} = addr{15-0};
		let DecoderMethod = "DecodeMem";
}
let canFoldAsLoad = 1 in
class LoadM<bits<6> op, string instr_asm, PatFrag OpNode,
	RegisterClass RC, Operand MemOpnd, bit Pseudo> :
    FMem<op, (outs RC:$ra), (ins MemOpnd:$addr),
        !strconcat(instr_asm, "\t$ra, $addr"),
        [(set RC:$ra, (OpNode ADDRls:$addr))], IILoad> {
    let isPseudo = Pseudo;
}
class StoreM<bits<6> op, string instr_asm, PatFrag OpNode,
	RegisterClass RC, Operand MemOpnd, bit Pseudo> :
    FMem<op, (outs), (ins RC:$ra, MemOpnd:$addr),
        !strconcat(instr_asm, "\t$ra, $addr"),
        [(OpNode RC:$ra, ADDRls:$addr)], IIStore> {
    let isPseudo = Pseudo;
}
class SetPort<bits<6> op, string instr_asm, PatFrag OpNode,
	RegisterClass RC, Operand MemOpnd, bit Pseudo> :
	FMem<op, (outs), (ins RC:$ra, MemOpnd:$addr),
		!strconcat(instr_asm, "\t$ra, $addr"),
		[(OpNode RC:$ra, ADDRio:$addr)], IIStore> {
	let isPseudo = Pseudo;
}
multiclass LoadMemory<bits<6> op, string instr_asm, PatFrag OpNode, bit Pseudo = 0> {
    def #NAME# : LoadM<op, instr_asm, OpNode, GPROut, mem, Pseudo>;
}
multiclass StoreMemory<bits<6> op, string instr_asm, PatFrag OpNode, bit Pseudo = 0> {
    def #NAME# : StoreM<op, instr_asm, OpNode, CPURegs, mem, Pseudo>;
}
multiclass SetIO<bits<6> op, string instr_asm, PatFrag OpNode, bit Pseudo = 0> {
	def #NAME# : SetPort<op, instr_asm, OpNode, CPURegs, mem, Pseudo>;
}

// Branch specific instruction formats
let Predicates = [Fe_1] in {
let isBranch = 1, isTerminator = 1, isBarrier = 1, imm16 = 0, 
	hasDelaySlot = 1, isIndirectBranch = 1 in
class JumpRegister<bits<6> op, string instr_asm, RegisterClass RC> :
    FI<op, (outs), (ins RC:$ra),
        !strconcat(instr_asm, "\t$ra"), [(brind RC:$ra)], IIBranch> {
    let rb = 0;
    let imm16 = 0;
}
class RetBase<RegisterClass RC> : JumpRegister<0x21, "ret", RC> {
    let isReturn = 1;
    let isCodeGenOnly = 1;
    let hasCtrlDep = 1;
    let hasExtraSrcRegAllocReq = 1;
}
// Feature_1
}

//===----------------------------------------------------------------------===//
// Instruction definition
//===----------------------------------------------------------------------===//

/// Load/Store and IO instructions
let Predicates = [HasSet] in {
defm SET : SetIO<0x3E, "set", truncstorei8>;
}
let Predicates = [Fe_1] in {
defm LW : LoadMemory<0x31, "lw", load32>;
defm SW : StoreMemory<0x39, "sw", store32>;
}
let Predicates = [Fe_3] in {
defm LH : LoadMemory<0x32, "lh", loads16>;
defm LHU : LoadMemory<0x33, "lhu", loadu16>;
defm LB : LoadMemory<0x34, "lb", sextloadi8>;
defm LBU : LoadMemory<0x35, "lbu", zextloadi8>;
defm SH : StoreMemory<0x3A, "sh", store16>;
defm SB : StoreMemory<0x3B, "sb", truncstorei8>;
}
/// Arithmetic and Logic Instructions (3-Operand, R-Type, I-Type)
let Predicates = [Fe_1] in {
let Predicates = [DisableOverflow] in {
let addr = 0 in
def NOP : FJ<0x00, (outs), (ins), "nop", [], IIAlu>;
def ADD : ArithLogicR<0x02, "add", add, IIAlu, CPURegs, 1>;
def ADDI : ArithLogicI<0x09, "addi", add, simm16, immSExt16, CPURegs>;
}
}
let Predicates = [Fe_2] in {
let Predicates = [DisableOverflow] in {
def SUB : ArithLogicR<0x03, "sub", sub, IIAlu, CPURegs>;
def AND : ArithLogicR<0x05, "and", and, IIAlu, CPURegs>;
def OR : ArithLogicR<0x06, "or", or, IIAlu, CPURegs>;
def XOR : ArithLogicR<0x07, "xor", xor, IIAlu, CPURegs>;

def SUBI : ArithLogicI<0x0A, "subi", sub, simm16, immSExt16, CPURegs>;
def LUI : LoadUpperI<0x0F, "lui", GPROut, uimm16>;
def ORI : ArithLogicI<0x11, "ori", or, uimm16, immUExt16, CPURegs>;
def ANDI : ArithLogicI<0x12, "andi", and, uimm16, immUExt16, CPURegs>;
}
}
let Predicates = [Fe_All] in {
let Predicates = [DisableOverflow] in {
def MUL : ArithLogicR<0x04, "mul", mul, IIAlu, CPURegs, 1>;
}
}
/// Shift Instructions
let Predicates = [Fe_3] in {
def SLL : ShiftImm32<0x14, "sll", shl>;
def SRA : ShiftImm32<0x15, "sra", sra>;
def SRL : ShiftImm32<0x16, "srl", srl>;
}
let Predicates = [Fe_1] in {
def JR : JumpRegister<0x22, "jr", GPROut>;
let isReturn = 1, isTerminator = 1, hasDelaySlot = 1, isBarrier = 1, hasCtrlDep = 1 in
def RetRA : ChinxPseudo<(outs), (ins), "", [(ChinxRet)]>;

def RET : RetBase<CPURegs>;
}

let Predicates = [Fe_1] in {
//===----------------------------------------------------------------------===//
// Instruction aliases
//===----------------------------------------------------------------------===//
def : ChinxInstAlias<"mov $dst, $src", 
    (ADD GPROut:$dst, GPROut:$src,ZERO), 1>;
}

//===----------------------------------------------------------------------===//
//  Arbitrary patterns that map to one or more instructions
//===----------------------------------------------------------------------===//

// Small immediates
def : Pat<(i32 immSExt16:$in), (ADDI ZERO, imm:$in)>;
let Predicates = [Fe_1] in {
def : Pat<(i32 immUExt16:$in), (ORI ZERO, imm:$in)>;
def : Pat<(i32 immLow16Zero:$in), (LUI (HI16 imm:$in))>;

// Arbitrary immediates
def : Pat<(i32 imm:$imm), (ORI (LUI (HI16 imm:$imm)), (LO16 imm:$imm))>;
}
