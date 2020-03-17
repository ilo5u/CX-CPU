//===-- ChinxFrameLowering.h - Define frame lowering for Chinx ----*- C++ -*-===//
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

#ifndef LLVM_LIB_TARGET_CHINX_CHINXFRAMELOWERING_H
#define LLVM_LIB_TARGET_CHINX_CHINXFRAMELOWERING_H

#include "Chinx.h"
#include "llvm/Target/TargetFrameLowering.h"

namespace llvm {
    class ChinxSubtarget;

class ChinxFrameLowering : public TargetFrameLowering {
protected:
    const ChinxSubtarget &STI;

public:
    explicit ChinxFrameLowering(const ChinxSubtarget &sti, unsigned Alignment)
            : TargetFrameLowering(StackGrowsDown, Alignment, 0, Alignment), STI(sti) {}

  static const ChinxFrameLowering *create(const ChinxSubtarget &ST);

  bool hasFP(const MachineFunction &MF) const override;
};

/// Create ChinxFrameLowering objects.
const ChinxFrameLowering *createChinxSEFrameLowering(const ChinxSubtarget &ST);

} // End llvm namespace

#endif
