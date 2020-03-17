//===-- ChinxSEFrameLowering.h - Chinx32/64 frame lowering --------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
//
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_CHINX_CHINXSEFRAMELOWERING_H
#define LLVM_LIB_TARGET_CHINX_CHINXSEFRAMELOWERING_H

#include "ChinxFrameLowering.h"

namespace llvm {

class ChinxSEFrameLowering : public ChinxFrameLowering {
public:
  explicit ChinxSEFrameLowering(const ChinxSubtarget &STI);

  /// emitProlog/emitEpilog - These methods insert prolog and epilog code into
  /// the function.
  void emitPrologue(MachineFunction &MF, MachineBasicBlock &MBB) const override;
  void emitEpilogue(MachineFunction &MF, MachineBasicBlock &MBB) const override;
};
} // End llvm namespace

#endif
