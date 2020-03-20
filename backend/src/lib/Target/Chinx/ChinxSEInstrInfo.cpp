//===-- ChinxSEInstrInfo.cpp - Chinx Instruction Information -----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the Chinx implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#include "ChinxSEInstrInfo.h"
#include "ChinxMachineFunction.h"
#include "ChinxTargetMachine.h"

#include "llvm/ADT/STLExtras.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

ChinxSEInstrInfo::ChinxSEInstrInfo(const ChinxSubtarget &STI)
    : ChinxInstrInfo(STI),
      RI(STI) {}

const ChinxRegisterInfo &ChinxSEInstrInfo::getRegisterInfo() const {
  return RI;
}

void ChinxSEInstrInfo::storeRegToStack(MachineBasicBlock &MBB,
  MachineBasicBlock::iterator I, unsigned SrcReg, bool isKill, int FI,
  const TargetRegisterClass *RC, const TargetRegisterInfo *TRI, int64_t Offset) const {
  DebugLoc DL;
  MachineMemOperand *MMO = GetMemOperand(MBB, FI, MachineMemOperand::MOStore);
  unsigned Opc = Chinx::SW;
  assert(Opc && "Register class not handled!");
  BuildMI(MBB, I, DL, get(Opc)).addReg(SrcReg, getKillRegState(isKill))
    .addFrameIndex(FI).addImm(Offset).addMemOperand(MMO);
}

void ChinxSEInstrInfo::loadRegFromStack(MachineBasicBlock &MBB,
  MachineBasicBlock::iterator I, unsigned DestReg, int FI,
  const TargetRegisterClass *RC,
  const TargetRegisterInfo *TRI, int64_t Offset) const {
  DebugLoc DL;
  if (I != MBB.end()) DL = I->getDebugLoc();
  MachineMemOperand *MMO = GetMemOperand(MBB, FI, MachineMemOperand::MOLoad);
  unsigned Opc = Chinx::LW;
  assert(Opc && "Register class not handled!");
  BuildMI(MBB, I, DL, get(Opc), DestReg).addFrameIndex(FI).addImm(Offset)
    .addMemOperand(MMO);
}

/// Expand Pseudo instructions into real backend instructions
bool ChinxSEInstrInfo::expandPostRAPseudo(MachineInstr &MI) const {
//@expandPostRAPseudo-body
  MachineBasicBlock &MBB = *MI.getParent();

  switch (MI.getDesc().getOpcode()) {
  default:
    return false;
  case Chinx::RetRA:
    expandRetRA(MBB, MI);
    break;
  }
  MBB.erase(MI);
  return true;
}

/// Adjust SP by Amount bytes.
void ChinxSEInstrInfo::adjustStackPtr(unsigned SP, int64_t Amount,
  MachineBasicBlock &MBB, MachineBasicBlock::iterator I) const {
  DebugLoc DL = I != MBB.end() ? I->getDebugLoc() : DebugLoc();
  unsigned ADD = Chinx::ADD; // add ra,rb,rc
  unsigned ADDI = Chinx::ADDI; // addi ra,rb,imm16

  if (isInt<16>(Amount)) {
    // addiu sp, sp, amount
    BuildMI(MBB, I, DL, get(ADDI), SP).addReg(SP).addImm(Amount);
  }
  else { // Expand immediate that doesn't fit in 16-bit.
    unsigned Reg = loadImmediate(Amount, MBB, I, DL, nullptr);
    BuildMI(MBB, I, DL, get(ADD), SP).addReg(SP).addReg(Reg, RegState::Kill);
  }
}

/// This function generates the sequence of instructions needed to get the
/// result of adding register REG and immediate IMM.
unsigned ChinxSEInstrInfo::loadImmediate(int64_t Imm,
  MachineBasicBlock &MBB, MachineBasicBlock::iterator II,
  const DebugLoc &DL, unsigned *NewImm) const {
  ChinxAnalyzeImmediate AnalyzeImm;
  unsigned Size = 32;
  unsigned LUI = Chinx::LUI;
  unsigned ZEROReg = Chinx::ZERO;
  unsigned ATReg = Chinx::AT;
  bool LastInstrIsADDI = NewImm;

  const ChinxAnalyzeImmediate::InstSeq &Seq =
    AnalyzeImm.Analyze(Imm, Size, LastInstrIsADDI);
  ChinxAnalyzeImmediate::InstSeq::const_iterator Inst = Seq.begin();

  assert(Seq.size() && (!LastInstrIsADDI || (Seq.size() > 1)));

  // The first instruction can be a LUI, which is different from other
  // instructions (ADDI, ORI and SLL) in that it does not have a register
  // operand.
  if (Inst->Opc == LUI)
    BuildMI(MBB, II, DL, get(LUI), ATReg).addImm(SignExtend64<16>(Inst->ImmOpnd));
  else
    BuildMI(MBB, II, DL, get(Inst->Opc), ATReg).addReg(ZEROReg)
      .addImm(SignExtend64<16>(Inst->ImmOpnd));

  // Build the remaining instructions in Seq.
  for (++Inst; Inst != Seq.end() - LastInstrIsADDI; ++Inst)
    BuildMI(MBB, II, DL, get(Inst->Opc), ATReg).addReg(ATReg)
      .addImm(SignExtend64<16>(Inst->ImmOpnd));

  if (LastInstrIsADDI)
    *NewImm = Inst->ImmOpnd;

  return ATReg;
}

void ChinxSEInstrInfo::expandRetRA(MachineBasicBlock &MBB,
                                MachineBasicBlock::iterator I) const {
  BuildMI(MBB, I, I->getDebugLoc(), get(Chinx::RET)).addReg(Chinx::RA);
}

const ChinxInstrInfo *llvm::createChinxSEInstrInfo(const ChinxSubtarget &STI) {
  return new ChinxSEInstrInfo(STI);
}
