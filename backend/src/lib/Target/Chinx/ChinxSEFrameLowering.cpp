//===-- ChinxSEFrameLowering.cpp - Chinx Frame Information ----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the Chinx implementation of TargetFrameLowering class.
//
//===----------------------------------------------------------------------===//

#include "ChinxSEFrameLowering.h"
#include "ChinxMachineFunction.h"
#include "ChinxSEInstrInfo.h"
#include "ChinxSubtarget.h"

#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Target/TargetOptions.h"

using namespace llvm;

ChinxSEFrameLowering::ChinxSEFrameLowering(const ChinxSubtarget &STI)
  : ChinxFrameLowering(STI, STI.stackAlignment()) {}

// @emitPrologue
void ChinxSEFrameLowering::emitPrologue(MachineFunction &MF,
                                        MachineBasicBlock &MBB) const {}

// @emitEpilogue
void ChinxSEFrameLowering::emitEpilogue(MachineFunction &MF,
                                        MachineBasicBlock &MBB) const {}

const ChinxFrameLowering *
llvm::createChinxSEFrameLowering(const ChinxSubtarget &ST) {
  return new ChinxSEFrameLowering(ST);
}
