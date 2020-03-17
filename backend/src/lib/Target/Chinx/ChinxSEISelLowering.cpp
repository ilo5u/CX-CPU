//===-- ChinxSEISelLowering.cpp - ChinxSE DAG Lowering Interface --*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Subclass of ChinxTargetLowering specialized for chinx.
//
//===----------------------------------------------------------------------===//
#include "ChinxMachineFunction.h"
#include "ChinxSEISelLowering.h"
#include "ChinxRegisterInfo.h"
#include "ChinxTargetMachine.h"

#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetInstrInfo.h"

using namespace llvm;

#define DEBUG_TYPE "chinx-isel"

// @EnableChinxTailCalls
static cl::opt<bool>
EnableChinxTailCalls("enable-chinx-tail-calls", cl::Hidden,
                    cl::desc("CHINX: Enable tail calls."), cl::init(false));

ChinxSETargetLowering::ChinxSETargetLowering(const ChinxTargetMachine &TM,
                                             const ChinxSubtarget &STI)
    : ChinxTargetLowering(TM, STI) {
  // Set up the register classes
  addRegisterClass(MVT::i32, &Chinx::CPURegsRegClass);

  // must, computeRegisterProperties - Once all of the register classes are
  // added, this allow us to compute derived properties we expose.
  computeRegisterProperties(Subtarget.getRegisterInfo());
}

SDValue ChinxSETargetLowering::LowerOperation(SDValue Op,
                                              SelectionDAG &DAG) const {
  return ChinxTargetLowering::LowerOperation(Op, DAG);
}

const ChinxTargetLowering *
llvm::createChinxSETargetLowering(const ChinxTargetMachine &TM,
                                  const ChinxSubtarget &STI) {
  return new ChinxSETargetLowering(TM, STI);                                    
}