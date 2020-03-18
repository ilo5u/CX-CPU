//===-- ChinxAsmPrinter.cpp - Chinx LLVM Assembly Printer -------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains a printer that converts from our internal representation
// of machine-dependent LLVM code to GAS-format CHINX assembly language.
//
//===----------------------------------------------------------------------===//

#include "ChinxAsmPrinter.h"
#include "InstPrinter/ChinxInstPrinter.h"
#include "MCTargetDesc/ChinxBaseInfo.h"
#include "Chinx.h"
#include "ChinxInstrInfo.h"

#include "llvm/ADT/SmallString.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/ADT/Twine.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineMemOperand.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Mangler.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/ELF.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Target/TargetLoweringObjectFile.h"
#include "llvm/Target/TargetOptions.h"

using namespace llvm;

#define DEBUG_TYPE "chinx-asm-printer"

bool ChinxAsmPrinter::runOnMachineFunction(MachineFunction &MF) {
  ChinxFI = MF.getInfo<ChinxFunctionInfo>();
  AsmPrinter::runOnMachineFunction(MF);
  return true;
}

bool ChinxAsmPrinter::lowerOperand(const MachineOperand &MO, MCOperand &MCOp) {
  MCOp = MCInstLowering.LowerOperand(MO);
  return MCOp.isValid();
}

void ChinxAsmPrinter::EmitInstruction(const MachineInstr *MI) {
  if (MI->isDebugValue()) {
    SmallString<128> Str;
    raw_svector_ostream OS(Str);

    PrintDebugValueComment(MI, OS);
    return;
  }

  // Print out both ordinary instruction and boudle instruction.
  MachineBasicBlock::const_instr_iterator I = MI->getIterator();
  MachineBasicBlock::const_instr_iterator E = MI->getParent()->instr_end();

  do {
    if (I->isPseudo())
      llvm_unreachable("Pseudo opcode found in EmitInstruction()");

    MCInst TmpInst0;
    MCInstLowering.Lower(&*I, TmpInst0);
    OutStreamer->EmitInstruction(TmpInst0, getSubtargetInfo());
  } while ((++I != E) && I->isInsideBundle()); // Delay slot check
}

//===----------------------------------------------------------------------===//
//
//  Chinx Asm Directives
//
//  -- Frame directive "frame Stackpointer, Stacksize, RARegister"
//  Describe the stack frame.
//
//  -- Mask directives "(f)mask  bitmask, offset"
//  Tells the assembler which registers are saved and where.
//  bitmask - contain a little endian bitset indicating which registers are
//            saved on function prologue (e.g. with a 0x80000000 mask, the
//            assembler knows the register 31 (RA) is saved at prologue.
//  offset  - the position before stack pointer subtraction indicating where
//            the first saved register on prologue is located. (e.g. with a
//
//  Consider the following function prologue:
//
//    .frame  $fp,48,$ra
//    .mask   0xc0000000,-8
//       addiu $sp, $sp, -48
//       sw $ra, 40($sp)
//       sw $fp, 36($sp)
//
//    With a 0xc0000000 mask, the assembler knows the register 31 (RA) and
//    30 (FP) are saved at prologue. As the save order on prologue is from
//    left to right, RA is saved first. A -8 offset means that after the
//    stack pointer subtration, the first register in the mask (RA) will be
//    saved at address 48-8=40.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Mask directives
//===----------------------------------------------------------------------===//

// Create a bitmask with all callee saved registers for CPU or Floating Point
// registers. For CPU registers consider RA, GP and FP for saving if necessary.
void ChinxAsmPrinter::printSavedRegsBitmask(raw_ostream& O) {
  // CPU Saved Registers Bitmasks
  unsigned CPUBitmask = 0;
  int CPUTopSavedRegOff;

  // Set the CPU Bitmasks
  const MachineFrameInfo *MFI = MF->getFrameInfo();
  const TargetRegisterInfo *TRI = MF->getSubtarget().getRegisterInfo();
  const std::vector<CalleeSavedInfo> &CSI = MFI->getCalleeSavedInfo();
  // size of stack area to which FP callee-saved regs are saved.
  unsigned CPURegSize = Chinx::CPURegsRegClass.getSize();

  // Set CPU Bitmask.
  for (const auto &I : CSI) {
    unsigned Reg = I.getReg();
    unsigned RegNum = TRI->getEncodingValue(Reg);
    CPUBitmask |= (1 << RegNum);
  }

  CPUTopSavedRegOff = CPUBitmask ? - CPURegSize : 0;

  // Print CPUBitmask
  O << "\t.mask \t";
  printHex32(CPUBitmask, O);
  O << "," << CPUTopSavedRegOff << "\n";
}

