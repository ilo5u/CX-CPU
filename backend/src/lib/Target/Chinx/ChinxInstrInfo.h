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
#include "ChinxAnalyzeImmediate.h"
#include "ChinxRegisterInfo.h"

#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/Target/TargetInstrInfo.h"

#define GET_INSTRINFO_HEADER
#include "ChinxGenInstrInfo.inc"

namespace llvm {
class ChinxInstrInfo : public ChinxGenInstrInfo {
  virtual void anchor();
  const ChinxRegisterInfo RI;

protected:
  const ChinxSubtarget &Subtarget;

public:
  explicit ChinxInstrInfo(const ChinxSubtarget &ST);

  static const ChinxInstrInfo *create(ChinxSubtarget &ST);

  /// getRegisterInfo - TargetInstrInfo is a superset of MRegister info.  As
  /// such, whenever a client has an instance of instruction info, it should
  /// always be able to get register info as well (through this method).
  ///
  const ChinxRegisterInfo &getRegisterInfo() const;

  /// Return the number of bytes of code the specified instruction may be.
  unsigned GetInstSizeInBytes(const MachineInstr &MI) const;

  void storeRegToStackSlot(MachineBasicBlock &MBB,
    MachineBasicBlock::iterator MBBI,
    unsigned SrcReg, bool isKill, int FrameIndex,
    const TargetRegisterClass *RC,
    const TargetRegisterInfo *TRI) const {
    storeRegToStack(MBB, MBBI, SrcReg, isKill, FrameIndex, RC, TRI, 0);
  }

  void loadRegFromStackSlot(MachineBasicBlock &MBB,
    MachineBasicBlock::iterator MBBI,
    unsigned DestReg, int FrameIndex,
    const TargetRegisterClass *RC,
    const TargetRegisterInfo *TRI) const {
    loadRegFromStack(MBB, MBBI, DestReg, FrameIndex, RC, TRI, 0);
  }

  void storeRegToStack(MachineBasicBlock &MBB,
    MachineBasicBlock::iterator MI,
    unsigned SrcReg, bool isKill, int FrameIndex,
    const TargetRegisterClass *RC,
    const TargetRegisterInfo *TRI,
    int64_t Offset) const;

  void loadRegFromStack(MachineBasicBlock &MBB,
    MachineBasicBlock::iterator MI,
    unsigned DestReg, int FrameIndex,
    const TargetRegisterClass *TRC,
    const TargetRegisterInfo *TRI,
    int64_t Offset) const;

  bool expandPostRAPseudo(MachineInstr &MI) const;

  void adjustStackPtr(unsigned SP, int64_t Amount,
    MachineBasicBlock &MBB,
    MachineBasicBlock::iterator I) const;

  /// Emit a series of instructions to load an immediate. If NewImm is a
  /// non-NULL parameter, the last instruction is not emitted, but instead
  /// its immediate operand is returned in NewImm.
  unsigned loadImmediate(int64_t Imm, MachineBasicBlock &MBB,
	  MachineBasicBlock::iterator II, const DebugLoc &DL, unsigned *NewImm) const;

protected:
  MachineMemOperand *GetMemOperand(MachineBasicBlock &MBB, int FI,
    MachineMemOperand::Flags Flags) const;

private:
	void expandRetRA(MachineBasicBlock &MBB, MachineBasicBlock::iterator I) const;
};
}

#endif
