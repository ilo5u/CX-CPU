//===-- ChinxMachineFunctionInfo.h - Private data used for Chinx ----*- C++ -*-=//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the Chinx specific subclass of MachineFunctionInfo.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_CHINX_CHINXMACHINEFUNCTION_H
#define LLVM_LIB_TARGET_CHINX_CHINXMACHINEFUNCTION_H

#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineMemOperand.h"
#include "llvm/CodeGen/PseudoSourceValue.h"
#include "llvm/Target/TargetFrameLowering.h"
#include "llvm/Target/TargetMachine.h"
#include <map>

namespace llvm {

/// ChinxFunctionInfo - This class is derived from MachineFunction private
/// Chinx target-specific information for each MachineFunction.
class ChinxFunctionInfo : public MachineFunctionInfo {
public:
  ChinxFunctionInfo(MachineFunction &MF)
      : MF(MF), VarArgsFrameIndex(0), MaxCallFrameSize(0) {}

  ~ChinxFunctionInfo();

  int getVarArgsFrameIndex() const { return VarArgsFrameIndex; }
  void setVarArgsFrameIndex(int Index) { VarArgsFrameIndex = Index; }

private:
  virtual void anchor();

  MachineFunction& MF;

  /// VarArgsFrameIndex - FrameIndex for start of varargs area.
  int VarArgsFrameIndex;

  unsigned MaxCallFrameSize;
};

} // end of namespace llvm

#endif
