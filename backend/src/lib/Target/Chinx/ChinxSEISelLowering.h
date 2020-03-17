//===-- ChinxSEISelLowering.h - ChinxSE DAG Lowering Interface ----*- C++ -*-===//
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

#ifndef LLVM_LIB_TARGET_CHINX_CHINXSEISELLOWERING_H
#define LLVM_LIB_TARGET_CHINX_CHINXSEISELLOWERING_H

#include "ChinxISelLowering.h"
#include "ChinxRegisterInfo.h"

namespace llvm {
  class ChinxSETargetLowering : public ChinxTargetLowering  {
  public:
    explicit ChinxSETargetLowering(const ChinxTargetMachine &TM,
                                   const ChinxSubtarget &STI);

    SDValue LowerOperation(SDValue Op, SelectionDAG &DAG) const override;
  };
}

#endif
