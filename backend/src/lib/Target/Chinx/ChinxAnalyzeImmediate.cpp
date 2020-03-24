//===-- ChinxAnalyzeImmediate.cpp - Analyze Immediates ---------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
#include "ChinxAnalyzeImmediate.h"
#include "Chinx.h"

#include "llvm/Support/MathExtras.h"

using namespace llvm;

ChinxAnalyzeImmediate::Inst::Inst(unsigned O, unsigned I) 
  : Opc(O), ImmOpnd(I) {}

// Add I to the instruction sequences.
void ChinxAnalyzeImmediate::AddInstr(InstSeqLs &SeqLs, const Inst &I) {
  // Add an instruction seqeunce consisting of just I.
  if (SeqLs.empty()) {
    SeqLs.push_back(InstSeq(1, I));
    return;
  }

  for (InstSeqLs::iterator Iter = SeqLs.begin(); Iter != SeqLs.end(); ++Iter)
    Iter->push_back(I);
}

void ChinxAnalyzeImmediate::GetInstSeqLsADDI(uint64_t Imm,
  unsigned RemSize, InstSeqLs &SeqLs) {
  GetInstSeqLs((Imm + 0x8000ULL) & 0xffffffffffff0000ULL, RemSize, SeqLs);
  AddInstr(SeqLs, Inst(ADDI, Imm & 0xffffULL));
}

void ChinxAnalyzeImmediate::GetInstSeqLsORI(uint64_t Imm,
  unsigned RemSize, InstSeqLs &SeqLs) {
  GetInstSeqLs(Imm & 0xffffffffffff0000ULL, RemSize, SeqLs);
  AddInstr(SeqLs, Inst(ORI, Imm & 0xffffULL));
}

void ChinxAnalyzeImmediate::GetInstSeqLsSHL(uint64_t Imm,
  unsigned RemSize, InstSeqLs &SeqLs) {
  unsigned Shamt = countTrailingZeros(Imm);
  GetInstSeqLs(Imm >> Shamt, RemSize - Shamt, SeqLs);
  AddInstr(SeqLs, Inst(SHL, Shamt));
}

void ChinxAnalyzeImmediate::GetInstSeqLs(uint64_t Imm,
  unsigned RemSize, InstSeqLs &SeqLs) {
  uint64_t MaskedImm = Imm & (0xffffffffffffffffULL >> (64 - Size));

  // Do nothing if Imm is 0.
  if (!MaskedImm)
    return;

  // A single ADDI will do if RemSize <= 16.
  if (RemSize <= 16) {
    AddInstr(SeqLs, Inst(ADDI, MaskedImm));
    return;
  }

  // Shift if the lower 16-bit is cleared.
  if (!(Imm & 0xffff)) {
    GetInstSeqLsSHL(Imm, RemSize, SeqLs);
    return;
  }

  GetInstSeqLsADDI(Imm, RemSize, SeqLs);

  // If bit 15 is cleared, it doesn't make a difference whether the last
  // instruction is an ADDI or ORI. In that case, do not call GetInstSeqLsORI.
  if (Imm & 0x8000) {
    InstSeqLs SeqLsORI;
    GetInstSeqLsORI(Imm, RemSize, SeqLsORI);
    SeqLs.insert(SeqLs.end(), SeqLsORI.begin(), SeqLsORI.end());
  }
}

// Replace a ADDI & SHL pair with a LUI.
// e.g. the following two instructions
//  ADDI 0x0111
//  SHL 18
// are replaced with
//  LUI 0x444
void ChinxAnalyzeImmediate::ReplaceADDISHLWithLUI(InstSeq &Seq) {
  // Check if the first two instructions are ADDI and SHL and the shift amount
  // is at least 16.
  if ((Seq.size() < 2) || (Seq[0].Opc != ADDI) ||
      (Seq[1].Opc != SHL) || (Seq[1].ImmOpnd < 16))
    return;

  // Sign-extend and shift operand of ADDI and see if it still fits in 16-bit.
  int64_t Imm = SignExtend64<16>(Seq[0].ImmOpnd);
  int64_t ShiftedImm = (uint64_t)Imm << (Seq[1].ImmOpnd - 16);

  if (!isInt<16>(ShiftedImm))
    return;

  // Replace the first instruction and erase the second.
  Seq[0].Opc = LUI;
  Seq[0].ImmOpnd = (unsigned)(ShiftedImm & 0xffff);
  Seq.erase(Seq.begin() + 1);
}

void ChinxAnalyzeImmediate::GetShortestSeq(InstSeqLs &SeqLs, InstSeq &Insts) {
  InstSeqLs::iterator ShortestSeq = SeqLs.end();
  // The length of an instruction sequence is at most 7.
  unsigned ShortestLength = 8;

  for (InstSeqLs::iterator S = SeqLs.begin(); S != SeqLs.end(); ++S) {
    ReplaceADDISHLWithLUI(*S);
    assert(S->size() <= 7);

    if (S->size() < ShortestLength) {
      ShortestSeq = S;
      ShortestLength = S->size();
    }
  }

  Insts.clear();
  Insts.append(ShortestSeq->begin(), ShortestSeq->end());
}

const ChinxAnalyzeImmediate::InstSeq
&ChinxAnalyzeImmediate::Analyze(uint64_t Imm, unsigned Size,
                               bool LastInstrIsADDI) {
  this->Size = Size;

  ADDI = Chinx::ADDI;
  ORI = Chinx::ORI;
  SHL = Chinx::SHL;
  LUI = Chinx::LUI;

  InstSeqLs SeqLs;

  // Get the list of instruction sequences.
  if (LastInstrIsADDI | !Imm)
    GetInstSeqLsADDI(Imm, Size, SeqLs);
  else
    GetInstSeqLs(Imm, Size, SeqLs);

  // Set Insts to the shortest instruction sequence.
  GetShortestSeq(SeqLs, Insts);

  return Insts;
}
