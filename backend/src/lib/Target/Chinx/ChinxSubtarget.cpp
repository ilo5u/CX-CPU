//===-- ChinxSubtarget.cpp - Chinx Subtarget Information --------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the Chinx specific subclass of TargetSubtargetInfo.
//
//===----------------------------------------------------------------------===//

#include "ChinxSubtarget.h"
#include "ChinxMachineFunction.h"
#include "Chinx.h"
#include "ChinxRegisterInfo.h"
#include "ChinxTargetMachine.h"

#include "llvm/IR/Attributes.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define DEBUG_TYPE "chinx-subtarget"

#define GET_SUBTARGETINFO_TARGET_DESC
#define GET_SUBTARGETINFO_CTOR
#include "ChinxGenSubtargetInfo.inc"

void ChinxSubtarget::anchor() {}

ChinxSubtarget::ChinxSubtarget(const Triple &TT, const std::string &CPU,
                               const std::string &FS, bool little,
                               const ChinxTargetMachine &TM)
    : ChinxGenSubtargetInfo(TT, CPU, FS), IsLittle(little),
      ChinxFeatureVersion(Chinx1), ChinxArchVersion(ChinxDefault),
      TM(TM), TargetTriple(TT), TSInfo(),
      InstrInfo(
          ChinxInstrInfo::create(initializeSubtargetDependencies(CPU, FS, TM))
      ), FrameLowering(ChinxFrameLowering::create(*this)),
      TLInfo(ChinxTargetLowering::create(TM, *this)) {}

bool ChinxSubtarget::isPositionIndependent() const {
  return TM.isPositionIndependent();
}

ChinxSubtarget &
ChinxSubtarget::initializeSubtargetDependencies(StringRef CPU, StringRef FS,
                                                const TargetMachine &TM) {
  if (TargetTriple.getArch() == Triple::chinx) {
    if (CPU.empty() || CPU == "generic") {
      CPU = "chinxII";
    }
    else if (CPU == "help") {
      CPU = "";
      return *this;
    }
    else if (CPU != "chinxI" && CPU != "chinxII") {
      CPU = "chinxII";
    }
  }
  else
  {
    errs() << "!!!Error, TargetTriple.getArch() = " << TargetTriple.getArch()
           << "CPU = " << CPU << "\n";
    exit(0);
  }

  if (CPU == "chinxI")
    ChinxArchVersion = ChinxI;
  else if (CPU == "chinxII")
    ChinxArchVersion = ChinxII;

  if (isChinxI()) {
    HasPush = true;
    HasCall = false;
  }
  else if (isChinxII()) {
    HasPush = true;
    HasCall = true;
  }
  else {
    errs() << "-mcpu must be empty(default:chinxII), chinxI or chinxII" << "\n";
  }

  // Parse features string.
  ParseSubtargetFeatures(CPU, FS);
  // Initialize scheduling itinerary for the specified CPU.
  InstrItins = getInstrItineraryForCPU(CPU);

  return *this;
}

bool ChinxSubtarget::abiUsesSoftFloat() const {
  return true;
}

const ChinxABIInfo &ChinxSubtarget::getABI() const { 
  return TM.getABI(); 
}
