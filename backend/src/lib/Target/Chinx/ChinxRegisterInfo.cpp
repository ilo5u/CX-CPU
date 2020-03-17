//===-- ChinxRegisterInfo.cpp - CHINX Register Information -== --------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the CHINX implementation of the TargetRegisterInfo class.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "chinx-reg-info"

#include "ChinxRegisterInfo.h"
#include "Chinx.h"
#include "ChinxSubtarget.h"
#include "ChinxMachineFunction.h"

#include "llvm/IR/Function.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

#define GET_REGINFO_TARGET_DESC
#include "ChinxGenRegisterInfo.inc"

using namespace llvm;

ChinxRegisterInfo::ChinxRegisterInfo(const ChinxSubtarget &ST) 
  : ChinxGenRegisterInfo(Chinx::RA), Subtarget(ST) {}

//===----------------------------------------------------------------------===//
// Callee Saved Registers methods
//===----------------------------------------------------------------------===//

/// Chinx Callee Saved Registers
/// In ChinxCallConv.td
/// def CSR_O32 : CalleeSavedRegs<(add RA,FP,(sequence "S%u", 7, 0))>;
/// llc create CSR_O32_SaveList and CSR_O32_RegMask from above defined.
const MCPhysReg *
ChinxRegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
  return CSR_O32_SaveList;
}

const uint32_t *
ChinxRegisterInfo::getCallPreservedMask(const MachineFunction &MF,
                                        CallingConv::ID) const {
  return CSR_O32_RegMask;
}

BitVector ChinxRegisterInfo::
getReservedRegs(const MachineFunction &MF) const {
  static const MCPhysReg ReservedCPURegs[] = {
    Chinx::ZERO, Chinx::AT, Chinx::K0, Chinx::K1, Chinx::SP,
    Chinx::RA, Chinx::PC
  };

  BitVector Reserved(getNumRegs());

  for (unsigned I = 0; I < array_lengthof(ReservedCPURegs); ++I)
    Reserved.set(ReservedCPURegs[I]);

  return Reserved;
}

// FrameIndex represent objects inside a abstract stack.
// We must replace FrameIndex with an stack/frame pointer
// direct reference.
void ChinxRegisterInfo::
eliminateFrameIndex(MachineBasicBlock::iterator II, int SPAdj,
                    unsigned FIOperandNum, RegScavenger *RS) const {}

bool
ChinxRegisterInfo::requiresRegisterScavenging(const MachineFunction &MF) const {
    return true;
}

bool
ChinxRegisterInfo::trackLivenessAfterRegAlloc(const MachineFunction &MF) const {
    return true;
}

unsigned ChinxRegisterInfo::
getFrameRegister(const MachineFunction &MF) const {
  const TargetFrameLowering *TFI = MF.getSubtarget().getFrameLowering();
  return TFI->hasFP(MF) ? Chinx::FP : Chinx::SP;
}
