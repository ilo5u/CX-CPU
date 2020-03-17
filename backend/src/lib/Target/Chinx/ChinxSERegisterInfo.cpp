//===-- ChinxSERegisterInfo.cpp - CHINX Register Information -== -------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the CHINX implementation of the TargetRegisterInfo
// class.
//
//===----------------------------------------------------------------------===//

#include "ChinxSERegisterInfo.h"

using namespace llvm;

#define DEBUG_TYPE "chinx-reg-info"

ChinxSERegisterInfo::ChinxSERegisterInfo(const ChinxSubtarget &ST)
  : ChinxRegisterInfo(ST) {}

const TargetRegisterClass *
ChinxSERegisterInfo::intRegClass(unsigned Size) const {
  return &Chinx::CPURegsRegClass;
}