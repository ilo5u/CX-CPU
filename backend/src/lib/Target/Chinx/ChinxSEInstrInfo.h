//===-- ChinxSEInstrInfo.h - Chinx Instruction Information ---*- C++ -*-===//
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

#ifndef LLVM_LIB_TARGET_CHINX_CHINXSEINSTRINFO_H
#define LLVM_LIB_TARGET_CHINX_CHINXSEINSTRINFO_H

#include "ChinxInstrInfo.h"
#include "ChinxSERegisterInfo.h"
#include "ChinxMachineFunction.h"

namespace llvm {

class ChinxSEInstrInfo : public ChinxInstrInfo {
  const ChinxSERegisterInfo RI;

public:
  explicit ChinxSEInstrInfo(const ChinxSubtarget &STI);

  const ChinxRegisterInfo &getRegisterInfo() const override;
};

}

#endif
