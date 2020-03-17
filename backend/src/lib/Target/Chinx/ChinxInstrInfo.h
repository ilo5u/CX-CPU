//===-- ChinxInstrInfo.h - Chinx Instruction Information ----------*- C++ -*-===//
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

#ifndef LLVM_LIB_TARGET_CHINX_CHINXINSTRINFO_H
#define LLVM_LIB_TARGET_CHINX_CHINXINSTRINFO_H

#include "Chinx.h"
#include "ChinxRegisterInfo.h"

#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/Target/TargetInstrInfo.h"

#define GET_INSTRINFO_HEADER
#include "ChinxGenInstrInfo.inc"

namespace llvm {
class ChinxInstrInfo : public ChinxGenInstrInfo {
  virtual void anchor();

protected:
  const ChinxSubtarget &Subtarget;

public:
  explicit ChinxInstrInfo(const ChinxSubtarget &STI);

  static const ChinxInstrInfo *create(ChinxSubtarget &STI);

  /// getRegisterInfo - TargetInstrInfo is a superset of MRegister info.  As
  /// such, whenever a client has an instance of instruction info, it should
  /// always be able to get register info as well (through this method).
  ///
  virtual const ChinxRegisterInfo &getRegisterInfo() const = 0;

  /// Return the number of bytes of code the specified instruction may be.
  unsigned GetInstSizeInBytes(const MachineInstr &MI) const;
};

/// Create ChinxInstrInfo objects.
const ChinxInstrInfo *createChinxSEInstrInfo(const ChinxSubtarget &STI);
}

#endif
