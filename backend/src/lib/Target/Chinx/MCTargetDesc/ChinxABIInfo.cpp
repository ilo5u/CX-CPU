//===---- ChinxABIInfo.cpp - Information about CHINX ABI's ------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "ChinxABIInfo.h"
#include "ChinxRegisterInfo.h"

#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/MC/MCTargetOptions.h"
#include "llvm/Support/CommandLine.h"

using namespace llvm;

static cl::opt<bool>
EnableChinx32Calls("chinx-s32-calls", cl::Hidden,
                   cl::desc("CHINX S32 call: use stack only to pass arguments."),
                   cl::init(false));

namespace {
static const MCPhysReg O32IntRegs[4] = {Chinx::A0, Chinx::A1, Chinx::A2, Chinx::A3};

static const MCPhysReg S32IntRegs = {};
}

const ArrayRef<MCPhysReg> ChinxABIInfo::GetByValArgRegs() const {
  if (IsO32())
    return makeArrayRef(O32IntRegs);
  if (IsS32())
    return makeArrayRef(S32IntRegs);
  llvm_unreachable("Unhandled ABI");
}

const ArrayRef<MCPhysReg> ChinxABIInfo::GetVarArgRegs() const {
  if (IsO32())
    return makeArrayRef(O32IntRegs);
  if (IsS32())
    return makeArrayRef(S32IntRegs);
  llvm_unreachable("Unhandled ABI");
}

unsigned ChinxABIInfo::GetCalleeAllocdArgSizeInBytes(CallingConv::ID CC) const {
  if (IsO32())
    return CC != 0;
  if (IsS32())
    return 0;
  llvm_unreachable("Unhandled ABI");
}

ChinxABIInfo ChinxABIInfo::computeTargetABI() {
  ChinxABIInfo abi(ABI::Unknown);
  if (EnableChinx32Calls)
    abi = ABI::S32;
  else
    abi = ABI::O32;
  // Assert exactly one ABI was chosen.
  assert(abi.ThisABI != ABI::Unknown);
  return abi;
}

unsigned ChinxABIInfo::GetStackPtr() const {
  return Chinx::SP;
}

unsigned ChinxABIInfo::GetFramePtr() const {
  return Chinx::FP;
}

unsigned ChinxABIInfo::GetNullPtr() const {
  return Chinx::ZERO;
}

unsigned ChinxABIInfo::GetEhDataReg(unsigned I) const {
  static const unsigned EhDataReg[] = {
    Chinx::A0, Chinx::A1, Chinx::A2, Chinx::A3
  };

  return EhDataReg[I];
}

int ChinxABIInfo::EhDataRegSize() const {
  if (ThisABI == ABI::S32)
    return 0;
  else
    return 4;
}
