//===-- ChinxAsmPrinter.h - Chinx LLVM Assembly Printer ----------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Chinx Assembly printer class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_CHINX_CHINXASMPRINTER_H
#define LLVM_LIB_TARGET_CHINX_CHINXASMPRINTER_H

#include "ChinxMachineFunction.h"
#include "ChinxMCInstLower.h"
#include "ChinxSubtarget.h"
#include "ChinxTargetMachine.h"

#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {
class MCStreamer;
class MachineInstr;
class MachineBasicBlock;
class Module;
class raw_ostream;

class LLVM_LIBRARY_VISIBILITY ChinxAsmPrinter : public AsmPrinter {
  void EmitInstrWithMacroNoAT(const MachineInstr *MI);

private:
  // lowerOperand - Convert a MachineOperand into the equivalent MCOperand.
  bool lowerOperand(const MachineOperand &MO, MCOperand &MCOp);

public:

  const ChinxSubtarget *Subtarget;
  const ChinxFunctionInfo *ChinxFI;
  ChinxMCInstLower MCInstLowering;

  explicit ChinxAsmPrinter(TargetMachine &TM,
                           std::unique_ptr<MCStreamer> Streamer)
      : AsmPrinter(TM, std::move(Streamer)), MCInstLowering(*this) {
          Subtarget = static_cast<ChinxTargetMachine &>(TM).getSubtargetImpl();
        }

  virtual const char *getPassName() const override {
    return "Chinx Assembly Printer";
  }

  virtual bool runOnMachineFunction(MachineFunction &MF) override;

  // EmitInstruction() must exists or will have run time error.
  void EmitInstruction(const MachineInstr *MI) override;
  void printSavedRegsBitmask(raw_ostream& O);
  void printHex32(unsigned int Value, raw_ostream& O);
  void emitFrameDirective();
  const char *getCurrentABIString() const;
  void EmitFunctionEntryLabel() override;
  void EmitFunctionBodyStart() override;
  void EmitFunctionBodyEnd() override;
  void EmitStartOfAsmFile(Module &M) override;
  void PrintDebugValueComment(const MachineInstr *MI, raw_ostream &OS);
};
}

#endif
