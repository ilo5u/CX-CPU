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

const ChinxInstrInfo *llvm::createChinxSEInstrInfo(const ChinxSubtarget &STI) {
  return new ChinxSEInstrInfo(STI);
}
