//===-- ChinxCallingConv.td - Calling Conventions for Chinx --*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
// This describes the calling conventions for Chinx architecture.
//===----------------------------------------------------------------------===//

/// CCIfSubtarget - Match if the current subtarget has a feature F.
class CCIfSubtarget<string F, CCAction A>
    : CCIf<!strconcat(
			"State.getTarget().getSubtarget<ChinxSubtarget>().",
                      F),
           A>;

def CSR_O32 : CalleeSavedRegs<(add FP, RA,
    (sequence "S%u", 7, 0))>;

def RetCC_ChinxEABI : CallingConv<[
    // i32 are returned in registers V0, V1, A0, A1, A2, A3
    CCIfType<[i32], CCAssignToReg<[V0, V1, A0, A1, A2, A3]>>
]>;

def RetCC_Chinx : CallingConv<[
    CCDelegateTo<RetCC_ChinxEABI>
]>;