//===-- ChinxSERegisterInfo.h - Chinx Register Information ---*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the Chinx implementation of the TargetRegisterInfo
// class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_CHINX_CHINXSEREGISTERINFO_H
#define LLVM_LIB_TARGET_CHINX_CHINXSEREGISTERINFO_H

#include "ChinxRegisterInfo.h"

namespace llvm {
class ChinxSEInstrInfo;

class ChinxSERegisterInfo : public ChinxRegisterInfo {
public:
  ChinxSERegisterInfo(const ChinxSubtarget &ST);

  const TargetRegisterClass *intRegClass(unsigned Size) const override;
};

} // end namespace llvm

#endif
