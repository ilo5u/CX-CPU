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
#include "MCTargetDesc/ChinxBaseInfo.h"
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

ChinxTargetLowering::ChinxTargetLowering(const ChinxTargetMachine &TM,
                                         const ChinxSubtarget &ST)
  : TargetLowering(TM), Subtarget(ST), ABI(TM.getABI()) {
  // set .align 2
  // it will emit .align 2 later
  setMinFunctionAlignment(2);

  // Set up the register classes
  addRegisterClass(MVT::i32, &Chinx::CPURegsRegClass);

  // must, computeRegisterProperties - Once all of the register classes are
  // added, this allow us to compute derived properties we expose.
  computeRegisterProperties(Subtarget.getRegisterInfo());
}

const ChinxTargetLowering *ChinxTargetLowering::create(const ChinxTargetMachine &TM,
                                                       const ChinxSubtarget &ST) {
  return new ChinxTargetLowering{TM, ST};
}

const char *ChinxTargetLowering::getTargetNodeName(unsigned Opcode) const {
  switch ((ChinxISD::NodeType)Opcode) {
  case ChinxISD::JmpLink:           return "ChinxISD::JmpLink";
  case ChinxISD::TailCall:          return "ChinxISD::TailCall";
  case ChinxISD::Hi:                return "ChinxISD::Hi";
  case ChinxISD::Lo:                return "ChinxISD::Lo";
  case ChinxISD::GPRel:             return "ChinxISD::GPRel";
  case ChinxISD::Ret:               return "ChinxISD::Ret";
  case ChinxISD::EH_RETURN:         return "ChinxISD::EH_RETURN";
  }
  return nullptr;
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
  MachineFunction &MF = DAG.getMachineFunction();
  // MachineFrameInfo *MFI = MF.getFrameInfo();
  ChinxFunctionInfo *ChinxFI = MF.getInfo<ChinxFunctionInfo>();

  ChinxFI->setVarArgsFrameIndex(0);

  // Assign locations to all of the incoming arguments.
  SmallVector<CCValAssign, 16> ArgLocs;
  CCState CCInfo(CallConv, IsVarArg, DAG.getMachineFunction(),
    ArgLocs, *DAG.getContext());
  ChinxCC ChinxCCInfo(CallConv, ABI.IsO32(), 
    CCInfo);

  ChinxFI->setFormalArgInfo(CCInfo.getNextStackOffset(),
    ChinxCCInfo.hasByValArg());

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
  SmallVector<CCValAssign, 16> RVLocs;
  MachineFunction& MF = DAG.getMachineFunction();

  CCState CCInfo(CallConv, IsVarArg, MF, RVLocs, *DAG.getContext());
  ChinxCC ChinxCCInfo(CallConv, ABI.IsO32(), CCInfo);
  ChinxCCInfo.analyzeReturn(Outs, Subtarget.abiUsesSoftFloat(),
    MF.getFunction().getReturnType());

  SDValue Flag;
  SmallVector<SDValue, 4> RetOps(1, Chain);

  for (unsigned i = 0; i != RVLocs.size(); ++i) {
    SDValue Val = OutVals[i];
    CCValAssign& VA = RVLocs[i];
    assert(VA.isRegLoc() && "Can only return in registers!");

    if (RVLocs[i].getValVT() != RVLocs[i].getLocVT())
      Val = DAG.getNode(ISD::BITCAST, DL, RVLocs[i].getLocVT(), Val);

    Chain = DAG.getCopyToReg(Chain, DL, VA.getLocReg(), Val, Flag);

    Flag = Chain.getValue(1);
    RetOps.push_back(DAG.getRegister(VA.getLocReg(), VA.getLocVT()));
  }

  if (MF.getFunction().hasStructRetAttr()) {
    ChinxFunctionInfo *ChinxFI = MF.getInfo<ChinxFunctionInfo>();
    unsigned Reg = ChinxFI->getSRetReturnReg();
    if (!Reg)
      llvm_unreachable("sret virtual register not created in the entry block");
    SDValue Val = DAG.getCopyFromReg(Chain, DL, Reg, getPointerTy(DAG.getDataLayout()));
    unsigned V0 = Chinx::V0;

    Chain = DAG.getCopyToReg(Chain, DL, V0, Val, Flag);
    Flag = Chain.getValue(1);
    RetOps.push_back(DAG.getRegister(V0, getPointerTy(DAG.getDataLayout())));
  }
  RetOps[0] = Chain;
  if (Flag.getNode())
    RetOps.push_back(Flag);
  // Standard return on Chinx is a "jr $ra"
  return DAG.getNode(ChinxISD::Ret, DL, MVT::Other, RetOps);
}

ChinxTargetLowering::ChinxCC::ChinxCC(CallingConv::ID CC, 
  bool IsO32_, CCState &Info,
  ChinxCC::SpecialCallingConvType SpecialCallingConv_)
    : CCInfo(Info), CallConv(CC), IsO32(IsO32_) {
  // Pre-allocate reserved argument area.
  CCInfo.AllocateStack(reservedArgArea(), 1);
}

template<typename Ty>
void ChinxTargetLowering::ChinxCC::
analyzeReturn(const SmallVectorImpl<Ty> &RetVals, bool IsSoftFloat,
              const SDNode *CallNode, const Type *RetTy) const {
  CCAssignFn *Fn;

  Fn = RetCC_Chinx;

  for (unsigned I = 0, E = RetVals.size(); I < E; ++I) {
    MVT VT = RetVals[I].VT;
    ISD::ArgFlagsTy Flags = RetVals[I].Flags;
    MVT RegVT = this->getRegVT(VT, RetTy, CallNode, IsSoftFloat);

    if (Fn(I, VT, RegVT, CCValAssign::Full, Flags, this->CCInfo)) {
#ifndef NDEBUG
      dbgs() << "Call result #" << I << " has unhandled type "
             << EVT(VT).getEVTString() << '\n';
#endif
      llvm_unreachable(nullptr);
    }
  }
}

void ChinxTargetLowering::ChinxCC::
analyzeCallResult(const SmallVectorImpl<ISD::InputArg> &Ins, bool IsSoftFloat,
                  const SDNode *CallNode, const Type *RetTy) const {
  analyzeReturn(Ins, IsSoftFloat, CallNode, RetTy);
}

void ChinxTargetLowering::ChinxCC::
analyzeReturn(const SmallVectorImpl<ISD::OutputArg> &Outs, bool IsSoftFloat,
              const Type *RetTy) const {
  analyzeReturn(Outs, IsSoftFloat, nullptr, RetTy);
}

unsigned ChinxTargetLowering::ChinxCC::reservedArgArea() const {
  return (IsO32 && (CallConv != CallingConv::Fast)) ? 8 : 0;
}

MVT ChinxTargetLowering::ChinxCC::getRegVT(MVT VT, const Type *OrigTy,
                                         const SDNode *CallNode,
                                         bool IsSoftFloat) const {
  return VT;
}
