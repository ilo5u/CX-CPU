//===-- ChinxTargetMachine.cpp - Define TargetMachine for Chinx -------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Implements the info about Chinx target spec.
//
//===----------------------------------------------------------------------===//

#include "ChinxTargetMachine.h"
#include "Chinx.h"
#include "ChinxSubtarget.h"
#include "ChinxTargetObjectFile.h"
#include "ChinxISelDAGToDAG.h"

#include "llvm/IR/LegacyPassManager.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define DEBUG_TYPE "chinx"

extern "C" void LLVMInitializeChinxTarget() {
    // Register the target.
    RegisterTargetMachine<ChinxTargetMachine>
            X(getTheChinxTarget());
}

static std::string computeDataLayout(const Triple &TT, StringRef CPU,
                                     const TargetOptions &Options,
                                     bool isLittle) {
    std::string Ret = "";

    if (isLittle)
      Ret += "e";
    else
      Ret += "E";

    Ret += "-m:m";

    // Pointers are 32 bit on ABIs.
    Ret += "-p:32:32";

    // 8 and 16 bit integers only need to have natural alignment, but try to
    // align them to 32 bits. 64 bit integers have natural alignment.
    Ret += "-i8:8:32-i16:16:32-i64:64";

    // 32 bit registers are always available and the stack is at least 64 bit
    // aligned.
    Ret += "-n32-S64";

  return Ret;
}

static Reloc::Model getEffectiveRelocModel(bool JIT,
                                           Optional<Reloc::Model> RM) {
    if (!RM.hasValue() || JIT)
        return Reloc::Static;
    return *RM;
}

static CodeModel::Model getEffectiveCodeModel(Optional<CodeModel::Model> CM) {
  if (CM)
    return *CM;
  return CodeModel::Small;
}

// On function prologue, the stack is created by decrementing
// its pointer. Once decremented, all references are done with positive
// offset from the stack/frame pointer, using StackGrowsUp enables
// an easier handling.
// Using CodeModel::Large enables different CALL behavior.
ChinxTargetMachine::ChinxTargetMachine(const Target &T, const Triple &TT, StringRef CPU,
                    StringRef FS, const TargetOptions &Options,
                    Optional<Reloc::Model> RM, Optional<CodeModel::Model> CM,
                    CodeGenOpt::Level OL, bool JIT)
    : LLVMTargetMachine(T, computeDataLayout(TT, CPU, Options, true), TT,
                        CPU, FS, Options, getEffectiveRelocModel(JIT, RM),
                        getEffectiveCodeModel(CM), OL),
      TLOF(make_unique<ChinxTargetObjectFile>()),
      ABI(ChinxABIInfo::computeTargetABI()),
      Subtarget(TT, CPU, FS, true, *this) {
    initAsmInfo();
}

ChinxTargetMachine::~ChinxTargetMachine() {}

const ChinxSubtarget *
ChinxTargetMachine::getSubtargetImpl(const Function &F) const {
  Attribute CPUAttr = F.getFnAttribute("target-cpu");
  Attribute FSAttr = F.getFnAttribute("target-features");

  std::string CPU = !CPUAttr.hasAttribute(Attribute::None)
                        ? CPUAttr.getValueAsString().str()
                        : TargetCPU;
  std::string FS = !FSAttr.hasAttribute(Attribute::None)
                       ? FSAttr.getValueAsString().str()
                       : TargetFS;

  auto &I = SubtargetMap[CPU + FS];
  if (!I) {
    // This needs to be done before we create a new subtarget since any
    // creation will depend on the TM and the code generation flags on the
    // function that reside in TargetOptions.
    resetTargetOptions(F);
    I = llvm::make_unique<ChinxSubtarget>(TargetTriple, CPU, FS, true,
                                          *this);
  }
  return I.get();
}

namespace {
/// Chinx Code Generator Pass Configuration Options.
class ChinxPassConfig : public TargetPassConfig {
public:
  ChinxPassConfig(ChinxTargetMachine &TM, PassManagerBase &PM)
    : TargetPassConfig(TM, PM) {}

  ChinxTargetMachine &getChinxTargetMachine() const {
    return getTM<ChinxTargetMachine>();
  }

  const ChinxSubtarget &getChinxSubtarget() const {
    return *getChinxTargetMachine().getSubtargetImpl();
  }

  bool addInstSelector() override;
};

// Install an instruction select pass using the ISelDag to gen Chinx code.
bool ChinxPassConfig::addInstSelector() {
  addPass(createChinxISelDag(getChinxTargetMachine(), getOptLevel()));
  return false;
}
} // namespace

TargetPassConfig *ChinxTargetMachine::createPassConfig(PassManagerBase &PM) {
  return new ChinxPassConfig(*this, PM);
}

