//===-- ChinxISelLowering.h - Chinx DAG Lowering Interface --------*- C++ -*-===//
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

#ifndef LLVM_LIB_TARGET_CHINX_CHINXISELLOWERING_H
#define LLVM_LIB_TARGET_CHINX_CHINXISELLOWERING_H

#include "MCTargetDesc/ChinxABIInfo.h"
#include "Chinx.h"
#include "ChinxRegisterInfo.h"

#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/IR/Function.h"
#include "llvm/CodeGen/TargetLowering.h"
#include <deque>

namespace llvm {
  namespace ChinxISD {
    enum NodeType : unsigned {
      // Start the numbering from where ISD NodeType finishes.
      FIRST_NUMBER = ISD::BUILTIN_OP_END,
      // Jump and link (call)
      JmpLink,
      // Tail call
      TailCall,
      // Get the Higher 16 bits from a 32-bit immediate
      // No relation with Chinx Hi register
      Hi,
      // Get the Lower 16 bits from a 32-bit immediate
      // No relation with Chinx Lo register
      Lo,
      // Handle gp_rel (small data/bss sections) relocation.
      GPRel,
      // Thread Pointer
      ThreadPointer,
      // Return
      Ret,
      // Software Exception Return.
      EH_RETURN,
      // Node used to extract integer from accumulator.
      MFHI,
      MFLO,
      // Mul nodes.
      Mul,
      Wrapper,
      DynAlloc,
      Sync
    };
  }

  //===--------------------------------------------------------------------===//
  // TargetLowering Implementation
  //===--------------------------------------------------------------------===//
  class ChinxFunctionInfo;
  class ChinxSubtarget;

  // @class ChinxTargetLowering
  class ChinxTargetLowering : public TargetLowering  {
  public:
    explicit ChinxTargetLowering(const ChinxTargetMachine &TM,
                                 const ChinxSubtarget &ST);

    static const ChinxTargetLowering *create(const ChinxTargetMachine &TM,
                                             const ChinxSubtarget &ST);

    /// getTargetNodeName - This method returns the name of a target specific
    //  DAG node.
    const char *getTargetNodeName(unsigned Opcode) const override;

    SDValue LowerReturn(SDValue Chain,
                        CallingConv::ID CallConv, bool IsVarArg,
                        const SmallVectorImpl<ISD::OutputArg> &Outs,
                        const SmallVectorImpl<SDValue> &OutVals,
                        const SDLoc &dl, SelectionDAG &DAG) const override;
    
    // SDValue PerformDAGCombine(SDNode *N, DAGCombinerInfo &DCI) const override;
  protected:
    // ByValArgInfo - ByVal argument information.
    struct ByValArgInfo {
      unsigned FirstIdx; // Index of the first register used.
      unsigned NumRegs; // Number of registers used for this argument.
      unsigned Address; // Offset of the stack area used to pass this argument.

      ByValArgInfo() : FirstIdx(0), NumRegs(0), Address(0) {}
    };

  protected:
    // Subtarget Info
    const ChinxSubtarget &Subtarget;
    // Cache the ABI from the TargetMachine, we use it everywhere.
    const ChinxABIInfo &ABI;

 class ChinxCC {
    public:
    enum SpecialCallingConvType {
      NoSpecialCallingConv
    };

    ChinxCC(CallingConv::ID CallConv, bool IsO32, CCState& Info,
      SpecialCallingConvType SpecialCallingConv = NoSpecialCallingConv);

    void analyzeCallResult(const SmallVectorImpl<ISD::InputArg>& Ins,
      bool IsSoftFloat, const SDNode *CallNode, const Type *RetTy) const;

    void analyzeReturn(const SmallVectorImpl<ISD::OutputArg>& Outs,
      bool IsSoftFloat, const Type *RetTy) const;

    const CCState& getCCInfo() const { return CCInfo; }

    bool hasByValArg() const { return !ByValArgs.empty(); }

    unsigned reservedArgArea() const;

    typedef SmallVectorImpl<ByValArgInfo>::const_iterator byval_iterator;
    byval_iterator byval_begin() const { return ByValArgs.begin(); }
    byval_iterator byval_end() const { return ByValArgs.end(); }

    private:
    MVT getRegVT(MVT VT, const Type *OrigTy, const SDNode *CallNode,
      bool IsSoftFloat) const;

    template<typename Ty>
    void analyzeReturn(const SmallVectorImpl<Ty>& RetVals, bool IsSoftFloat, 
      const SDNode* CallNode, const Type *RetTy) const;

    CCState& CCInfo;
    CallingConv::ID CallConv;
    bool IsO32;
    SmallVector<ByValArgInfo, 2> ByValArgs;
  };

  private:
    // Lower Operand specifics
    SDValue lowerGlobalAddress(SDValue Op, SelectionDAG &DAG) const;

    // must be exist even without function call
    SDValue LowerFormalArguments(SDValue Chain,
                                 CallingConv::ID CallConv, bool IsVarArg,
                                 const SmallVectorImpl<ISD::InputArg> &Ins,
                                 const SDLoc &dl, SelectionDAG &DAG,
                                 SmallVectorImpl<SDValue> &InVals) const override;
  };
}

#endif
