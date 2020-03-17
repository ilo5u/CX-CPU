def SDT_ChinxRet : SDTypeProfile<0, 1, [SDTCisInt<0>]>;

def ChinxRet : SDNode<"ChinxISD::Ret", SDTNone, [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

include "ChinxInstrFormats.td"

def simm16 : Operand<iPTR> {
    let DecoderMethod = "DecodeSimm16";
}

def mem : Operand<iPTR> {
    let PrintMethod = "printMemOperand";
    let MIOperandInfo = (ops CPURegs, simm16);
    let EncoderMethod = "getMemEncoding";
}

def immSExt16 : PatLeaf<(imm), [{ return isInt<16>(N->getSExtValue()); }]>;

def addr : ComplexPattern<iPTR, 2, "SelectAddr", [frameindex], [SDNPWantParent]>;

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

class ArithLogicI<bits<6> op, string instr_asm, SDNode OpNode, Operand Od, PatLeaf imm_type, RegisterClass RC> :
    FI<op, (outs GPROut:$ra), (ins RC:$rb, Od:$imm16),
        !strconcat(instr_asm, "\t$ra, $rb, $imm16"),
        [(set GPROut:$ra, (OpNode RC:$rb, imm_type:$imm16))], IIAlu> {
    let isReMaterializable = 1;
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

defm LW : LoadM32<0x22, "lw", load_a>;
defm SW : StoreM32<0x25, "sw", store_a>;

def ADDI : ArithLogicI<0x2A, "addi", add, simm16, immSExt16, CPURegs>;

def JR : JumpFI<0x1F, "jr", CPURegs>;

def RET : RetBase<CPURegs>;

let addr = 0 in
    def NOP : FJ<0, (outs), (ins), "nop", [], IIAlu>;

def : Pat<(i32 immSExt16:$in), (ADDI ZERO, imm:$in)>;

def Fe_1 : Predicate<"Subtarget->hasFe_1()">,
           AssemblerPredicate<"FEATURE_1">;
def Fe_2 : Predicate<"Subtarget->hasFe_2()">,
           AssemblerPredicate<"FEATURE_2">;
def Fe_3 : Predicate<"Subtarget->hasFe_3()">,
           AssemblerPredicate<"FEATURE_3">;
def Fe_ALL : Predicate<"Subtarget->hasFe_All()">,
           AssemblerPredicate<"FEATURE_ALL">;

def EnableOverflow : Predicate<"Subtarget->enableOverflow()">;
def DisableOverflow : Predicate<"Subtarget->disableOverflow()">;

def HasPush : Predicate<"Subtarget->hasPush()">;
def HasCall : Predicate<"Subtarget->hasCall()">;