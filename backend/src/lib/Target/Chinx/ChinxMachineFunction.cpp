//===-- ChinxMachineFunctionInfo.cpp - Private data used for Chinx ----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "ChinxMachineFunction.h"
#include "ChinxInstrInfo.h"
#include "ChinxSubtarget.h"

#include "llvm/IR/Function.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"

using namespace llvm;

bool FixGlobalBaseReg;

ChinxFunctionInfo::~ChinxFunctionInfo() {}

void ChinxFunctionInfo::anchor() {}
