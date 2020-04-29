//===---- ChinxISelDAGToDAG.h - A Dag to Dag Inst Selector for Chinx --------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines an instruction selector for the CHINX target.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_CHINX_CHINXISELDAGTODAG_H
#define LLVM_LIB_TARGET_CHINX_CHINXISELDAGTODAG_H

#include "Chinx.h"
#include "ChinxSubtarget.h"
#include "ChinxTargetMachine.h"

#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/Debug.h"

//===----------------------------------------------------------------------===//
// Instruction Selector Implementation
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// ChinxDAGToDAGISel - CHINX specific code to select CHINX machine
// instructions for SelectionDAG operations.
//===----------------------------------------------------------------------===//
namespace llvm {

class ChinxDAGToDAGISel : public SelectionDAGISel {
public:
  explicit ChinxDAGToDAGISel(ChinxTargetMachine &TM, CodeGenOpt::Level OL)
      : SelectionDAGISel(TM, OL), Subtarget(nullptr) {}

  // Pass Name
  StringRef getPassName() const override {
    return "CHINX DAG->DAG Pattern Instruction Selection";
  }

  bool runOnMachineFunction(MachineFunction &MF) override;

protected:
  /// Keep a pointer to the ChinxSubtarget around so that we can make the right
  /// decision when generating code for different targets.
  const ChinxSubtarget *Subtarget;

private:
  // Include the pieces autogenerated from the target description.
  #include "ChinxGenDAGISel.inc"

  /// getTargetMachine - Return a reference to the TargetMachine, casted
  /// to the target-specific type.
  const ChinxTargetMachine &getTargetMachine() {
    return static_cast<const ChinxTargetMachine&>(TM);
  }
  
  // Complex Pattern
  bool SelectADDRls(SDNode *Parent, SDValue Addr, SDValue& Base, SDValue& Offset);

  bool SelectADDRio(SDValue Addr, SDValue &Base, SDValue &Offset);

  void Select(SDNode *N) override;

  bool trySelect(SDNode *Node);

  // getImm - Return a target constant with the specified value.
  inline SDValue getImm(const SDNode *Node, uint64_t Imm) {
    return CurDAG->getTargetConstant(Imm, SDLoc(Node), Node->getValueType(0));
  }

  void processFunctionAfterISel(MachineFunction &MF);

  // Insert instructions to initialize the global base register in the
  // first MBB of the function.
  // void initGlobalBaseReg(MachineFunction &MF);
};
FunctionPass *createChinxISelDag(ChinxTargetMachine &TM,
                                 CodeGenOpt::Level OptLevel);
}
#endif
