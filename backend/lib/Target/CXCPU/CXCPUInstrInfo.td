//===- CXCPUInstrInfo.td - Target Description for CXCPU Target -*- tablegen -*-=//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the CXCPU implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
// CXCPU profiles and nodes
//===----------------------------------------------------------------------===//

def SDT_CXCPURet  : SDTypeProfile<0, 1, [SDTCisInt<0>]>;

// Return
def CXCPURet : SDNode<"CXCPUISD::Ret", SDTNone,
                      [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

//===----------------------------------------------------------------------===//
// Instruction format superclass
//===----------------------------------------------------------------------===//

include "CXCPUInstrFormats.td"

//===----------------------------------------------------------------------===//
// CXCPU Operand, Complex Patterns and Transformations Definitions.
//===----------------------------------------------------------------------===//
// Instruction operand types

// Signed Immediate Operand
def simm16      : Operand<i32> {
  let DecoderMethod= "DecodeSimm16";
}

// Address operand
def mem : Operand<iPTR> {
  let PrintMethod   = "printMemOperand";
  let MIOperandInfo = (ops CXCPUGPRRegs, simm16);
  let EncoderMethod = "getMemEncoding";
}

// Node immediate fits as 16-bit sign extended on target immediate.
// e.g. addi, andi
def immSExt16  : PatLeaf<(imm), [{ return isInt<16>(N->getSExtValue()); }]>;

// CXCPU Address Mode! SDNode frameindex could possibily be a match
// since load and store instructions from stack used it.
def addr :
  ComplexPattern<iPTR, 2, "selectIntAddr", [frameindex], [SDNPWantParent]>;

//===----------------------------------------------------------------------===//
// Pattern fragment for load/store
//===----------------------------------------------------------------------===//

class AlignedLoad<PatFrag Node> :
  PatFrag<(ops node:$ptr), (Node node:$ptr), [{
  LoadSDNode *LD = cast<LoadSDNode>(N);
  return LD-getMemoryVT().getSizeInBits()/8 <= LD->getAlignment();
}]>;

class AlignedStore<PatFrag Node> :
  PatFrag<(ops node:$val, node:$ptr), (Node node:$val, node:$ptr), [{
  StoreSDNode *SD = cast<StoreSDNode>(N);
  return SD->getMemoryVT().getSizeInBits()/8 <= SD->getAlignment();
}]>;

// Load/Store PatFrags.
def load_a  : AlignedLoad<load>;
def store_a : AlignedStore<store>;

//===----------------------------------------------------------------------===//
// Instructions specific format
//===----------------------------------------------------------------------===//

// Arithmetic and logical instructions with 3 register operands.
class ArithLogicR<string opstr, RegisterOperand RO, bit isComm = 0,
                  InstrItinClass Itin = NoItinerary,
                  SDPatternOperator OpNode = null_frag>:
  InstSE<(outs RO:$rd), (ins RO:$rs, RO:$rt),
         !strconcat(opstr, "\t$rd, $rs, $rt"),
         [(set RO:$rd, (OpNode RO:$rs, RO:$rt))], Itin, FrmR, opstr> {
  let isCommutable = isComm;
  let isReMaterializable = 1;
  let TwoOperandAliasConstraint = "$rd = $rs";
}

// Arithmetic and logical instructions with 2 register operands.
class ArithLogicI<string opstr, Operand Od, RegisterOperand RO,
                  InstrItinClass Itin = NoItinerary,
                  SDPatternOperator imm_type = null_frag,
                  SDPatternOperator OpNode = null_frag> :
  InstSE<(outs RO:$rt), (ins RO:$rs, Od:$imm16),
         !strconcat(opstr, "\t$rt, $rs, $imm16"),
         [(set RO:$rt, (OpNode RO:$rs, imm_type:$imm16))],
         Itin, FrmI, opstr> {
  let isReMaterializable = 1;
  let TwoOperandAliasConstraint = "$rs = $rt";
}

// Arithmetic Multiply ADD/SUB
class MArithR<string opstr, InstrItinClass itin, bit isComm = 0> :
  InstSE<(outs), (ins GPR32Opnd:$rs, GPR32Opnd:$rt),
         !strconcat(opstr, "\t$rs, $rt"), [], itin, FrmR, opstr> {
  let Defs = [HI0, LO0];
  let Uses = [HI0, LO0];
  let isCommutable = isComm;
}

//  Logical
class LogicNOR<string opstr, RegisterOperand RO>:
  InstSE<(outs RO:$rd), (ins RO:$rs, RO:$rt),
         !strconcat(opstr, "\t$rd, $rs, $rt"),
         [(set RO:$rd, (not (or RO:$rs, RO:$rt)))], II_NOR, FrmR, opstr> {
  let isCommutable = 1;
}

// Shifts
class shift_rotate_imm<string opstr, Operand ImmOpnd,
                       RegisterOperand RO, InstrItinClass itin,
                       SDPatternOperator OpNode = null_frag,
                       SDPatternOperator PF = null_frag> :
  InstSE<(outs RO:$rd), (ins RO:$rt, ImmOpnd:$shamt),
         !strconcat(opstr, "\t$rd, $rt, $shamt"),
         [(set RO:$rd, (OpNode RO:$rt, PF:$shamt))], itin, FrmR, opstr> {
  let TwoOperandAliasConstraint = "$rt = $rd";
}

class shift_rotate_reg<string opstr, RegisterOperand RO, InstrItinClass itin,
                       SDPatternOperator OpNode = null_frag>:
  InstSE<(outs RO:$rd), (ins RO:$rt, GPR32Opnd:$rs),
         !strconcat(opstr, "\t$rd, $rt, $rs"),
         [(set RO:$rd, (OpNode RO:$rt, GPR32Opnd:$rs))], itin, FrmR,
         opstr>;

// Load Upper Imediate
class LoadUpper<string opstr, RegisterOperand RO, Operand Imm>:
  InstSE<(outs RO:$rt), (ins Imm:$imm16), !strconcat(opstr, "\t$rt, $imm16"),
         [], II_LUI, FrmI, opstr>, IsAsCheapAsAMove {
  let hasSideEffects = 0;
  let isReMaterializable = 1;
}

// Memory Load/Store
class Load<string opstr, DAGOperand RO, SDPatternOperator OpNode = null_frag,
           InstrItinClass Itin = NoItinerary, ComplexPattern Addr = addr> :
  InstSE<(outs RO:$rt), (ins mem:$addr), !strconcat(opstr, "\t$rt, $addr"),
         [(set RO:$rt, (OpNode Addr:$addr))], Itin, FrmI, opstr> {
  let DecoderMethod = "DecodeMem";
  let canFoldAsLoad = 1;
  let mayLoad = 1;
}

class Store<string opstr, DAGOperand RO, SDPatternOperator OpNode = null_frag,
            InstrItinClass Itin = NoItinerary, ComplexPattern Addr = addr> :
  InstSE<(outs), (ins RO:$rt, mem:$addr), !strconcat(opstr, "\t$rt, $addr"),
         [(OpNode RO:$rt, Addr:$addr)], Itin, FrmI, opstr> {
  let DecoderMethod = "DecodeMem";
  let mayStore = 1;
}

// Load/Store Left/Right
let canFoldAsLoad = 1 in
class LoadLeftRight<string opstr, SDNode OpNode, RegisterOperand RO,
                    InstrItinClass Itin> :
  InstSE<(outs RO:$rt), (ins mem:$addr, RO:$src),
         !strconcat(opstr, "\t$rt, $addr"),
         [(set RO:$rt, (OpNode addr:$addr, RO:$src))], Itin, FrmI> {
  let DecoderMethod = "DecodeMem";
  string Constraints = "$src = $rt";
}

class StoreLeftRight<string opstr, SDNode OpNode, RegisterOperand RO,
                     InstrItinClass Itin> :
  InstSE<(outs), (ins RO:$rt, mem:$addr), !strconcat(opstr, "\t$rt, $addr"),
         [(OpNode RO:$rt, addr:$addr)], Itin, FrmI> {
  let DecoderMethod = "DecodeMem";
}

// COP2 Load/Store
class LW_FT2<string opstr, RegisterOperand RC, InstrItinClass Itin,
             SDPatternOperator OpNode= null_frag> :
  InstSE<(outs RC:$rt), (ins mem:$addr), !strconcat(opstr, "\t$rt, $addr"),
         [(set RC:$rt, (OpNode addrDefault:$addr))], Itin, FrmFI, opstr> {
  let DecoderMethod = "DecodeFMem2";
  let mayLoad = 1;
}

class SW_FT2<string opstr, RegisterOperand RC, InstrItinClass Itin,
             SDPatternOperator OpNode= null_frag> :
  InstSE<(outs), (ins RC:$rt, mem:$addr), !strconcat(opstr, "\t$rt, $addr"),
         [(OpNode RC:$rt, addrDefault:$addr)], Itin, FrmFI, opstr> {
  let DecoderMethod = "DecodeFMem2";
  let mayStore = 1;
}

// COP3 Load/Store
class LW_FT3<string opstr, RegisterOperand RC, InstrItinClass Itin,
             SDPatternOperator OpNode= null_frag> :
  InstSE<(outs RC:$rt), (ins mem:$addr), !strconcat(opstr, "\t$rt, $addr"),
         [(set RC:$rt, (OpNode addrDefault:$addr))], Itin, FrmFI, opstr> {
  let DecoderMethod = "DecodeFMem3";
  let mayLoad = 1;
}

class SW_FT3<string opstr, RegisterOperand RC, InstrItinClass Itin,
             SDPatternOperator OpNode= null_frag> :
  InstSE<(outs), (ins RC:$rt, mem:$addr), !strconcat(opstr, "\t$rt, $addr"),
         [(OpNode RC:$rt, addrDefault:$addr)], Itin, FrmFI, opstr> {
  let DecoderMethod = "DecodeFMem3";
  let mayStore = 1;
}

// Conditional Branch
class CBranch<string opstr, DAGOperand opnd, PatFrag cond_op,
              RegisterOperand RO, bit DelaySlot = 1> :
  InstSE<(outs), (ins RO:$rs, RO:$rt, opnd:$offset),
         !strconcat(opstr, "\t$rs, $rt, $offset"),
         [(brcond (i32 (cond_op RO:$rs, RO:$rt)), bb:$offset)], IIBranch,
         FrmI, opstr> {
  let isBranch = 1;
  let isTerminator = 1;
  let hasDelaySlot = DelaySlot;
  let Defs = [AT];
}

class CBranchZero<string opstr, DAGOperand opnd, PatFrag cond_op,
                  RegisterOperand RO, bit DelaySlot = 1> :
  InstSE<(outs), (ins RO:$rs, opnd:$offset),
         !strconcat(opstr, "\t$rs, $offset"),
         [(brcond (i32 (cond_op RO:$rs, 0)), bb:$offset)], IIBranch,
         FrmI, opstr> {
  let isBranch = 1;
  let isTerminator = 1;
  let hasDelaySlot = DelaySlot;
  let Defs = [AT];
}

// SetCC
class SetCC_R<string opstr, PatFrag cond_op, RegisterOperand RO> :
  InstSE<(outs GPR32Opnd:$rd), (ins RO:$rs, RO:$rt),
         !strconcat(opstr, "\t$rd, $rs, $rt"),
         [(set GPR32Opnd:$rd, (cond_op RO:$rs, RO:$rt))],
         II_SLT_SLTU, FrmR, opstr>;

class SetCC_I<string opstr, PatFrag cond_op, Operand Od, PatLeaf imm_type,
              RegisterOperand RO>:
  InstSE<(outs GPR32Opnd:$rt), (ins RO:$rs, Od:$imm16),
         !strconcat(opstr, "\t$rt, $rs, $imm16"),
         [(set GPR32Opnd:$rt, (cond_op RO:$rs, imm_type:$imm16))],
         II_SLTI_SLTIU, FrmI, opstr>;

// Jump
class JumpFJ<DAGOperand opnd, string opstr, SDPatternOperator operator,
             SDPatternOperator targetoperator, string bopstr> :
  InstSE<(outs), (ins opnd:$target), !strconcat(opstr, "\t$target"),
         [(operator targetoperator:$target)], IIBranch, FrmJ, bopstr> {
  let isTerminator=1;
  let isBarrier=1;
  let hasDelaySlot = 1;
  let DecoderMethod = "DecodeJumpTarget";
  let Defs = [AT];
}

// Unconditional branch
class UncondBranch<Instruction BEQInst> :
  PseudoSE<(outs), (ins brtarget:$offset), [(br bb:$offset)], IIBranch>,
  PseudoInstExpansion<(BEQInst ZERO, ZERO, brtarget:$offset)> {
  let isBranch = 1;
  let isTerminator = 1;
  let isBarrier = 1;
  let hasDelaySlot = 1;
  let AdditionalPredicates = [RelocPIC];
  let Defs = [AT];
}

// Base class for indirect branch and return instruction classes.
let isTerminator=1, isBarrier=1, hasDelaySlot = 1 in
class JumpFR<string opstr, RegisterOperand RO,
             SDPatternOperator operator = null_frag>:
  InstSE<(outs), (ins RO:$rs), "jr\t$rs", [(operator RO:$rs)], IIBranch,
         FrmR, opstr>;

// Indirect branch
class IndirectBranch<string opstr, RegisterOperand RO> : JumpFR<opstr, RO> {
  let isBranch = 1;
  let isIndirectBranch = 1;
}

// Jump and Link (Call)
let isCall=1, hasDelaySlot=1, Defs = [RA] in {
  class JumpLink<string opstr, DAGOperand opnd> :
    InstSE<(outs), (ins opnd:$target), !strconcat(opstr, "\t$target"),
           [(CXCPUJmpLink imm:$target)], IIBranch, FrmJ, opstr> {
    let DecoderMethod = "DecodeJumpTarget";
  }

  class JumpLinkRegPseudo<RegisterOperand RO, Instruction JALRInst,
                          Register RetReg, RegisterOperand ResRO = RO>:
    PseudoSE<(outs), (ins RO:$rs), [(CXCPUJmpLink RO:$rs)], IIBranch>,
    PseudoInstExpansion<(JALRInst RetReg, ResRO:$rs)>;

  class JumpLinkReg<string opstr, RegisterOperand RO>:
    InstSE<(outs RO:$rd), (ins RO:$rs), !strconcat(opstr, "\t$rd, $rs"),
           [], IIBranch, FrmR>;

  class BGEZAL_FT<string opstr, DAGOperand opnd,
                  RegisterOperand RO, bit DelaySlot = 1> :
    InstSE<(outs), (ins RO:$rs, opnd:$offset),
           !strconcat(opstr, "\t$rs, $offset"), [], IIBranch, FrmI, opstr> {
    let hasDelaySlot = DelaySlot;
  }

}

let isCall = 1, isTerminator = 1, isReturn = 1, isBarrier = 1, hasDelaySlot = 1,
    hasExtraSrcRegAllocReq = 1, Defs = [AT] in {
  class TailCall<Instruction JumpInst> :
    PseudoSE<(outs), (ins calltarget:$target), [], IIBranch>,
    PseudoInstExpansion<(JumpInst jmptarget:$target)>;

  class TailCallReg<RegisterOperand RO, Instruction JRInst,
                    RegisterOperand ResRO = RO> :
    PseudoSE<(outs), (ins RO:$rs), [(CXCPUTailCall RO:$rs)], IIBranch>,
    PseudoInstExpansion<(JRInst ResRO:$rs)>;
}

class BAL_BR_Pseudo<Instruction RealInst> :
  PseudoSE<(outs), (ins brtarget:$offset), [], IIBranch>,
  PseudoInstExpansion<(RealInst ZERO, brtarget:$offset)> {
  let isBranch = 1;
  let isTerminator = 1;
  let isBarrier = 1;
  let hasDelaySlot = 1;
  let Defs = [RA];
}

// Syscall
class SYS_FT<string opstr> :
  InstSE<(outs), (ins uimm20:$code_),
         !strconcat(opstr, "\t$code_"), [], NoItinerary, FrmI, opstr>;
// Break
class BRK_FT<string opstr> :
  InstSE<(outs), (ins uimm10:$code_1, uimm10:$code_2),
         !strconcat(opstr, "\t$code_1, $code_2"), [], NoItinerary,
         FrmOther, opstr>;

// (D)Eret
class ER_FT<string opstr> :
  InstSE<(outs), (ins),
         opstr, [], NoItinerary, FrmOther, opstr>;

// Interrupts
class DEI_FT<string opstr, RegisterOperand RO> :
  InstSE<(outs RO:$rt), (ins),
         !strconcat(opstr, "\t$rt"), [], NoItinerary, FrmOther, opstr>;

// Wait
class WAIT_FT<string opstr> :
  InstSE<(outs), (ins), opstr, [], NoItinerary, FrmOther, opstr>;

// Sync
let hasSideEffects = 1 in
class SYNC_FT<string opstr> :
  InstSE<(outs), (ins i32imm:$stype), "sync $stype", [(CXCPUSync imm:$stype)],
         NoItinerary, FrmOther, opstr>;

class SYNCI_FT<string opstr> :
  InstSE<(outs), (ins mem_simm16:$addr), !strconcat(opstr, "\t$addr"), [],
         NoItinerary, FrmOther, opstr> {
  let hasSideEffects = 1;
  let DecoderMethod = "DecodeSyncI";
}

let hasSideEffects = 1 in
class TEQ_FT<string opstr, RegisterOperand RO> :
  InstSE<(outs), (ins RO:$rs, RO:$rt, uimm16:$code_),
         !strconcat(opstr, "\t$rs, $rt, $code_"), [], NoItinerary,
         FrmI, opstr>;

class TEQI_FT<string opstr, RegisterOperand RO> :
  InstSE<(outs), (ins RO:$rs, uimm16:$imm16),
         !strconcat(opstr, "\t$rs, $imm16"), [], NoItinerary, FrmOther, opstr>;
// Mul, Div
class Mult<string opstr, InstrItinClass itin, RegisterOperand RO,
           list<Register> DefRegs> :
  InstSE<(outs), (ins RO:$rs, RO:$rt), !strconcat(opstr, "\t$rs, $rt"), [],
         itin, FrmR, opstr> {
  let isCommutable = 1;
  let Defs = DefRegs;
  let hasSideEffects = 0;
}

// Pseudo multiply/divide instruction with explicit accumulator register
// operands.
class MultDivPseudo<Instruction RealInst, RegisterClass R0, RegisterOperand R1,
                    SDPatternOperator OpNode, InstrItinClass Itin,
                    bit IsComm = 1, bit HasSideEffects = 0,
                    bit UsesCustomInserter = 0> :
  PseudoSE<(outs R0:$ac), (ins R1:$rs, R1:$rt),
           [(set R0:$ac, (OpNode R1:$rs, R1:$rt))], Itin>,
  PseudoInstExpansion<(RealInst R1:$rs, R1:$rt)> {
  let isCommutable = IsComm;
  let hasSideEffects = HasSideEffects;
  let usesCustomInserter = UsesCustomInserter;
}

// Pseudo multiply add/sub instruction with explicit accumulator register
// operands.
class MAddSubPseudo<Instruction RealInst, SDPatternOperator OpNode,
                    InstrItinClass itin>
  : PseudoSE<(outs ACC64:$ac),
             (ins GPR32Opnd:$rs, GPR32Opnd:$rt, ACC64:$acin),
             [(set ACC64:$ac,
              (OpNode GPR32Opnd:$rs, GPR32Opnd:$rt, ACC64:$acin))],
             itin>,
    PseudoInstExpansion<(RealInst GPR32Opnd:$rs, GPR32Opnd:$rt)> {
  string Constraints = "$acin = $ac";
}

class Div<string opstr, InstrItinClass itin, RegisterOperand RO,
          list<Register> DefRegs> :
  InstSE<(outs), (ins RO:$rs, RO:$rt), !strconcat(opstr, "\t$$zero, $rs, $rt"),
         [], itin, FrmR, opstr> {
  let Defs = DefRegs;
}

// Move from Hi/Lo
class PseudoMFLOHI<RegisterClass DstRC, RegisterClass SrcRC, SDNode OpNode>
  : PseudoSE<(outs DstRC:$rd), (ins SrcRC:$hilo),
             [(set DstRC:$rd, (OpNode SrcRC:$hilo))], II_MFHI_MFLO>;

class MoveFromLOHI<string opstr, RegisterOperand RO, Register UseReg>:
  InstSE<(outs RO:$rd), (ins), !strconcat(opstr, "\t$rd"), [], II_MFHI_MFLO,
         FrmR, opstr> {
  let Uses = [UseReg];
  let hasSideEffects = 0;
}

class PseudoMTLOHI<RegisterClass DstRC, RegisterClass SrcRC>
  : PseudoSE<(outs DstRC:$lohi), (ins SrcRC:$lo, SrcRC:$hi),
             [(set DstRC:$lohi, (CXCPUMTLOHI SrcRC:$lo, SrcRC:$hi))],
             II_MTHI_MTLO>;

class MoveToLOHI<string opstr, RegisterOperand RO, list<Register> DefRegs>:
  InstSE<(outs), (ins RO:$rs), !strconcat(opstr, "\t$rs"), [], II_MTHI_MTLO,
  FrmR, opstr> {
  let Defs = DefRegs;
  let hasSideEffects = 0;
}

class EffectiveAddress<string opstr, RegisterOperand RO> :
  InstSE<(outs RO:$rt), (ins mem_ea:$addr), !strconcat(opstr, "\t$rt, $addr"),
         [(set RO:$rt, addr:$addr)], NoItinerary, FrmI,
         !strconcat(opstr, "_lea")> {
  let isCodeGenOnly = 1;
  let DecoderMethod = "DecodeMem";
}

// Count Leading Ones/Zeros in Word
class CountLeading0<string opstr, RegisterOperand RO>:
  InstSE<(outs RO:$rd), (ins RO:$rs), !strconcat(opstr, "\t$rd, $rs"),
         [(set RO:$rd, (ctlz RO:$rs))], II_CLZ, FrmR, opstr>;

class CountLeading1<string opstr, RegisterOperand RO>:
  InstSE<(outs RO:$rd), (ins RO:$rs), !strconcat(opstr, "\t$rd, $rs"),
         [(set RO:$rd, (ctlz (not RO:$rs)))], II_CLO, FrmR, opstr>;

// Sign Extend in Register.
class SignExtInReg<string opstr, ValueType vt, RegisterOperand RO,
                   InstrItinClass itin> :
  InstSE<(outs RO:$rd), (ins RO:$rt), !strconcat(opstr, "\t$rd, $rt"),
         [(set RO:$rd, (sext_inreg RO:$rt, vt))], itin, FrmR, opstr>;

// Subword Swap
class SubwordSwap<string opstr, RegisterOperand RO>:
  InstSE<(outs RO:$rd), (ins RO:$rt), !strconcat(opstr, "\t$rd, $rt"), [],
         NoItinerary, FrmR, opstr> {
  let hasSideEffects = 0;
}

// Read Hardware
class ReadHardware<RegisterOperand CPURegOperand, RegisterOperand RO> :
  InstSE<(outs CPURegOperand:$rt), (ins RO:$rd), "rdhwr\t$rt, $rd", [],
         II_RDHWR, FrmR, "rdhwr">;

// Ext and Ins
class ExtBase<string opstr, RegisterOperand RO, Operand PosOpnd,
              SDPatternOperator Op = null_frag>:
  InstSE<(outs RO:$rt), (ins RO:$rs, PosOpnd:$pos, size_ext:$size),
         !strconcat(opstr, " $rt, $rs, $pos, $size"),
         [(set RO:$rt, (Op RO:$rs, imm:$pos, imm:$size))], II_EXT,
         FrmR, opstr>, ISA_CXCPU32R2;

class InsBase<string opstr, RegisterOperand RO, Operand PosOpnd,
              SDPatternOperator Op = null_frag>:
  InstSE<(outs RO:$rt), (ins RO:$rs, PosOpnd:$pos, size_ins:$size, RO:$src),
         !strconcat(opstr, " $rt, $rs, $pos, $size"),
         [(set RO:$rt, (Op RO:$rs, imm:$pos, imm:$size, RO:$src))],
         II_INS, FrmR, opstr>, ISA_CXCPU32R2 {
  let Constraints = "$src = $rt";
}

// Atomic instructions with 2 source operands (ATOMIC_SWAP & ATOMIC_LOAD_*).
class Atomic2Ops<PatFrag Op, RegisterClass DRC> :
  PseudoSE<(outs DRC:$dst), (ins PtrRC:$ptr, DRC:$incr),
           [(set DRC:$dst, (Op iPTR:$ptr, DRC:$incr))]>;

// Atomic Compare & Swap.
class AtomicCmpSwap<PatFrag Op, RegisterClass DRC> :
  PseudoSE<(outs DRC:$dst), (ins PtrRC:$ptr, DRC:$cmp, DRC:$swap),
           [(set DRC:$dst, (Op iPTR:$ptr, DRC:$cmp, DRC:$swap))]>;

class LLBase<string opstr, RegisterOperand RO> :
  InstSE<(outs RO:$rt), (ins mem:$addr), !strconcat(opstr, "\t$rt, $addr"),
         [], NoItinerary, FrmI> {
  let DecoderMethod = "DecodeMem";
  let mayLoad = 1;
}

class SCBase<string opstr, RegisterOperand RO> :
  InstSE<(outs RO:$dst), (ins RO:$rt, mem:$addr),
         !strconcat(opstr, "\t$rt, $addr"), [], NoItinerary, FrmI> {
  let DecoderMethod = "DecodeMem";
  let mayStore = 1;
  let Constraints = "$rt = $dst";
}

class MFC3OP<string asmstr, RegisterOperand RO, RegisterOperand RD> :
  InstSE<(outs RO:$rt), (ins RD:$rd, uimm16:$sel),
         !strconcat(asmstr, "\t$rt, $rd, $sel"), [], NoItinerary, FrmFR>;

class MTC3OP<string asmstr, RegisterOperand RO, RegisterOperand RD> :
  InstSE<(outs RO:$rd), (ins RD:$rt, uimm16:$sel),
         !strconcat(asmstr, "\t$rt, $rd, $sel"), [], NoItinerary, FrmFR>;

class TrapBase<Instruction RealInst>
  : PseudoSE<(outs), (ins), [(trap)], NoItinerary>,
    PseudoInstExpansion<(RealInst 0, 0)> {
  let isBarrier = 1;
  let isTerminator = 1;
  let isCodeGenOnly = 1;
}

//===----------------------------------------------------------------------===//
// Pseudo instructions
//===----------------------------------------------------------------------===//

// Return RA.
let isReturn=1, isTerminator=1, hasDelaySlot=1, isBarrier=1, hasCtrlDep=1 in
def RetRA : PseudoSE<(outs), (ins), [(CXCPURet)]>;

let Defs = [SP], Uses = [SP], hasSideEffects = 1 in {
def ADJCALLSTACKDOWN : CXCPUPseudo<(outs), (ins i32imm:$amt),
                                  [(callseq_start timm:$amt)]>;
def ADJCALLSTACKUP   : CXCPUPseudo<(outs), (ins i32imm:$amt1, i32imm:$amt2),
                                  [(callseq_end timm:$amt1, timm:$amt2)]>;
}

let usesCustomInserter = 1 in {
  def ATOMIC_LOAD_ADD_I8   : Atomic2Ops<atomic_load_add_8, GPR32>;
  def ATOMIC_LOAD_ADD_I16  : Atomic2Ops<atomic_load_add_16, GPR32>;
  def ATOMIC_LOAD_ADD_I32  : Atomic2Ops<atomic_load_add_32, GPR32>;
  def ATOMIC_LOAD_SUB_I8   : Atomic2Ops<atomic_load_sub_8, GPR32>;
  def ATOMIC_LOAD_SUB_I16  : Atomic2Ops<atomic_load_sub_16, GPR32>;
  def ATOMIC_LOAD_SUB_I32  : Atomic2Ops<atomic_load_sub_32, GPR32>;
  def ATOMIC_LOAD_AND_I8   : Atomic2Ops<atomic_load_and_8, GPR32>;
  def ATOMIC_LOAD_AND_I16  : Atomic2Ops<atomic_load_and_16, GPR32>;
  def ATOMIC_LOAD_AND_I32  : Atomic2Ops<atomic_load_and_32, GPR32>;
  def ATOMIC_LOAD_OR_I8    : Atomic2Ops<atomic_load_or_8, GPR32>;
  def ATOMIC_LOAD_OR_I16   : Atomic2Ops<atomic_load_or_16, GPR32>;
  def ATOMIC_LOAD_OR_I32   : Atomic2Ops<atomic_load_or_32, GPR32>;
  def ATOMIC_LOAD_XOR_I8   : Atomic2Ops<atomic_load_xor_8, GPR32>;
  def ATOMIC_LOAD_XOR_I16  : Atomic2Ops<atomic_load_xor_16, GPR32>;
  def ATOMIC_LOAD_XOR_I32  : Atomic2Ops<atomic_load_xor_32, GPR32>;
  def ATOMIC_LOAD_NAND_I8  : Atomic2Ops<atomic_load_nand_8, GPR32>;
  def ATOMIC_LOAD_NAND_I16 : Atomic2Ops<atomic_load_nand_16, GPR32>;
  def ATOMIC_LOAD_NAND_I32 : Atomic2Ops<atomic_load_nand_32, GPR32>;

  def ATOMIC_SWAP_I8       : Atomic2Ops<atomic_swap_8, GPR32>;
  def ATOMIC_SWAP_I16      : Atomic2Ops<atomic_swap_16, GPR32>;
  def ATOMIC_SWAP_I32      : Atomic2Ops<atomic_swap_32, GPR32>;

  def ATOMIC_CMP_SWAP_I8   : AtomicCmpSwap<atomic_cmp_swap_8, GPR32>;
  def ATOMIC_CMP_SWAP_I16  : AtomicCmpSwap<atomic_cmp_swap_16, GPR32>;
  def ATOMIC_CMP_SWAP_I32  : AtomicCmpSwap<atomic_cmp_swap_32, GPR32>;
}

/// Pseudo instructions for loading and storing accumulator registers.
let isPseudo = 1, isCodeGenOnly = 1 in {
  def LOAD_ACC64  : Load<"", ACC64>;
  def STORE_ACC64 : Store<"", ACC64>;
}

// We need these two pseudo instructions to avoid offset calculation for long
// branches.  See the comment in file CXCPULongBranch.cpp for detailed
// explanation.

// Expands to: lui $dst, %hi($tgt - $baltgt)
def LONG_BRANCH_LUi : PseudoSE<(outs GPR32Opnd:$dst),
  (ins brtarget:$tgt, brtarget:$baltgt), []>;

// Expands to: addiu $dst, $src, %lo($tgt - $baltgt)
def LONG_BRANCH_ADDiu : PseudoSE<(outs GPR32Opnd:$dst),
  (ins GPR32Opnd:$src, brtarget:$tgt, brtarget:$baltgt), []>;

//===----------------------------------------------------------------------===//
// Instruction definition
//===----------------------------------------------------------------------===//
//===----------------------------------------------------------------------===//
// CXCPUI Instructions
//===----------------------------------------------------------------------===//

/// Arithmetic Instructions (ALU Immediate)
let AdditionalPredicates = [NotInMicroCXCPU] in {
def ADDiu : MMRel, StdMMR6Rel, ArithLogicI<"addiu", simm16, GPR32Opnd,
                                           II_ADDIU, immSExt16, add>,
            ADDI_FM<0x9>, IsAsCheapAsAMove;
}
def ADDi  : MMRel, ArithLogicI<"addi", simm16, GPR32Opnd>, ADDI_FM<0x8>,
            ISA_CXCPU1_NOT_32R6_64R6;
def SLTi  : MMRel, SetCC_I<"slti", setlt, simm16, immSExt16, GPR32Opnd>,
            SLTI_FM<0xa>;
def SLTiu : MMRel, SetCC_I<"sltiu", setult, simm16, immSExt16, GPR32Opnd>,
            SLTI_FM<0xb>;
let AdditionalPredicates = [NotInMicroCXCPU] in {
def ANDi  : MMRel, StdMMR6Rel,
            ArithLogicI<"andi", uimm16, GPR32Opnd, II_ANDI, immZExt16, and>,
            ADDI_FM<0xc>;
}
def ORi   : MMRel, StdMMR6Rel,
            ArithLogicI<"ori", uimm16, GPR32Opnd, II_ORI, immZExt16, or>,
            ADDI_FM<0xd>;
def XORi  : MMRel, StdMMR6Rel,
            ArithLogicI<"xori", uimm16, GPR32Opnd, II_XORI, immZExt16, xor>,
            ADDI_FM<0xe>;
def LUi   : MMRel, LoadUpper<"lui", GPR32Opnd, uimm16>, LUI_FM;
let AdditionalPredicates = [NotInMicroCXCPU] in {
/// Arithmetic Instructions (3-Operand, R-Type)
def ADDu  : MMRel, StdMMR6Rel, ArithLogicR<"addu", GPR32Opnd, 1, II_ADDU, add>,
            ADD_FM<0, 0x21>;
def SUBu  : MMRel, ArithLogicR<"subu", GPR32Opnd, 0, II_SUBU, sub>,
            ADD_FM<0, 0x23>;
}
let Defs = [HI0, LO0] in
def MUL   : MMRel, ArithLogicR<"mul", GPR32Opnd, 1, II_MUL, mul>,
            ADD_FM<0x1c, 2>, ISA_CXCPU32_NOT_32R6_64R6;
def ADD   : MMRel, StdMMR6Rel, ArithLogicR<"add", GPR32Opnd>, ADD_FM<0, 0x20>;
def SUB   : MMRel, ArithLogicR<"sub", GPR32Opnd>, ADD_FM<0, 0x22>;
def SLT   : MMRel, SetCC_R<"slt", setlt, GPR32Opnd>, ADD_FM<0, 0x2a>;
def SLTu  : MMRel, SetCC_R<"sltu", setult, GPR32Opnd>, ADD_FM<0, 0x2b>;
let AdditionalPredicates = [NotInMicroCXCPU] in {
def AND   : MMRel, StdMMR6Rel, ArithLogicR<"and", GPR32Opnd, 1, II_AND, and>,
            ADD_FM<0, 0x24>;
def OR    : MMRel, StdMMR6Rel, ArithLogicR<"or", GPR32Opnd, 1, II_OR, or>,
            ADD_FM<0, 0x25>;
def XOR   : MMRel, StdMMR6Rel, ArithLogicR<"xor", GPR32Opnd, 1, II_XOR, xor>,
            ADD_FM<0, 0x26>;
}
def NOR   : MMRel, StdMMR6Rel, LogicNOR<"nor", GPR32Opnd>, ADD_FM<0, 0x27>;

/// Shift Instructions
let AdditionalPredicates = [NotInMicroCXCPU] in {
def SLL  : MMRel, shift_rotate_imm<"sll", uimm5, GPR32Opnd, II_SLL, shl,
                                   immZExt5>, SRA_FM<0, 0>;
def SRL  : MMRel, shift_rotate_imm<"srl", uimm5, GPR32Opnd, II_SRL, srl,
                                   immZExt5>, SRA_FM<2, 0>;
}
def SRA  : MMRel, shift_rotate_imm<"sra", uimm5, GPR32Opnd, II_SRA, sra,
                                   immZExt5>, SRA_FM<3, 0>;
def SLLV : MMRel, shift_rotate_reg<"sllv", GPR32Opnd, II_SLLV, shl>,
           SRLV_FM<4, 0>;
def SRLV : MMRel, shift_rotate_reg<"srlv", GPR32Opnd, II_SRLV, srl>,
           SRLV_FM<6, 0>;
def SRAV : MMRel, shift_rotate_reg<"srav", GPR32Opnd, II_SRAV, sra>,
           SRLV_FM<7, 0>;

// Rotate Instructions
def ROTR  : MMRel, shift_rotate_imm<"rotr", uimm5, GPR32Opnd, II_ROTR, rotr,
                                    immZExt5>,
            SRA_FM<2, 1>, ISA_CXCPU32R2;
def ROTRV : MMRel, shift_rotate_reg<"rotrv", GPR32Opnd, II_ROTRV, rotr>,
            SRLV_FM<6, 1>, ISA_CXCPU32R2;

/// Load and Store Instructions
///  aligned
def LB  : Load<"lb", GPR32Opnd, sextloadi8, II_LB>, MMRel, LW_FM<0x20>;
def LBu : Load<"lbu", GPR32Opnd, zextloadi8, II_LBU, addrDefault>, MMRel,
          LW_FM<0x24>;
def LH  : Load<"lh", GPR32Opnd, sextloadi16, II_LH, addrDefault>, MMRel,
          LW_FM<0x21>;
def LHu : Load<"lhu", GPR32Opnd, zextloadi16, II_LHU>, MMRel, LW_FM<0x25>;
let AdditionalPredicates = [NotInMicroCXCPU] in {
def LW  : Load<"lw", GPR32Opnd, load, II_LW, addrDefault>, MMRel,
          LW_FM<0x23>;
}
def SB  : Store<"sb", GPR32Opnd, truncstorei8, II_SB>, MMRel, LW_FM<0x28>;
def SH  : Store<"sh", GPR32Opnd, truncstorei16, II_SH>, MMRel, LW_FM<0x29>;
let AdditionalPredicates = [NotInMicroCXCPU] in {
def SW  : Store<"sw", GPR32Opnd, store, II_SW>, MMRel, LW_FM<0x2b>;
}

/// load/store left/right
let EncodingPredicates = []<Predicate>, // FIXME: Lack of HasStdEnc is probably a bug
    AdditionalPredicates = [NotInMicroCXCPU] in {
def LWL : LoadLeftRight<"lwl", CXCPULWL, GPR32Opnd, II_LWL>, LW_FM<0x22>,
          ISA_CXCPU1_NOT_32R6_64R6;
def LWR : LoadLeftRight<"lwr", CXCPULWR, GPR32Opnd, II_LWR>, LW_FM<0x26>,
          ISA_CXCPU1_NOT_32R6_64R6;
def SWL : StoreLeftRight<"swl", CXCPUSWL, GPR32Opnd, II_SWL>, LW_FM<0x2a>,
          ISA_CXCPU1_NOT_32R6_64R6;
def SWR : StoreLeftRight<"swr", CXCPUSWR, GPR32Opnd, II_SWR>, LW_FM<0x2e>,
          ISA_CXCPU1_NOT_32R6_64R6;
}

let AdditionalPredicates = [NotInMicroCXCPU] in {
// COP2 Memory Instructions
def LWC2 : LW_FT2<"lwc2", COP2Opnd, NoItinerary, load>, LW_FM<0x32>,
           ISA_CXCPU1_NOT_32R6_64R6;
def SWC2 : SW_FT2<"swc2", COP2Opnd, NoItinerary, store>, LW_FM<0x3a>,
           ISA_CXCPU1_NOT_32R6_64R6;
def LDC2 : LW_FT2<"ldc2", COP2Opnd, NoItinerary, load>, LW_FM<0x36>,
           ISA_CXCPU2_NOT_32R6_64R6;
def SDC2 : SW_FT2<"sdc2", COP2Opnd, NoItinerary, store>, LW_FM<0x3e>,
           ISA_CXCPU2_NOT_32R6_64R6;

// COP3 Memory Instructions
let DecoderNamespace = "COP3_" in {
  def LWC3 : LW_FT3<"lwc3", COP3Opnd, NoItinerary, load>, LW_FM<0x33>;
  def SWC3 : SW_FT3<"swc3", COP3Opnd, NoItinerary, store>, LW_FM<0x3b>;
  def LDC3 : LW_FT3<"ldc3", COP3Opnd, NoItinerary, load>, LW_FM<0x37>,
             ISA_CXCPU2;
  def SDC3 : SW_FT3<"sdc3", COP3Opnd, NoItinerary, store>, LW_FM<0x3f>,
             ISA_CXCPU2;
}
}

def SYNC : MMRel, SYNC_FT<"sync">, SYNC_FM, ISA_CXCPU32;
def SYNCI : MMRel, SYNCI_FT<"synci">, SYNCI_FM, ISA_CXCPU32R2;

def TEQ : MMRel, TEQ_FT<"teq", GPR32Opnd>, TEQ_FM<0x34>, ISA_CXCPU2;
def TGE : MMRel, TEQ_FT<"tge", GPR32Opnd>, TEQ_FM<0x30>, ISA_CXCPU2;
def TGEU : MMRel, TEQ_FT<"tgeu", GPR32Opnd>, TEQ_FM<0x31>, ISA_CXCPU2;
def TLT : MMRel, TEQ_FT<"tlt", GPR32Opnd>, TEQ_FM<0x32>, ISA_CXCPU2;
def TLTU : MMRel, TEQ_FT<"tltu", GPR32Opnd>, TEQ_FM<0x33>, ISA_CXCPU2;
def TNE : MMRel, TEQ_FT<"tne", GPR32Opnd>, TEQ_FM<0x36>, ISA_CXCPU2;

def TEQI : MMRel, TEQI_FT<"teqi", GPR32Opnd>, TEQI_FM<0xc>,
           ISA_CXCPU2_NOT_32R6_64R6;
def TGEI : MMRel, TEQI_FT<"tgei", GPR32Opnd>, TEQI_FM<0x8>,
           ISA_CXCPU2_NOT_32R6_64R6;
def TGEIU : MMRel, TEQI_FT<"tgeiu", GPR32Opnd>, TEQI_FM<0x9>,
           ISA_CXCPU2_NOT_32R6_64R6;
def TLTI : MMRel, TEQI_FT<"tlti", GPR32Opnd>, TEQI_FM<0xa>,
           ISA_CXCPU2_NOT_32R6_64R6;
def TTLTIU : MMRel, TEQI_FT<"tltiu", GPR32Opnd>, TEQI_FM<0xb>,
           ISA_CXCPU2_NOT_32R6_64R6;
def TNEI : MMRel, TEQI_FT<"tnei", GPR32Opnd>, TEQI_FM<0xe>,
           ISA_CXCPU2_NOT_32R6_64R6;

let AdditionalPredicates = [NotInMicroCXCPU] in {
def BREAK : MMRel, StdMMR6Rel, BRK_FT<"break">, BRK_FM<0xd>;
}
def SYSCALL : MMRel, SYS_FT<"syscall">, SYS_FM<0xc>;
def TRAP : TrapBase<BREAK>;
def SDBBP : MMRel, SYS_FT<"sdbbp">, SDBBP_FM, ISA_CXCPU32_NOT_32R6_64R6;

let AdditionalPredicates = [NotInMicroCXCPU] in {
def ERET : MMRel, ER_FT<"eret">, ER_FM<0x18>, INSN_CXCPU3_32;
}
def DERET : MMRel, ER_FT<"deret">, ER_FM<0x1f>, ISA_CXCPU32;

let AdditionalPredicates = [NotInMicroCXCPU] in {
def EI : MMRel, StdMMR6Rel, DEI_FT<"ei", GPR32Opnd>, EI_FM<1>, ISA_CXCPU32R2;
}
def DI : MMRel, DEI_FT<"di", GPR32Opnd>, EI_FM<0>, ISA_CXCPU32R2;

let EncodingPredicates = []<Predicate>, // FIXME: Lack of HasStdEnc is probably a bug
    AdditionalPredicates = [NotInMicroCXCPU] in {
def WAIT : WAIT_FT<"wait">, WAIT_FM;

/// Load-linked, Store-conditional
def LL : LLBase<"ll", GPR32Opnd>, LW_FM<0x30>, ISA_CXCPU2_NOT_32R6_64R6;
def SC : SCBase<"sc", GPR32Opnd>, LW_FM<0x38>, ISA_CXCPU2_NOT_32R6_64R6;
}

/// Jump and Branch Instructions
def J       : MMRel, JumpFJ<jmptarget, "j", br, bb, "j">, FJ<2>,
              AdditionalRequires<[RelocStatic]>, IsBranch;
def JR      : MMRel, IndirectBranch<"jr", GPR32Opnd>, MTLO_FM<8>;
def BEQ     : MMRel, CBranch<"beq", brtarget, seteq, GPR32Opnd>, BEQ_FM<4>;
def BEQL    : MMRel, CBranch<"beql", brtarget, seteq, GPR32Opnd, 0>,
              BEQ_FM<20>, ISA_CXCPU2_NOT_32R6_64R6;
def BNE     : MMRel, CBranch<"bne", brtarget, setne, GPR32Opnd>, BEQ_FM<5>;
def BNEL    : MMRel, CBranch<"bnel", brtarget, setne, GPR32Opnd, 0>,
              BEQ_FM<21>, ISA_CXCPU2_NOT_32R6_64R6;
def BGEZ    : MMRel, CBranchZero<"bgez", brtarget, setge, GPR32Opnd>,
              BGEZ_FM<1, 1>;
def BGEZL   : MMRel, CBranchZero<"bgezl", brtarget, setge, GPR32Opnd, 0>,
              BGEZ_FM<1, 3>, ISA_CXCPU2_NOT_32R6_64R6;
def BGTZ    : MMRel, CBranchZero<"bgtz", brtarget, setgt, GPR32Opnd>,
              BGEZ_FM<7, 0>;
def BGTZL   : MMRel, CBranchZero<"bgtzl", brtarget, setgt, GPR32Opnd, 0>,
              BGEZ_FM<23, 0>, ISA_CXCPU2_NOT_32R6_64R6;
def BLEZ    : MMRel, CBranchZero<"blez", brtarget, setle, GPR32Opnd>,
              BGEZ_FM<6, 0>;
def BLEZL   : MMRel, CBranchZero<"blezl", brtarget, setle, GPR32Opnd, 0>,
              BGEZ_FM<22, 0>, ISA_CXCPU2_NOT_32R6_64R6;
def BLTZ    : MMRel, CBranchZero<"bltz", brtarget, setlt, GPR32Opnd>,
              BGEZ_FM<1, 0>;
def BLTZL   : MMRel, CBranchZero<"bltzl", brtarget, setlt, GPR32Opnd, 0>,
              BGEZ_FM<1, 2>, ISA_CXCPU2_NOT_32R6_64R6;
def B       : UncondBranch<BEQ>;

def JAL  : MMRel, JumpLink<"jal", calltarget>, FJ<3>;
let AdditionalPredicates = [NotInMicroCXCPU] in {
  def JALR : JumpLinkReg<"jalr", GPR32Opnd>, JALR_FM;
  def JALRPseudo : JumpLinkRegPseudo<GPR32Opnd, JALR, RA>;
}

def JALX : MMRel, JumpLink<"jalx", calltarget>, FJ<0x1D>,
           ISA_CXCPU32_NOT_32R6_64R6;
def BGEZAL : MMRel, BGEZAL_FT<"bgezal", brtarget, GPR32Opnd>, BGEZAL_FM<0x11>,
             ISA_CXCPU1_NOT_32R6_64R6;
def BGEZALL : MMRel, BGEZAL_FT<"bgezall", brtarget, GPR32Opnd, 0>,
              BGEZAL_FM<0x13>, ISA_CXCPU2_NOT_32R6_64R6;
def BLTZAL : MMRel, BGEZAL_FT<"bltzal", brtarget, GPR32Opnd>, BGEZAL_FM<0x10>,
             ISA_CXCPU1_NOT_32R6_64R6;
def BLTZALL : MMRel, BGEZAL_FT<"bltzall", brtarget, GPR32Opnd, 0>,
              BGEZAL_FM<0x12>, ISA_CXCPU2_NOT_32R6_64R6;
def BAL_BR : BAL_BR_Pseudo<BGEZAL>;
def TAILCALL : TailCall<J>;
def TAILCALL_R : TailCallReg<GPR32Opnd, JR>;

// Indirect branches are matched as PseudoIndirectBranch/PseudoIndirectBranch64
// then are expanded to JR, JR64, JALR, or JALR64 depending on the ISA.
class PseudoIndirectBranchBase<RegisterOperand RO> :
    CXCPUPseudo<(outs), (ins RO:$rs), [(brind RO:$rs)], IIBranch> {
  let isTerminator=1;
  let isBarrier=1;
  let hasDelaySlot = 1;
  let isBranch = 1;
  let isIndirectBranch = 1;
}

def PseudoIndirectBranch : PseudoIndirectBranchBase<GPR32Opnd>;

// Return instructions are matched as a RetRA instruction, then ar expanded
// into PseudoReturn/PseudoReturn64 after register allocation. Finally,
// CXCPUAsmPrinter expands this into JR, JR64, JALR, or JALR64 depending on the
// ISA.
class PseudoReturnBase<RegisterOperand RO> : CXCPUPseudo<(outs), (ins RO:$rs),
                                                        [], IIBranch> {
  let isTerminator = 1;
  let isBarrier = 1;
  let hasDelaySlot = 1;
  let isReturn = 1;
  let isCodeGenOnly = 1;
  let hasCtrlDep = 1;
  let hasExtraSrcRegAllocReq = 1;
}

def PseudoReturn : PseudoReturnBase<GPR32Opnd>;

// Exception handling related node and instructions.
// The conversion sequence is:
// ISD::EH_RETURN -> CXCPUISD::EH_RETURN ->
// CXCPUeh_return -> (stack change + indirect branch)
//
// CXCPUeh_return takes the place of regular return instruction
// but takes two arguments (V1, V0) which are used for storing
// the offset and return address respectively.
def SDT_CXCPUEHRET : SDTypeProfile<0, 2, [SDTCisInt<0>, SDTCisPtrTy<1>]>;

def CXCPUehret : SDNode<"CXCPUISD::EH_RETURN", SDT_CXCPUEHRET,
                      [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

let Uses = [V0, V1], isTerminator = 1, isReturn = 1, isBarrier = 1 in {
  def CXCPUeh_return32 : CXCPUPseudo<(outs), (ins GPR32:$spoff, GPR32:$dst),
                                [(CXCPUehret GPR32:$spoff, GPR32:$dst)]>;
  def CXCPUeh_return64 : CXCPUPseudo<(outs), (ins GPR64:$spoff,
                                                GPR64:$dst),
                                [(CXCPUehret GPR64:$spoff, GPR64:$dst)]>;
}

/// Multiply and Divide Instructions.
def MULT  : MMRel, Mult<"mult", II_MULT, GPR32Opnd, [HI0, LO0]>,
            MULT_FM<0, 0x18>, ISA_CXCPU1_NOT_32R6_64R6;
def MULTu : MMRel, Mult<"multu", II_MULTU, GPR32Opnd, [HI0, LO0]>,
            MULT_FM<0, 0x19>, ISA_CXCPU1_NOT_32R6_64R6;
def SDIV  : MMRel, Div<"div", II_DIV, GPR32Opnd, [HI0, LO0]>,
            MULT_FM<0, 0x1a>, ISA_CXCPU1_NOT_32R6_64R6;
def UDIV  : MMRel, Div<"divu", II_DIVU, GPR32Opnd, [HI0, LO0]>,
            MULT_FM<0, 0x1b>, ISA_CXCPU1_NOT_32R6_64R6;

def MTHI : MMRel, MoveToLOHI<"mthi", GPR32Opnd, [HI0]>, MTLO_FM<0x11>,
           ISA_CXCPU1_NOT_32R6_64R6;
def MTLO : MMRel, MoveToLOHI<"mtlo", GPR32Opnd, [LO0]>, MTLO_FM<0x13>,
           ISA_CXCPU1_NOT_32R6_64R6;
let EncodingPredicates = []<Predicate>, // FIXME: Lack of HasStdEnc is probably a bug
    AdditionalPredicates = [NotInMicroCXCPU] in {
def MFHI : MMRel, MoveFromLOHI<"mfhi", GPR32Opnd, AC0>, MFLO_FM<0x10>,
           ISA_CXCPU1_NOT_32R6_64R6;
def MFLO : MMRel, MoveFromLOHI<"mflo", GPR32Opnd, AC0>, MFLO_FM<0x12>,
           ISA_CXCPU1_NOT_32R6_64R6;
}

/// Sign Ext In Register Instructions.
def SEB : MMRel, StdMMR6Rel, SignExtInReg<"seb", i8, GPR32Opnd, II_SEB>,
          SEB_FM<0x10, 0x20>, ISA_CXCPU32R2;
def SEH : MMRel, StdMMR6Rel, SignExtInReg<"seh", i16, GPR32Opnd, II_SEH>,
          SEB_FM<0x18, 0x20>, ISA_CXCPU32R2;

/// Count Leading
def CLZ : MMRel, CountLeading0<"clz", GPR32Opnd>, CLO_FM<0x20>,
          ISA_CXCPU32_NOT_32R6_64R6;
def CLO : MMRel, CountLeading1<"clo", GPR32Opnd>, CLO_FM<0x21>,
          ISA_CXCPU32_NOT_32R6_64R6;

/// Word Swap Bytes Within Halfwords
def WSBH : MMRel, SubwordSwap<"wsbh", GPR32Opnd>, SEB_FM<2, 0x20>, ISA_CXCPU32R2;

/// No operation.
def NOP : PseudoSE<(outs), (ins), []>, PseudoInstExpansion<(SLL ZERO, ZERO, 0)>;

// FrameIndexes are legalized when they are operands from load/store
// instructions. The same not happens for stack address copies, so an
// add op with mem ComplexPattern is used and the stack address copy
// can be matched. It's similar to Sparc LEA_ADDRi
def LEA_ADDiu : MMRel, EffectiveAddress<"addiu", GPR32Opnd>, LW_FM<9>;

// MADD*/MSUB*
def MADD  : MMRel, MArithR<"madd", II_MADD, 1>, MULT_FM<0x1c, 0>,
            ISA_CXCPU32_NOT_32R6_64R6;
def MADDU : MMRel, MArithR<"maddu", II_MADDU, 1>, MULT_FM<0x1c, 1>,
            ISA_CXCPU32_NOT_32R6_64R6;
def MSUB  : MMRel, MArithR<"msub", II_MSUB>, MULT_FM<0x1c, 4>,
            ISA_CXCPU32_NOT_32R6_64R6;
def MSUBU : MMRel, MArithR<"msubu", II_MSUBU>, MULT_FM<0x1c, 5>,
            ISA_CXCPU32_NOT_32R6_64R6;

let AdditionalPredicates = [NotDSP] in {
def PseudoMULT  : MultDivPseudo<MULT, ACC64, GPR32Opnd, CXCPUMult, II_MULT>,
                  ISA_CXCPU1_NOT_32R6_64R6;
def PseudoMULTu : MultDivPseudo<MULTu, ACC64, GPR32Opnd, CXCPUMultu, II_MULTU>,
                  ISA_CXCPU1_NOT_32R6_64R6;
def PseudoMFHI : PseudoMFLOHI<GPR32, ACC64, CXCPUMFHI>, ISA_CXCPU1_NOT_32R6_64R6;
def PseudoMFLO : PseudoMFLOHI<GPR32, ACC64, CXCPUMFLO>, ISA_CXCPU1_NOT_32R6_64R6;
def PseudoMTLOHI : PseudoMTLOHI<ACC64, GPR32>, ISA_CXCPU1_NOT_32R6_64R6;
def PseudoMADD  : MAddSubPseudo<MADD, CXCPUMAdd, II_MADD>,
                  ISA_CXCPU32_NOT_32R6_64R6;
def PseudoMADDU : MAddSubPseudo<MADDU, CXCPUMAddu, II_MADDU>,
                  ISA_CXCPU32_NOT_32R6_64R6;
def PseudoMSUB  : MAddSubPseudo<MSUB, CXCPUMSub, II_MSUB>,
                  ISA_CXCPU32_NOT_32R6_64R6;
def PseudoMSUBU : MAddSubPseudo<MSUBU, CXCPUMSubu, II_MSUBU>,
                  ISA_CXCPU32_NOT_32R6_64R6;
}

def PseudoSDIV : MultDivPseudo<SDIV, ACC64, GPR32Opnd, CXCPUDivRem, II_DIV,
                               0, 1, 1>, ISA_CXCPU1_NOT_32R6_64R6;
def PseudoUDIV : MultDivPseudo<UDIV, ACC64, GPR32Opnd, CXCPUDivRemU, II_DIVU,
                               0, 1, 1>, ISA_CXCPU1_NOT_32R6_64R6;

def RDHWR : MMRel, ReadHardware<GPR32Opnd, HWRegsOpnd>, RDHWR_FM;

def EXT : MMRel, ExtBase<"ext", GPR32Opnd, uimm5, CXCPUExt>, EXT_FM<0>;
def INS : MMRel, InsBase<"ins", GPR32Opnd, uimm5, CXCPUIns>, EXT_FM<4>;

/// Move Control Registers From/To CPU Registers
def MFC0 : MFC3OP<"mfc0", GPR32Opnd, COP0Opnd>, MFC3OP_FM<0x10, 0>, ISA_CXCPU32;
def MTC0 : MTC3OP<"mtc0", COP0Opnd, GPR32Opnd>, MFC3OP_FM<0x10, 4>, ISA_CXCPU32;
def MFC2 : MFC3OP<"mfc2", GPR32Opnd, COP2Opnd>, MFC3OP_FM<0x12, 0>;
def MTC2 : MTC3OP<"mtc2", COP2Opnd, GPR32Opnd>, MFC3OP_FM<0x12, 4>;

class Barrier<string asmstr> : InstSE<(outs), (ins), asmstr, [], NoItinerary,
                                      FrmOther, asmstr>;
def SSNOP : MMRel, Barrier<"ssnop">, BARRIER_FM<1>;
def EHB : MMRel, Barrier<"ehb">, BARRIER_FM<3>;
def PAUSE : MMRel, Barrier<"pause">, BARRIER_FM<5>, ISA_CXCPU32R2;

// JR_HB and JALR_HB are defined here using the new style naming
// scheme because some of this code is shared with CXCPU32r6InstrInfo.td
// and because of that it doesn't follow the naming convention of the
// rest of the file. To avoid a mixture of old vs new style, the new
// style was chosen.
class JR_HB_DESC_BASE<string instr_asm, RegisterOperand GPROpnd> {
  dag OutOperandList = (outs);
  dag InOperandList = (ins GPROpnd:$rs);
  string AsmString = !strconcat(instr_asm, "\t$rs");
  list<dag> Pattern = [];
}

class JALR_HB_DESC_BASE<string instr_asm, RegisterOperand GPROpnd> {
  dag OutOperandList = (outs GPROpnd:$rd);
  dag InOperandList = (ins GPROpnd:$rs);
  string AsmString = !strconcat(instr_asm, "\t$rd, $rs");
  list<dag> Pattern = [];
}

class JR_HB_DESC : InstSE<(outs), (ins), "", [], NoItinerary, FrmJ>,
                   JR_HB_DESC_BASE<"jr.hb", GPR32Opnd> {
  let isBranch=1;
  let isIndirectBranch=1;
  let hasDelaySlot=1;
  let isTerminator=1;
  let isBarrier=1;
}

class JALR_HB_DESC : InstSE<(outs), (ins), "", [], NoItinerary, FrmJ>,
                     JALR_HB_DESC_BASE<"jalr.hb", GPR32Opnd> {
  let isIndirectBranch=1;
  let hasDelaySlot=1;
}

class JR_HB_ENC : JR_HB_FM<8>;
class JALR_HB_ENC : JALR_HB_FM<9>;

def JR_HB : JR_HB_DESC, JR_HB_ENC, ISA_CXCPU32_NOT_32R6_64R6;
def JALR_HB : JALR_HB_DESC, JALR_HB_ENC, ISA_CXCPU32;

class TLB<string asmstr> : InstSE<(outs), (ins), asmstr, [], NoItinerary,
                                      FrmOther, asmstr>;
def TLBP : MMRel, TLB<"tlbp">, COP0_TLB_FM<0x08>;
def TLBR : MMRel, TLB<"tlbr">, COP0_TLB_FM<0x01>;
def TLBWI : MMRel, TLB<"tlbwi">, COP0_TLB_FM<0x02>;
def TLBWR : MMRel, TLB<"tlbwr">, COP0_TLB_FM<0x06>;

class CacheOp<string instr_asm, Operand MemOpnd> :
    InstSE<(outs), (ins  MemOpnd:$addr, uimm5:$hint),
           !strconcat(instr_asm, "\t$hint, $addr"), [], NoItinerary, FrmOther,
           instr_asm> {
  let DecoderMethod = "DecodeCacheOp";
}

def CACHE : MMRel, CacheOp<"cache", mem>, CACHEOP_FM<0b101111>,
            INSN_CXCPU3_32_NOT_32R6_64R6;
def PREF :  MMRel, CacheOp<"pref", mem>, CACHEOP_FM<0b110011>,
            INSN_CXCPU3_32_NOT_32R6_64R6;

//===----------------------------------------------------------------------===//
// Instruction aliases
//===----------------------------------------------------------------------===//
def : CXCPUInstAlias<"move $dst, $src",
                    (ADDu GPR32Opnd:$dst, GPR32Opnd:$src,ZERO), 1>,
      GPR_32 {
  let AdditionalPredicates = [NotInMicroCXCPU];
}
def : CXCPUInstAlias<"bal $offset", (BGEZAL ZERO, brtarget:$offset), 0>,
      ISA_CXCPU1_NOT_32R6_64R6;
def : CXCPUInstAlias<"addu $rs, $rt, $imm",
                    (ADDiu GPR32Opnd:$rs, GPR32Opnd:$rt, simm16:$imm), 0>;
def : CXCPUInstAlias<"addu $rs, $imm",
                    (ADDiu GPR32Opnd:$rs, GPR32Opnd:$rs, simm16:$imm), 0>;
def : CXCPUInstAlias<"add $rs, $rt, $imm",
                    (ADDi GPR32Opnd:$rs, GPR32Opnd:$rt, simm16:$imm), 0>,
                    ISA_CXCPU1_NOT_32R6_64R6;
def : CXCPUInstAlias<"add $rs, $imm",
                    (ADDi GPR32Opnd:$rs, GPR32Opnd:$rs, simm16:$imm), 0>,
                    ISA_CXCPU1_NOT_32R6_64R6;
def : CXCPUInstAlias<"and $rs, $rt, $imm",
                    (ANDi GPR32Opnd:$rs, GPR32Opnd:$rt, simm16:$imm), 0>;
def : CXCPUInstAlias<"and $rs, $imm",
                    (ANDi GPR32Opnd:$rs, GPR32Opnd:$rs, simm16:$imm), 0>;
def : CXCPUInstAlias<"j $rs", (JR GPR32Opnd:$rs), 0>;
let Predicates = [NotInMicroCXCPU] in {
def : CXCPUInstAlias<"jalr $rs", (JALR RA, GPR32Opnd:$rs), 0>;
}
def : CXCPUInstAlias<"jalr.hb $rs", (JALR_HB RA, GPR32Opnd:$rs), 1>, ISA_CXCPU32;
def : CXCPUInstAlias<"not $rt, $rs",
                    (NOR GPR32Opnd:$rt, GPR32Opnd:$rs, ZERO), 0>;
def : CXCPUInstAlias<"neg $rt, $rs",
                    (SUB GPR32Opnd:$rt, ZERO, GPR32Opnd:$rs), 1>;
def : CXCPUInstAlias<"negu $rt",
                    (SUBu GPR32Opnd:$rt, ZERO, GPR32Opnd:$rt), 0>;
def : CXCPUInstAlias<"negu $rt, $rs",
                    (SUBu GPR32Opnd:$rt, ZERO, GPR32Opnd:$rs), 1>;
def : CXCPUInstAlias<"slt $rs, $rt, $imm",
                    (SLTi GPR32Opnd:$rs, GPR32Opnd:$rt, simm16:$imm), 0>;
def : CXCPUInstAlias<"sltu $rt, $rs, $imm",
                    (SLTiu GPR32Opnd:$rt, GPR32Opnd:$rs, simm16:$imm), 0>;
def : CXCPUInstAlias<"xor $rs, $rt, $imm",
                    (XORi GPR32Opnd:$rs, GPR32Opnd:$rt, uimm16:$imm), 0>;
def : CXCPUInstAlias<"xor $rs, $imm",
                    (XORi GPR32Opnd:$rs, GPR32Opnd:$rs, uimm16:$imm), 0>;
def : CXCPUInstAlias<"or $rs, $rt, $imm",
                    (ORi GPR32Opnd:$rs, GPR32Opnd:$rt, uimm16:$imm), 0>;
def : CXCPUInstAlias<"or $rs, $imm",
                    (ORi GPR32Opnd:$rs, GPR32Opnd:$rs, uimm16:$imm), 0>;
let AdditionalPredicates = [NotInMicroCXCPU] in {
def : CXCPUInstAlias<"nop", (SLL ZERO, ZERO, 0), 1>;
}
def : CXCPUInstAlias<"mfc0 $rt, $rd", (MFC0 GPR32Opnd:$rt, COP0Opnd:$rd, 0), 0>;
def : CXCPUInstAlias<"mtc0 $rt, $rd", (MTC0 COP0Opnd:$rd, GPR32Opnd:$rt, 0), 0>;
def : CXCPUInstAlias<"mfc2 $rt, $rd", (MFC2 GPR32Opnd:$rt, COP2Opnd:$rd, 0), 0>;
def : CXCPUInstAlias<"mtc2 $rt, $rd", (MTC2 COP2Opnd:$rd, GPR32Opnd:$rt, 0), 0>;
let AdditionalPredicates = [NotInMicroCXCPU] in {
def : CXCPUInstAlias<"b $offset", (BEQ ZERO, ZERO, brtarget:$offset), 0>;
}
def : CXCPUInstAlias<"bnez $rs,$offset",
                    (BNE GPR32Opnd:$rs, ZERO, brtarget:$offset), 0>;
def : CXCPUInstAlias<"bnezl $rs,$offset",
                    (BNEL GPR32Opnd:$rs, ZERO, brtarget:$offset), 0>;
def : CXCPUInstAlias<"beqz $rs,$offset",
                    (BEQ GPR32Opnd:$rs, ZERO, brtarget:$offset), 0>;
def : CXCPUInstAlias<"beqzl $rs,$offset",
                    (BEQL GPR32Opnd:$rs, ZERO, brtarget:$offset), 0>;
def : CXCPUInstAlias<"syscall", (SYSCALL 0), 1>;
    
def : CXCPUInstAlias<"break", (BREAK 0, 0), 1>;
def : CXCPUInstAlias<"break $imm", (BREAK uimm10:$imm, 0), 1>;
let AdditionalPredicates = [NotInMicroCXCPU] in {
def : CXCPUInstAlias<"ei", (EI ZERO), 1>, ISA_CXCPU32R2;
}
def : CXCPUInstAlias<"di", (DI ZERO), 1>, ISA_CXCPU32R2;

def : CXCPUInstAlias<"teq $rs, $rt",
                    (TEQ GPR32Opnd:$rs, GPR32Opnd:$rt, 0), 1>, ISA_CXCPU2;
def : CXCPUInstAlias<"tge $rs, $rt",
                    (TGE GPR32Opnd:$rs, GPR32Opnd:$rt, 0), 1>, ISA_CXCPU2;
def : CXCPUInstAlias<"tgeu $rs, $rt",
                    (TGEU GPR32Opnd:$rs, GPR32Opnd:$rt, 0), 1>, ISA_CXCPU2;
def : CXCPUInstAlias<"tlt $rs, $rt",
                    (TLT GPR32Opnd:$rs, GPR32Opnd:$rt, 0), 1>, ISA_CXCPU2;
def : CXCPUInstAlias<"tltu $rs, $rt",
                    (TLTU GPR32Opnd:$rs, GPR32Opnd:$rt, 0), 1>, ISA_CXCPU2;
def : CXCPUInstAlias<"tne $rs, $rt",
                    (TNE GPR32Opnd:$rs, GPR32Opnd:$rt, 0), 1>, ISA_CXCPU2;

def  : CXCPUInstAlias<"sll $rd, $rt, $rs",
                     (SLLV GPR32Opnd:$rd, GPR32Opnd:$rt, GPR32Opnd:$rs), 0>;
def : CXCPUInstAlias<"sub, $rd, $rs, $imm",
                    (ADDi GPR32Opnd:$rd, GPR32Opnd:$rs,
                          InvertedImOperand:$imm), 0>, ISA_CXCPU1_NOT_32R6_64R6;
def : CXCPUInstAlias<"sub $rs, $imm",
                    (ADDi GPR32Opnd:$rs, GPR32Opnd:$rs, InvertedImOperand:$imm),
                    0>, ISA_CXCPU1_NOT_32R6_64R6;
def : CXCPUInstAlias<"subu, $rd, $rs, $imm",
                    (ADDiu GPR32Opnd:$rd, GPR32Opnd:$rs,
                           InvertedImOperand:$imm), 0>;
def : CXCPUInstAlias<"subu $rs, $imm", (ADDiu GPR32Opnd:$rs, GPR32Opnd:$rs,
                                             InvertedImOperand:$imm), 0>;
def : CXCPUInstAlias<"sra $rd, $rt, $rs",
                    (SRAV GPR32Opnd:$rd, GPR32Opnd:$rt, GPR32Opnd:$rs), 0>;
def : CXCPUInstAlias<"srl $rd, $rt, $rs",
                    (SRLV GPR32Opnd:$rd, GPR32Opnd:$rt, GPR32Opnd:$rs), 0>;
def : CXCPUInstAlias<"sdbbp", (SDBBP 0)>, ISA_CXCPU32_NOT_32R6_64R6;
def : CXCPUInstAlias<"sync",
                    (SYNC 0), 1>, ISA_CXCPU2;
//===----------------------------------------------------------------------===//
// Assembler Pseudo Instructions
//===----------------------------------------------------------------------===//

class LoadImmediate32<string instr_asm, Operand Od, RegisterOperand RO> :
  CXCPUAsmPseudoInst<(outs RO:$rt), (ins Od:$imm32),
                     !strconcat(instr_asm, "\t$rt, $imm32")> ;
def LoadImm32 : LoadImmediate32<"li", uimm5, GPR32Opnd>;

class LoadAddressFromReg32<string instr_asm, Operand MemOpnd,
                           RegisterOperand RO> :
  CXCPUAsmPseudoInst<(outs RO:$rt), (ins MemOpnd:$addr),
                     !strconcat(instr_asm, "\t$rt, $addr")> ;
def LoadAddrReg32 : LoadAddressFromReg32<"la", mem, GPR32Opnd>;

class LoadAddressFromImm32<string instr_asm, Operand Od, RegisterOperand RO> :
  CXCPUAsmPseudoInst<(outs RO:$rt), (ins Od:$imm32),
                     !strconcat(instr_asm, "\t$rt, $imm32")> ;
def LoadAddrImm32 : LoadAddressFromImm32<"la", uimm5, GPR32Opnd>;

def JalTwoReg : CXCPUAsmPseudoInst<(outs GPR32Opnd:$rd), (ins GPR32Opnd:$rs),
                      "jal\t$rd, $rs"> ;
def JalOneReg : CXCPUAsmPseudoInst<(outs), (ins GPR32Opnd:$rs),
                      "jal\t$rs"> ;

let hasDelaySlot = 1 in {
def BneImm : CXCPUAsmPseudoInst<(outs GPR32Opnd:$rt),
                               (ins imm64:$imm64, brtarget:$offset),
                               "bne\t$rt, $imm64, $offset">;
def BeqImm : CXCPUAsmPseudoInst<(outs GPR32Opnd:$rt),
                               (ins imm64:$imm64, brtarget:$offset),
                               "beq\t$rt, $imm64, $offset">;

class CondBranchPseudo<string instr_asm> :
  CXCPUAsmPseudoInst<(outs), (ins GPR32Opnd:$rs, GPR32Opnd:$rt,
                                 brtarget:$offset),
                    !strconcat(instr_asm, "\t$rs, $rt, $offset")>;
}

def BLT : CondBranchPseudo<"blt">;
def BLE : CondBranchPseudo<"ble">;
def BGE : CondBranchPseudo<"bge">;
def BGT : CondBranchPseudo<"bgt">;
def BLTU : CondBranchPseudo<"bltu">;
def BLEU : CondBranchPseudo<"bleu">;
def BGEU : CondBranchPseudo<"bgeu">;
def BGTU : CondBranchPseudo<"bgtu">;

def Ulhu : CXCPUAsmPseudoInst<(outs GPR32Opnd:$rt), (ins mem:$addr),
                             "ulhu\t$rt, $addr">, ISA_CXCPU1_NOT_32R6_64R6;

def Ulw : CXCPUAsmPseudoInst<(outs GPR32Opnd:$rt), (ins mem:$addr),
                            "ulw\t$rt, $addr">, ISA_CXCPU1_NOT_32R6_64R6;

//===----------------------------------------------------------------------===//
//  Arbitrary patterns that map to one or more instructions
//===----------------------------------------------------------------------===//

// Load/store pattern templates.
class LoadRegImmPat<Instruction LoadInst, ValueType ValTy, PatFrag Node> :
  CXCPUPat<(ValTy (Node addrRegImm:$a)), (LoadInst addrRegImm:$a)>;

class StoreRegImmPat<Instruction StoreInst, ValueType ValTy> :
  CXCPUPat<(store ValTy:$v, addrRegImm:$a), (StoreInst ValTy:$v, addrRegImm:$a)>;

// Small immediates
let AdditionalPredicates = [NotInMicroCXCPU] in {
def : CXCPUPat<(i32 immSExt16:$in),
              (ADDiu ZERO, imm:$in)>;
def : CXCPUPat<(i32 immZExt16:$in),
              (ORi ZERO, imm:$in)>;
}
def : CXCPUPat<(i32 immLow16Zero:$in),
              (LUi (HI16 imm:$in))>;

// Arbitrary immediates
def : CXCPUPat<(i32 imm:$imm),
          (ORi (LUi (HI16 imm:$imm)), (LO16 imm:$imm))>;

// Carry CXCPUPatterns
def : CXCPUPat<(subc GPR32:$lhs, GPR32:$rhs),
              (SUBu GPR32:$lhs, GPR32:$rhs)>;
let AdditionalPredicates = [NotDSP] in {
  def : CXCPUPat<(addc GPR32:$lhs, GPR32:$rhs),
                (ADDu GPR32:$lhs, GPR32:$rhs)>;
  def : CXCPUPat<(addc  GPR32:$src, immSExt16:$imm),
                (ADDiu GPR32:$src, imm:$imm)>;
}

// Support multiplication for pre-CXCPU32 targets that don't have
// the MUL instruction.
def : CXCPUPat<(mul GPR32:$lhs, GPR32:$rhs),
              (PseudoMFLO (PseudoMULT GPR32:$lhs, GPR32:$rhs))>,
      ISA_CXCPU1_NOT_32R6_64R6;

// SYNC
def : CXCPUPat<(CXCPUSync (i32 immz)),
              (SYNC 0)>, ISA_CXCPU2;

// Call
def : CXCPUPat<(CXCPUJmpLink (i32 tglobaladdr:$dst)),
              (JAL tglobaladdr:$dst)>;
def : CXCPUPat<(CXCPUJmpLink (i32 texternalsym:$dst)),
              (JAL texternalsym:$dst)>;
//def : CXCPUPat<(CXCPUJmpLink GPR32:$dst),
//              (JALR GPR32:$dst)>;

// Tail call
def : CXCPUPat<(CXCPUTailCall (iPTR tglobaladdr:$dst)),
              (TAILCALL tglobaladdr:$dst)>;
def : CXCPUPat<(CXCPUTailCall (iPTR texternalsym:$dst)),
              (TAILCALL texternalsym:$dst)>;
// hi/lo relocs
def : CXCPUPat<(CXCPUHi tglobaladdr:$in), (LUi tglobaladdr:$in)>;
def : CXCPUPat<(CXCPUHi tblockaddress:$in), (LUi tblockaddress:$in)>;
def : CXCPUPat<(CXCPUHi tjumptable:$in), (LUi tjumptable:$in)>;
def : CXCPUPat<(CXCPUHi tconstpool:$in), (LUi tconstpool:$in)>;
def : CXCPUPat<(CXCPUHi tglobaltlsaddr:$in), (LUi tglobaltlsaddr:$in)>;
def : CXCPUPat<(CXCPUHi texternalsym:$in), (LUi texternalsym:$in)>;

def : CXCPUPat<(CXCPULo tglobaladdr:$in), (ADDiu ZERO, tglobaladdr:$in)>;
def : CXCPUPat<(CXCPULo tblockaddress:$in), (ADDiu ZERO, tblockaddress:$in)>;
def : CXCPUPat<(CXCPULo tjumptable:$in), (ADDiu ZERO, tjumptable:$in)>;
def : CXCPUPat<(CXCPULo tconstpool:$in), (ADDiu ZERO, tconstpool:$in)>;
def : CXCPUPat<(CXCPULo tglobaltlsaddr:$in), (ADDiu ZERO, tglobaltlsaddr:$in)>;
def : CXCPUPat<(CXCPULo texternalsym:$in), (ADDiu ZERO, texternalsym:$in)>;

def : CXCPUPat<(add GPR32:$hi, (CXCPULo tglobaladdr:$lo)),
              (ADDiu GPR32:$hi, tglobaladdr:$lo)>;
def : CXCPUPat<(add GPR32:$hi, (CXCPULo tblockaddress:$lo)),
              (ADDiu GPR32:$hi, tblockaddress:$lo)>;
def : CXCPUPat<(add GPR32:$hi, (CXCPULo tjumptable:$lo)),
              (ADDiu GPR32:$hi, tjumptable:$lo)>;
def : CXCPUPat<(add GPR32:$hi, (CXCPULo tconstpool:$lo)),
              (ADDiu GPR32:$hi, tconstpool:$lo)>;
def : CXCPUPat<(add GPR32:$hi, (CXCPULo tglobaltlsaddr:$lo)),
              (ADDiu GPR32:$hi, tglobaltlsaddr:$lo)>;

// gp_rel relocs
def : CXCPUPat<(add GPR32:$gp, (CXCPUGPRel tglobaladdr:$in)),
              (ADDiu GPR32:$gp, tglobaladdr:$in)>;
def : CXCPUPat<(add GPR32:$gp, (CXCPUGPRel tconstpool:$in)),
              (ADDiu GPR32:$gp, tconstpool:$in)>;

// wrapper_pic
class WrapperPat<SDNode node, Instruction ADDiuOp, RegisterClass RC>:
      CXCPUPat<(CXCPUWrapper RC:$gp, node:$in),
              (ADDiuOp RC:$gp, node:$in)>;

def : WrapperPat<tglobaladdr, ADDiu, GPR32>;
def : WrapperPat<tconstpool, ADDiu, GPR32>;
def : WrapperPat<texternalsym, ADDiu, GPR32>;
def : WrapperPat<tblockaddress, ADDiu, GPR32>;
def : WrapperPat<tjumptable, ADDiu, GPR32>;
def : WrapperPat<tglobaltlsaddr, ADDiu, GPR32>;

let AdditionalPredicates = [NotInMicroCXCPU] in {
// CXCPU does not have "not", so we expand our way
def : CXCPUPat<(not GPR32:$in),
              (NOR GPR32Opnd:$in, ZERO)>;
}

// extended loads
def : CXCPUPat<(i32 (extloadi1  addr:$src)), (LBu addr:$src)>;
def : CXCPUPat<(i32 (extloadi8  addr:$src)), (LBu addr:$src)>;
def : CXCPUPat<(i32 (extloadi16 addr:$src)), (LHu addr:$src)>;

// peepholes
def : CXCPUPat<(store (i32 0), addr:$dst), (SW ZERO, addr:$dst)>;

// brcond patterns
multiclass BrcondPats<RegisterClass RC, Instruction BEQOp, Instruction BNEOp,
                      Instruction SLTOp, Instruction SLTuOp, Instruction SLTiOp,
                      Instruction SLTiuOp, Register ZEROReg> {
def : CXCPUPat<(brcond (i32 (setne RC:$lhs, 0)), bb:$dst),
              (BNEOp RC:$lhs, ZEROReg, bb:$dst)>;
def : CXCPUPat<(brcond (i32 (seteq RC:$lhs, 0)), bb:$dst),
              (BEQOp RC:$lhs, ZEROReg, bb:$dst)>;

def : CXCPUPat<(brcond (i32 (setge RC:$lhs, RC:$rhs)), bb:$dst),
              (BEQ (SLTOp RC:$lhs, RC:$rhs), ZERO, bb:$dst)>;
def : CXCPUPat<(brcond (i32 (setuge RC:$lhs, RC:$rhs)), bb:$dst),
              (BEQ (SLTuOp RC:$lhs, RC:$rhs), ZERO, bb:$dst)>;
def : CXCPUPat<(brcond (i32 (setge RC:$lhs, immSExt16:$rhs)), bb:$dst),
              (BEQ (SLTiOp RC:$lhs, immSExt16:$rhs), ZERO, bb:$dst)>;
def : CXCPUPat<(brcond (i32 (setuge RC:$lhs, immSExt16:$rhs)), bb:$dst),
              (BEQ (SLTiuOp RC:$lhs, immSExt16:$rhs), ZERO, bb:$dst)>;
def : CXCPUPat<(brcond (i32 (setgt RC:$lhs, immSExt16Plus1:$rhs)), bb:$dst),
              (BEQ (SLTiOp RC:$lhs, (Plus1 imm:$rhs)), ZERO, bb:$dst)>;
def : CXCPUPat<(brcond (i32 (setugt RC:$lhs, immSExt16Plus1:$rhs)), bb:$dst),
              (BEQ (SLTiuOp RC:$lhs, (Plus1 imm:$rhs)), ZERO, bb:$dst)>;

def : CXCPUPat<(brcond (i32 (setle RC:$lhs, RC:$rhs)), bb:$dst),
              (BEQ (SLTOp RC:$rhs, RC:$lhs), ZERO, bb:$dst)>;
def : CXCPUPat<(brcond (i32 (setule RC:$lhs, RC:$rhs)), bb:$dst),
              (BEQ (SLTuOp RC:$rhs, RC:$lhs), ZERO, bb:$dst)>;

def : CXCPUPat<(brcond RC:$cond, bb:$dst),
              (BNEOp RC:$cond, ZEROReg, bb:$dst)>;
}

defm : BrcondPats<GPR32, BEQ, BNE, SLT, SLTu, SLTi, SLTiu, ZERO>;

def : CXCPUPat<(brcond (i32 (setlt i32:$lhs, 1)), bb:$dst),
              (BLEZ i32:$lhs, bb:$dst)>;
def : CXCPUPat<(brcond (i32 (setgt i32:$lhs, -1)), bb:$dst),
              (BGEZ i32:$lhs, bb:$dst)>;

// setcc patterns
multiclass SeteqPats<RegisterClass RC, Instruction SLTiuOp, Instruction XOROp,
                     Instruction SLTuOp, Register ZEROReg> {
  def : CXCPUPat<(seteq RC:$lhs, 0),
                (SLTiuOp RC:$lhs, 1)>;
  def : CXCPUPat<(setne RC:$lhs, 0),
                (SLTuOp ZEROReg, RC:$lhs)>;
  def : CXCPUPat<(seteq RC:$lhs, RC:$rhs),
                (SLTiuOp (XOROp RC:$lhs, RC:$rhs), 1)>;
  def : CXCPUPat<(setne RC:$lhs, RC:$rhs),
                (SLTuOp ZEROReg, (XOROp RC:$lhs, RC:$rhs))>;
}

multiclass SetlePats<RegisterClass RC, Instruction SLTOp, Instruction SLTuOp> {
  def : CXCPUPat<(setle RC:$lhs, RC:$rhs),
                (XORi (SLTOp RC:$rhs, RC:$lhs), 1)>;
  def : CXCPUPat<(setule RC:$lhs, RC:$rhs),
                (XORi (SLTuOp RC:$rhs, RC:$lhs), 1)>;
}

multiclass SetgtPats<RegisterClass RC, Instruction SLTOp, Instruction SLTuOp> {
  def : CXCPUPat<(setgt RC:$lhs, RC:$rhs),
                (SLTOp RC:$rhs, RC:$lhs)>;
  def : CXCPUPat<(setugt RC:$lhs, RC:$rhs),
                (SLTuOp RC:$rhs, RC:$lhs)>;
}

multiclass SetgePats<RegisterClass RC, Instruction SLTOp, Instruction SLTuOp> {
  def : CXCPUPat<(setge RC:$lhs, RC:$rhs),
                (XORi (SLTOp RC:$lhs, RC:$rhs), 1)>;
  def : CXCPUPat<(setuge RC:$lhs, RC:$rhs),
                (XORi (SLTuOp RC:$lhs, RC:$rhs), 1)>;
}

multiclass SetgeImmPats<RegisterClass RC, Instruction SLTiOp,
                        Instruction SLTiuOp> {
  def : CXCPUPat<(setge RC:$lhs, immSExt16:$rhs),
                (XORi (SLTiOp RC:$lhs, immSExt16:$rhs), 1)>;
  def : CXCPUPat<(setuge RC:$lhs, immSExt16:$rhs),
                (XORi (SLTiuOp RC:$lhs, immSExt16:$rhs), 1)>;
}

defm : SeteqPats<GPR32, SLTiu, XOR, SLTu, ZERO>;
defm : SetlePats<GPR32, SLT, SLTu>;
defm : SetgtPats<GPR32, SLT, SLTu>;
defm : SetgePats<GPR32, SLT, SLTu>;
defm : SetgeImmPats<GPR32, SLTi, SLTiu>;

// bswap pattern
def : CXCPUPat<(bswap GPR32:$rt), (ROTR (WSBH GPR32:$rt), 16)>;

// Load halfword/word patterns.
let AddedComplexity = 40 in {
  def : LoadRegImmPat<LBu, i32, zextloadi8>;
  def : LoadRegImmPat<LH, i32, sextloadi16>;
  let AdditionalPredicates = [NotInMicroCXCPU] in {
  def : LoadRegImmPat<LW, i32, load>;
  }
}

//===----------------------------------------------------------------------===//
// Floating Point Support
//===----------------------------------------------------------------------===//

include "CXCPUInstrFPU.td"
include "CXCPU64InstrInfo.td"
include "CXCPUCondMov.td"

include "CXCPU32r6InstrInfo.td"
include "CXCPU64r6InstrInfo.td"

//
// CXCPU16

include "CXCPU16InstrFormats.td"
include "CXCPU16InstrInfo.td"

// DSP
include "CXCPUDSPInstrFormats.td"
include "CXCPUDSPInstrInfo.td"

// MSA
include "CXCPUMSAInstrFormats.td"
include "CXCPUMSAInstrInfo.td"

// Micromips
include "MicroCXCPUInstrFormats.td"
include "MicroCXCPUInstrInfo.td"
include "MicroCXCPUInstrFPU.td"

// Micromips r6
include "MicroCXCPU32r6InstrFormats.td"
include "MicroCXCPU32r6InstrInfo.td"
