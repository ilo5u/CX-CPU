//===-- ChinxSEISelDAGToDAG.h - A Dag to Dag Inst Selector for ChinxSE -----===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Subclass of ChinxDAGToDAGISel specialized for chinx.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_CHINX_CHINXSEISELDAGTODAG_H
#define LLVM_LIB_TARGET_CHINX_CHINXSEISELDAGTODAG_H

#include "ChinxISelDAGToDAG.h"

namespace llvm {

class ChinxSEDAGToDAGISel : public ChinxDAGToDAGISel {

public:
  explicit ChinxSEDAGToDAGISel(ChinxTargetMachine &TM, CodeGenOpt::Level OL)
      : ChinxDAGToDAGISel(TM, OL) {}

private:

  bool runOnMachineFunction(MachineFunction &MF) override;

  bool trySelect(SDNode *Node) override;

  void processFunctionAfterISel(MachineFunction &MF) override;

  // Insert instructions to initialize the global base register in the
  // first MBB of the function.
  void initGlobalBaseReg(MachineFunction &MF);
};

FunctionPass *createChinxSEISelDag(ChinxTargetMachine &TM,
                                   CodeGenOpt::Level OptLevel);
}

#endif
