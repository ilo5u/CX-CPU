//===-- ChinxISelLowering.cpp - Chinx DAG Lowering Implementation -----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the interfaces that Chinx uses to lower LLVM code into a
// selection DAG.
//
//===----------------------------------------------------------------------===//
#include "ChinxISelLowering.h"
#include "ChinxMachineFunction.h"
#include "ChinxTargetMachine.h"
#include "ChinxTargetObjectFile.h"
#include "ChinxSubtarget.h"

#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/IR/CallingConv.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define DEBUG_TYPE "chinx-lower"

const char *ChinxTargetLowering::getTargetNodeName(unsigned Opcode) const {
  switch ((ChinxISD::NodeType)Opcode) {
  case ChinxISD::JmpLink:           return "ChinxISD::JmpLink";
  case ChinxISD::TailCall:          return "ChinxISD::TailCall";
  case ChinxISD::Hi:                return "ChinxISD::Hi";
  case ChinxISD::Lo:                return "ChinxISD::Lo";
  case ChinxISD::GPRel:             return "ChinxISD::GPRel";
  case ChinxISD::Ret:               return "ChinxISD::Ret";
  case ChinxISD::EH_RETURN:         return "ChinxISD::EH_RETURN";
  case ChinxISD::MFHI:              return "ChinxISD::MFHI";
  case ChinxISD::MFLO:              return "ChinxISD::MFLO";
  case ChinxISD::Mult:              return "ChinxISD::Mult";
  case ChinxISD::Wrapper:           return "ChinxISD::Wrapper";
  }
  return nullptr;
}

ChinxTargetLowering::ChinxTargetLowering(const ChinxTargetMachine &TM,
                                         const ChinxSubtarget &STI)
  : TargetLowering(TM), Subtarget(STI), ABI(TM.getABI()) {}

const ChinxTargetLowering *ChinxTargetLowering::create(const ChinxTargetMachine &TM,
                                                       const ChinxSubtarget &STI) {
  return llvm::createChinxSETargetLowering(TM, STI);
}

#include "ChinxGenCallingConv.inc"

//===----------------------------------------------------------------------===//
//             Formal Arguments Calling Convention Implementation
//===----------------------------------------------------------------------===//
/// LowerFormalArguments - transform physical registers into virtual registers
/// and generate load operations for arguments places on the stack.
SDValue ChinxTargetLowering::LowerFormalArguments(
    SDValue Chain, CallingConv::ID CallConv, bool IsVarArg,
    const SmallVectorImpl<ISD::InputArg> &Ins, const SDLoc &DL,
    SelectionDAG &DAG, SmallVectorImpl<SDValue> &InVals) const {
  return Chain;
}

//===----------------------------------------------------------------------===//
//               Return Value Calling Convention Implementation
//===----------------------------------------------------------------------===//

SDValue
ChinxTargetLowering::LowerReturn(SDValue Chain, CallingConv::ID CallConv,
                                 bool IsVarArg,
                                 const SmallVectorImpl<ISD::OutputArg> &Outs,
                                 const SmallVectorImpl<SDValue> &OutVals,
                                 const SDLoc &DL, SelectionDAG &DAG) const {
  // Standard return on Chinx is a "jr $ra"
  return DAG.getNode(ChinxISD::Ret, DL, MVT::Other, Chain, 
                     DAG.getRegister(Chinx::RA, MVT::i32));
}