//===-- ChinxBaseInfo.h - Top level definitions for CHINX MC ------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains small standalone helper functions and enum definitions for
// the Chinx target useful for the compiler back-end and the MC libraries.
//
//===----------------------------------------------------------------------===//
#ifndef LLVM_LIB_TARGET_CHINX_MCTARGETDESC_CHINXBASEINFO_H
#define LLVM_LIB_TARGET_CHINX_MCTARGETDESC_CHINXBASEINFO_H

#include "ChinxMCTargetDesc.h"

#include "llvm/MC/MCExpr.h"
#include "llvm/Support/DataTypes.h"
#include "llvm/Support/ErrorHandling.h"

namespace llvm {

/// ChinxII - This namespace holds all of the target specific flags that
/// instruction info tracks.
///
namespace ChinxII {
  /// Target Operand Flag enum.
  enum TOF {
    //===------------------------------------------------------------------===//
    // Chinx Specific MachineOperand flags.

    MO_NO_FLAG,

    /// MO_GOT_CALL - Represents the offset into the global offset table at
    /// which the address of a call site relocation entry symbol resides
    /// during execution. This is different from the above since this flag
    /// can only be present in call instructions.
    MO_GOT_CALL,

    /// MO_GPREL - Represents the offset from the current gp value to be used
    /// for the relocatable object file being produced.
    MO_GPREL,

    /// MO_ABS_HI/LO - Represents the hi or low part of an absolute symbol
    /// address.
    MO_ABS_HI,
    MO_ABS_LO,

    /// MO_GOT_HI16/LO16, MO_CALL_HI16/LO16 - Relocations used for large GOTs.
    MO_GOT_HI16,
    MO_GOT_LO16
  };

  enum {
    //===------------------------------------------------------------------===//
    // Instruction encodings.  These are the standard/most common forms for
    // Chinx instructions.
    //

    // Pseudo - This represents an instruction that is a pseudo instruction
    // or one that has not been implemented yet.  It is illegal to code generate
    // it, but tolerated for intermediate implementation stages.
    Pseudo   = 0,

    /// FrmR - This form is for instructions of the format R.
    FrmR  = 1,
    /// FrmI - This form is for instructions of the format I.
    FrmI  = 2,
    /// FrmJ - This form is for instructions of the format J.
    FrmJ  = 3,
    /// FrmFR - This form is for instructions of the format FR.
    FrmFR = 4,
    /// FrmFI - This form is for instructions of the format FI.
    FrmFI = 5,
    /// FrmOther - This form is for instructions that have no specific format.
    FrmOther = 6,

    FormMask = 15
  };
}
}

#endif
