//===-- ChinxTargetMachine.h - Define TargetMachine for Chinx -----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the Chinx specific subclass of TargetMachine.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_CHINX_CHINXTARGETMACHINE_H
#define LLVM_LIB_TARGET_CHINX_CHINXTARGETMACHINE_H

#include "MCTargetDesc/ChinxABIInfo.h"
#include "ChinxSubtarget.h"

#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/CodeGen/TargetFrameLowering.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {
class formatted_raw_ostream;
class ChinxRegisterInfo;

class ChinxTargetMachine : public LLVMTargetMachine {
  bool isLittle;
  std::unique_ptr<TargetLoweringObjectFile> TLOF;
  // Selected ABI
  ChinxABIInfo ABI;

  // This oject will be used in several files, e.g. ChinxRegisterInfo
  ChinxSubtarget Subtarget;

  mutable StringMap<std::unique_ptr<ChinxSubtarget>> SubtargetMap;

public:
  ChinxTargetMachine(const Target &T, const Triple &TT, StringRef CPU,
                     StringRef FS, const TargetOptions &Options,
                     Optional<Reloc::Model> RM, Optional<CodeModel::Model> CM,
                     CodeGenOpt::Level OL, bool JIT, bool isLittle);
  ~ChinxTargetMachine() override;

  const ChinxSubtarget *getSubtargetImpl() const {
    return &Subtarget;
  }

  const ChinxSubtarget *getSubtargetImpl(const Function &F) const override;

  // Pass Pipeline Configuration
  TargetPassConfig *createPassConfig(PassManagerBase &PM) override;

  TargetLoweringObjectFile *getObjFileLowering() const override {
    return TLOF.get();
  }

  bool isLittleEndian() const { return true; }
  const ChinxABIInfo &getABI() const { return ABI; }
};

class ChinxebTargetMachine : public ChinxTargetMachine {
    virtual void anchor();
public:
    ChinxebTargetMachine(const Target &T, const Triple &TT, StringRef CPU,
                         StringRef FS, const TargetOptions &Options,
                         Optional<Reloc::Model> RM,
                         Optional<CodeModel::Model> CM, CodeGenOpt::Level OL,
                         bool JIT);
};

class ChinxelTargetMachine : public ChinxTargetMachine {
    virtual void anchor();
public:
    ChinxelTargetMachine(const Target &T, const Triple &TT, StringRef CPU,
                         StringRef FS, const TargetOptions &Options,
                         Optional<Reloc::Model> RM,
                         Optional<CodeModel::Model> CM, CodeGenOpt::Level OL,
                         bool JIT);
};
} // End llvm namespace

#endif
