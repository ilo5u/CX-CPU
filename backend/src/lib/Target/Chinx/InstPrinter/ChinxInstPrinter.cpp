//===-- ChinxInstPrinter.cpp - Convert Chinx MCInst to assembly syntax ------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This class prints an Chinx MCInst to a .s file.
//
//===----------------------------------------------------------------------===//

#include "ChinxInstPrinter.h"
#include "ChinxInstrInfo.h"

#include "llvm/ADT/StringExtras.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;

#define DEBUG_TYPE "asm-printer"

#define PRINT_ALIAS_INSTR
#include "ChinxGenAsmWriter.inc"

void ChinxInstPrinter::printRegName(raw_ostream &OS, unsigned RegNo) const {
// getRegisterName(RegNo) defined in ChinxGenAsmWriter.inc which indicate in Chinx.td
  OS << '$' << StringRef(getRegisterName(RegNo)).lower();
}

void ChinxInstPrinter::printInst(const MCInst *MI, raw_ostream &O,
                                 StringRef Annot, const MCSubtargetInfo &STI) {
  // Try to print any aliases first.
  // printInstruction(MI, O) defined in ChinxGenAsmWriter.inc which indicate in Chinx.td
  if (!printAliasInstr(MI, O))
    printInstruction(MI, O);
  printAnnotation(O, Annot);
}

void ChinxInstPrinter::printOperand(const MCInst *MI, unsigned OpNo,
                                    raw_ostream &O) {
  const MCOperand &Op = MI->getOperand(OpNo);
  if (Op.isReg()) {
    printRegName(O, Op.getReg());
    return;
  }

  if (Op.isImm()) {
    O << formatImm(Op.getImm());
    return;
  }

  assert(Op.isExpr() && "unknown operand kind in printOperand");
  Op.getExpr()->print(O, &MAI, true);
}

void ChinxInstPrinter::printUImm(const MCInst *MI, int opNum, raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(opNum);
  if (MO.isImm()) {
    O << (unsigned short int)MO.getImm();
    return;
  }
  printOperand(MI, opNum, O);
}

void ChinxInstPrinter::
printMemOperand(const MCInst *MI, int opNum, raw_ostream &O) {
  // Load/Store memory operands -- imm($reg)
  // If PIC target the target is loaded as the
  // pattern lw $25,%call16($gp)
  printOperand(MI, opNum+1, O);
  O << "(";
  printOperand(MI, opNum, O);
  O << ")";
}