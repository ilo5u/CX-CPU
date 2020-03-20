//===-- ChinxSEISelDAGToDAG.cpp - A Dag to Dag Inst Selector for ChinxSE ----===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Subclass of ChinxDAGToDAGISel specialized for chinx.
//
//===----------------------------------------------------------------------===//

#include "ChinxSEISelDAGToDAG.h"
#include "MCTargetDesc/ChinxBaseInfo.h"
#include "Chinx.h"
#include "ChinxMachineFunction.h"
#include "ChinxRegisterInfo.h"

#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAGNodes.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetMachine.h"
using namespace llvm;

#define DEBUG_TYPE "chinx-isel"

bool ChinxSEDAGToDAGISel::runOnMachineFunction(MachineFunction &MF) {
  Subtarget = &static_cast<const ChinxSubtarget &>(MF.getSubtarget());
  return ChinxDAGToDAGISel::runOnMachineFunction(MF);
}

void ChinxSEDAGToDAGISel::processFunctionAfterISel(MachineFunction &MF) {}

bool ChinxSEDAGToDAGISel::trySelect(SDNode *Node) {
  unsigned Opcode = Node->getOpcode();
  SDLoc DL(Node);
  // EVT NodeTy = Node->getValueType(0);
  // unsigned MultOpc;
  ///
  // Instruction Selection not handled by the auto-generated
  // tablegen selection should be handled here.
  ///
  switch(Opcode) {
  default: break;
  }
  return false;
}

FunctionPass *llvm::createChinxSEISelDag(ChinxTargetMachine &TM,
                                         CodeGenOpt::Level OptLevel) {
  return new ChinxSEDAGToDAGISel(TM, OptLevel);
}