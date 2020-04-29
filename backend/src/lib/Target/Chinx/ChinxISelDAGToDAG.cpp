//===-- ChinxISelDAGToDAG.cpp - A Dag to Dag Inst Selector for Chinx
//--------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines an instruction selector for the CHINX target.
//
//===----------------------------------------------------------------------===//

#include "ChinxISelDAGToDAG.h"
#include "Chinx.h"
#include "ChinxMachineFunction.h"
#include "ChinxRegisterInfo.h"
#include "ChinxTargetMachine.h"

#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
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

//===----------------------------------------------------------------------===//
// Instruction Selector Implementation
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// ChinxDAGToDAGISel - CHINX specific code to select CHINX machine
// instructions for SelectionDAG operations.
//===----------------------------------------------------------------------===//

bool ChinxDAGToDAGISel::runOnMachineFunction(MachineFunction &MF) {
  Subtarget = &static_cast<const ChinxSubtarget &>(MF.getSubtarget());
  bool Ret = SelectionDAGISel::runOnMachineFunction(MF);
  return Ret;
}

/// ComplexPattern used on ChinxInstrInfo
/// Used on Chinx Load/Store instructions
bool ChinxDAGToDAGISel::SelectADDRls(SDNode *Parent, SDValue Addr, SDValue &Base,
                                     SDValue &Offset) {
  EVT ValTy = Addr.getValueType();
  SDLoc DL(Addr);

  // If Parent is an unsigned f32 load or store, select a (base + index)
  // floating pointer load/store instruction (luxcl or suxcl).
  const LSBaseSDNode *LS = nullptr;
  if (Parent && (LS == dyn_cast<LSBaseSDNode>(Parent))) {
    EVT VT = LS->getMemoryVT();
    if (VT.getSizeInBits() / 8 > LS->getAlignment()) {
      assert("Unaligned loads/stores not supported for this type.");
      if (VT == MVT::f32)
        return false;
    }
  }

  // if Address is FI, get the TargetFrameIndex.
  if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
    Base = CurDAG->getTargetFrameIndex(FIN->getIndex(), ValTy);
    Offset = CurDAG->getTargetConstant(0, DL, ValTy);
    return true;
  }

  Base = Addr;
  Offset = CurDAG->getTargetConstant(0, DL, ValTy);
  return true;
}

bool ChinxDAGToDAGISel::SelectADDRio(SDValue Addr, SDValue &Base,
                                     SDValue &Offset) {
  EVT ValTy = Addr.getValueType();
  SDLoc DL(Addr);

  // if Address is FI, get the TargetFrameIndex.
  if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
    return false;
  }

  Base = Addr;
  Offset = CurDAG->getTargetConstant(0, DL, ValTy);
  return true;
}

/// Select instructions not customized! Used for
/// expanded, promoted and normal instructions
void ChinxDAGToDAGISel::Select(SDNode *Node) {
  unsigned Opcode = Node->getOpcode();

  // Dump information about the Node being selected
  // DEBUG(errs() << "Selecting: "; Node->dump(CurDAG); errs() << "\n");

  // If we have a custom node, we already have selected!
  if (Node->isMachineOpcode()) {
    // DEBUG(errs() << "== "; Node->dump(CurDAG); errs() << "\n");
    Node->setNodeId(-1);
    return;
  }

  // See if subclasses can handle this node.
  if (trySelect(Node))
    return;

  switch (Opcode) {
  default:
    break;
  }

  // Select the default instruction
  SelectCode(Node);
}

bool ChinxDAGToDAGISel::trySelect(SDNode *Node) {
  unsigned Opcode = Node->getOpcode();
  SDLoc DL(Node);
  EVT NodeTy = Node->getValueType(0);
  //unsigned MulOpc;
  ///
  // Instruction Selection not handled by the auto-generated
  // tablegen selection should be handled here.
  ///
  switch (Opcode) {
  // case ISD::MUL:
  //case ISD::STORE: {
  //  SDNode *Store = CurDAG->getMachineNode(Chinx::SET, DL, NodeTy, MVT::Glue,
		//{Node->getOperand(0), Node->getOperand(1), Node->getOperand(2), Node->getOperand(3)});
  //  ReplaceNode(Node, Store);
  //StoreSDNode *s = dyn_cast<StoreSDNode>(Node);
  //
  //break;
  //  return true;
  //}
  //case ISD::MULHU:
  //case ISD::MULHS: {
  //  MulOpc = Chinx::MUL;
  //  auto LoHi = selectMul(Node, MulOpc, DL, NodeTy, true, true);
  //  ReplaceNode(Node, LoHi.second);
  //  return true;
  //}
  //case ISD::Constant: {
  //  const ConstantSDNode *CN = dyn_cast<ConstantSDNode>(Node);
  //  if (CN->getValueSizeInBits(0) == 32)
  //    break;
  //  return true;
  //}
  default:
    break;
  }
  return false;
}

void ChinxDAGToDAGISel::processFunctionAfterISel(MachineFunction &MF) {}

FunctionPass *llvm::createChinxISelDag(ChinxTargetMachine &TM,
                                       CodeGenOpt::Level OptLevel) {
  return new ChinxDAGToDAGISel(TM, OptLevel);
}
