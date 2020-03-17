//===-- ChinxInstrInfo.cpp - Chinx Instruction Information ------------------===//
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

#include "ChinxInstrInfo.h"
#include "ChinxTargetMachine.h"
#include "ChinxMachineFunction.h"

#include "llvm/ADT/STLExtras.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define GET_INSTRINFO_CTOR_DTOR
#include "ChinxGenInstrInfo.inc"

// Pin the vtable to this file.
void ChinxInstrInfo::anchor() {}

ChinxInstrInfo::ChinxInstrInfo(const ChinxSubtarget &STI)
    : Subtarget(STI) {}

const ChinxInstrInfo *ChinxInstrInfo::create(ChinxSubtarget &STI) {
  return llvm::createChinxSEInstrInfo(STI);
}

/// Return the number of bytes of code the specified instruction may be.
unsigned ChinxInstrInfo::GetInstSizeInBytes(const MachineInstr &MI) const {
  switch (MI.getOpcode()) {
  default:
    return MI.getDesc().getSize();
  }
}