void ChinxAsmPrinter::printHex32(unsigned Value, raw_ostream& O) {
  O << "0x";
  for (int i = 7; i >= 0; --i)
    O.write_hex((Value & (0xF << (i * 4))) >> (i * 4));
}

//===----------------------------------------------------------------------===//
// Frame and Set directives
//===----------------------------------------------------------------------===//

/// Frame Directive
void ChinxAsmPrinter::emitFrameDirective() {
  const TargetRegisterInfo &RI = *MF->getSubtarget().getRegisterInfo();

  unsigned stackReg  = RI.getFrameRegister(*MF);
  unsigned returnReg = RI.getRARegister();
  unsigned stackSize = MF->getFrameInfo()->getStackSize();
  if (OutStreamer->hasRawTextSupport()) {
    OutStreamer->EmitRawText("\t.frame\t$" + 
      StringRef(ChinxInstPrinter::getRegisterName(stackReg)).lower() + 
      "," + Twine(stackSize) + ",$" +
      StringRef(ChinxInstPrinter::getRegisterName(returnReg)).lower()
    );
  }
}

/// Emit Set directives.
const char *ChinxAsmPrinter::getCurrentABIString() const {
  switch (static_cast<ChinxTargetMachine &>(TM).getABI().GetEnumValue()) {
  case ChinxABIInfo::ABI::O32:  return "abiO32";
  case ChinxABIInfo::ABI::S32:  return "abiS32";
  default: llvm_unreachable("Unknown Chinx ABI");
  }
}

void ChinxAsmPrinter::EmitFunctionEntryLabel() {
  if (OutStreamer->hasRawTextSupport())
    OutStreamer->EmitRawText("\t.ent\t" + Twine(CurrentFnSym->getName()));
  OutStreamer->EmitLabel(CurrentFnSym);
}

/// EmitFunctionBodyStart - Targets can override this to emit stuff before
/// the first basic block in the function.
void ChinxAsmPrinter::EmitFunctionBodyStart() {
  MCInstLowering.Initialize(&MF->getContext());
  emitFrameDirective();
  if (OutStreamer->hasRawTextSupport()) {
    SmallString<128> Str;
    raw_svector_ostream OS(Str);
    printSavedRegsBitmask(OS);
    OutStreamer->EmitRawText(OS.str());
    OutStreamer->EmitRawText(StringRef("\t.set\tnoreorder"));
    OutStreamer->EmitRawText(StringRef("\t.set\tnomacro"));
    if (ChinxFI->getEmitNOAT())
      OutStreamer->EmitRawText(StringRef("\t.set\tnoat"));
  }
}

/// EmitFunctionBodyEnd - Targets can override this to emit stuff after
/// the last basic block in the function.
void ChinxAsmPrinter::EmitFunctionBodyEnd() {
  // There are instruction for this macros, but they must
  // always be at the function end, and we can't emit and
  // break with BB logic.
  if (OutStreamer->hasRawTextSupport()) {
    if (ChinxFI->getEmitNOAT())
      OutStreamer->EmitRawText(StringRef("\t.set\tat"));
    OutStreamer->EmitRawText(StringRef("\t.set\tmacro"));
    OutStreamer->EmitRawText(StringRef("\t.set\treorder"));
    OutStreamer->EmitRawText("\t.end\t" + Twine(CurrentFnSym->getName()));
  }
}

void ChinxAsmPrinter::EmitStartOfAsmFile(Module &M) {
  // tell the assembler which ABI we are using
  if (OutStreamer->hasRawTextSupport())
    OutStreamer->EmitRawText("\t.section .mdebug." + 
      Twine(getCurrentABIString()));
  // return to previous section
  if (OutStreamer->hasRawTextSupport())
    OutStreamer->EmitRawText(StringRef("\t.previous"));
}

void ChinxAsmPrinter::PrintDebugValueComment(const MachineInstr *MI,
                                             raw_ostream &OS) {
  OS << "PrintDebugValueComment()";
}

// Force static initialization.
extern "C" void LLVMInitializeChinxAsmPrinter() {
  RegisterAsmPrinter<ChinxAsmPrinter> X(TheChinxTarget);
  RegisterAsmPrinter<ChinxAsmPrinter> Y(TheChinxelTarget);
}
