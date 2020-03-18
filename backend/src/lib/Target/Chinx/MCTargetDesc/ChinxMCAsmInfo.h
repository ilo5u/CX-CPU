//===-- ChinxMCAsmInfo.h - Chinx Asm Info ------------------------*- C++ -*--===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the declaration of the ChinxMCAsmInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_CHINX_MCTARGETDESC_CHINXMCASMINFO_H
#define LLVM_LIB_TARGET_CHINX_MCTARGETDESC_CHINXMCASMINFO_H

#include "llvm/MC/MCAsmInfoELF.h"

namespace llvm {
class Triple;

class ChinxMCAsmInfo : public MCAsmInfoELF {
  void anchor() override;

public:
  explicit ChinxMCAsmInfo(const Triple &TheTriple);
};

} // namespace llvm

#endif
