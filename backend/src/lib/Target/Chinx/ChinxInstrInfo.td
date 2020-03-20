def SDT_ChinxRet : SDTypeProfile<0, 1, [SDTCisInt<0>]>;

def ChinxRet : SDNode<"ChinxISD::Ret", SDTNone, 
    [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

def Fe_1 : Predicate<"Subtarget->hasFeature_1()">,
           AssemblerPredicate<"Feature_1">;
def Fe_2 : Predicate<"Subtarget->hasFeature_2()">,
           AssemblerPredicate<"Feature_2">;
def Fe_3 : Predicate<"Subtarget->hasFeature_3()">,
           AssemblerPredicate<"Feature_3">;
def Fe_All : Predicate<"Subtarget->hasFeature_All()">,
           AssemblerPredicate<"Feature_All">;

def EnableOverflow : Predicate<"Subtarget->enableOverflow()">;
def DisableOverflow : Predicate<"Subtarget->disableOverflow()">;

def HasPush : Predicate<"Subtarget->hasPush()">;
def HasCall : Predicate<"Subtarget->hasCall()">;

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

// def shamt : Operand<i32>;

// Unsigned Operand
def uimm16 : Operand<i32> {
    let PrintMethod = "printUImm";
}

def mem : Operand<iPTR> {
    let PrintMethod = "printMemOperand";
    let MIOperandInfo = (ops CPURegs, simm16);
    let EncoderMethod = "getMemEncoding";
}

// Transformation Function - get the lower 16 bits.
def LO16 : SDNodeXForm<imm, [{
  return getImm(N, N->getZExtValue() & 0xffff);
}]>;

// Transformation Function - get the higher 16 bits.
def HI16 : SDNodeXForm<imm, [{
  return getImm(N, (N->getZExtValue() >> 16) & 0xffff);
}]>;

// Node immediate fits as 16-bit sign extended on target immediate.
// e.g. addi, andi
def immSExt16 : PatLeaf<(imm), [{ return isInt<16>(N->getSExtValue()); }]>;

// Node immediate fits as 16-bit zero extended on target immediate.
// The LO16 param means that only the lower 16 bits of the node
// immediate are caught.
// e.g. add
def immUExt16  : PatLeaf<(imm), [{
  if (N->getValueType(0) == MVT::i32)
    return (uint32_t)N->getZExtValue() == (unsigned short)N->getZExtValue();
  else
    return (uint64_t)N->getZExtValue() == (unsigned short)N->getZExtValue();
}], LO16>;

// Immediate can be loaded with LUi (32-bit int with lower 16-bit cleared).
def immLow16Zero : PatLeaf<(imm), [{
  int64_t Val = N->getSExtValue();
  return isInt<32>(Val) && !(Val & 0xffff);
}]>;

// imm field must fit in 5 bits.
def immUExt5 : ImmLeaf<i32, [{return Imm == (Imm & 0x1f);}]>;

// Cpu0 Address Mode! SDNode frameindex could possibily be a match
// since load and store instructions from stack used it.
def addr : ComplexPattern<iPTR, 2, "SelectAddr", [frameindex], [SDNPWantParent]>;

//===----------------------------------------------------------------------===//
// Pattern fragment for load/store
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

def load_a : AlignedLoad<load>;
def store_a : AlignedStore<store>;

//===----------------------------------------------------------------------===//
// Instructions specific format
//===----------------------------------------------------------------------===//

let Predicates = [Fe_1] in {
// Arithmetic and logical instructions with 3 register operands.
class ArithLogicR<bits<6> op, string instr_asm, SDNode OpNode,
                  InstrItinClass itin, RegisterClass RC, bit isComm = 0>:
  FR<op, (outs GPROut:$ra), (ins RC:$rb, RC:$rc),
     !strconcat(instr_asm, "\t$ra, $rb, $rc"),
     [(set GPROut:$ra, (OpNode RC:$rb, RC:$rc))], itin> {
  let reserved = 0;
  let isCommutable = isComm;	// e.g. add rb rc =  add rc rb
  let isReMaterializable = 1;
}
}

class ArithLogicI<bits<6> op, string instr_asm, SDNode OpNode, Operand Od, PatLeaf imm_type, RegisterClass RC> :
    FI<op, (outs GPROut:$ra), (ins RC:$rb, Od:$imm16),
        !strconcat(instr_asm, "\t$ra, $rb, $imm16"),
        [(set GPROut:$ra, (OpNode RC:$rb, imm_type:$imm16))], IIAlu> {
    let isReMaterializable = 1;
}

let Predicates = [Fe_1] in {
// Shifts
class ShiftLogicLeftI<bits<6> op, string instr_asm,
    SDNode OpNode, PatFrag PF, Operand ImmOpnd,
    RegisterClass RC>:
  FI<op, (outs GPROut:$ra), (ins RC:$rb, ImmOpnd:$imm16),
     !strconcat(instr_asm, "\t$ra, $rb, $imm16"),
     [(set GPROut:$ra, (OpNode RC:$rb, PF:$imm16))], IIAlu> {
}

// 32-bit shift instructions.
class ShiftLogicLeftI32<bits<6> op, string instr_asm, SDNode OpNode>:
  ShiftLogicLeftI<op, instr_asm, OpNode, immUExt5, uimm16, CPURegs>;
}

let Predicates = [Fe_1] in {
// Load Upper Imediate
class LoadUpperI<bits<6> op, string instr_asm, RegisterClass RC, Operand Imm>:
  FI<op, (outs RC:$ra), (ins Imm:$imm16),
     !strconcat(instr_asm, "\t$ra, $imm16"), [], IIAlu> {
  let rb = 0;
  let isReMaterializable = 1;
}
}

class FMem<bits<6> op, dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin> :
    FI<op, outs, ins, asmstr, pattern, itin> {
    bits<21> addr;
    let Inst{20-16} = addr{20-16};
    let Inst{15-0} = addr{15-0};
    let DecoderMethod = "DecodeMem";
}

let canFoldAsLoad = 1 in
class LoadM<bits<6> op, string instr_asm, PatFrag OpNode, RegisterClass RC, Operand MemOpnd, bit Pseudo> :
    FMem<op, (outs RC:$ra), (ins MemOpnd:$addr),
        !strconcat(instr_asm, "\t$ra, $addr"),
        [(set RC:$ra, (OpNode addr:$addr))], IILoad> {
    let isPseudo = Pseudo;
}

class StoreM<bits<6> op, string instr_asm, PatFrag OpNode, RegisterClass RC, Operand MemOpnd, bit Pseudo> :
    FMem<op, (outs), (ins RC:$ra, MemOpnd:$addr),
        !strconcat(instr_asm, "\t$ra, $addr"),
        [(OpNode RC:$ra, addr:$addr)], IIStore> {
    let isPseudo = Pseudo;
}

multiclass LoadM32<bits<6> op, string instr_asm, PatFrag OpNode, bit Pseudo = 0> {
    def #NAME# : LoadM<op, instr_asm, OpNode, GPROut, mem, Pseudo>;
}

multiclass StoreM32<bits<6> op, string instr_asm, PatFrag OpNode, bit Pseudo = 0> {
    def #NAME# : StoreM<op, instr_asm, OpNode, CPURegs, mem, Pseudo>;
}

let isBranch = 1, isTerminator = 1, isBarrier = 1, imm16 = 0, hasDelaySlot = 1, isIndirectBranch = 1 in
class JumpFI<bits<6> op, string instr_asm, RegisterClass RC> :
    FI<op, (outs), (ins RC:$ra),
        !strconcat(instr_asm, "\t$ra"), [(brind RC:$ra)], IIBranch> {
    let rb = 0;
    let imm16 = 0;
}

class RetBase<RegisterClass RC> : JumpFI<0x28, "ret", RC> {
    let isReturn = 1;
    let isCodeGenOnly = 1;
    let hasCtrlDep = 1;
    let hasExtraSrcRegAllocReq = 1;
}

//===----------------------------------------------------------------------===//
// Instruction definition
//===----------------------------------------------------------------------===//

defm LW : LoadM32<0x22, "lw", load_a>;
defm SW : StoreM32<0x25, "sw", store_a>;

def ADDI : ArithLogicI<0x2A, "addi", add, simm16, immSExt16, CPURegs>;

let Predicates = [Fe_1] in {
def ORI : ArithLogicI<0x0d, "ori", or, uimm16, immUExt16, CPURegs>;
def LUI : LoadUpperI<0x0f, "lui", GPROut, uimm16>;
}

/// Arithmetic Instructions (3-Operand, R-Type)
let Predicates = [Fe_1] in {
let Predicates = [DisableOverflow] in {
def ADD : ArithLogicR<0x11, "add", add, IIAlu, CPURegs, 1>;
}
}

/// Shift Instructions
let Predicates = [Fe_1] in {
def SHL : ShiftLogicLeftI32<0x1e, "shl", shl>;
}

def JR : JumpFI<0x1F, "jr", GPROut>;

let Predicates = [Fe_1] in {
    let isReturn = 1, isTerminator = 1, hasDelaySlot = 1, isBarrier = 1, hasCtrlDep = 1 in
    def RetRA : ChinxPseudo<(outs), (ins), "", [(ChinxRet)]>;
}

def RET : RetBase<CPURegs>;

let addr = 0 in
    def NOP : FJ<0, (outs), (ins), "nop", [], IIAlu>;

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