#ifndef LLVM_LIB_TARGET_CHINX_MCTARGETDESC_CHINXMCTARGETDESC_H
#define LLVM_LIB_TARGET_CHINX_MCTARGETDESC_CHINXMCTARGETDESC_H

#include "llvm/Support/DataTypes.h"

namespace llvm {
    class Target;
    class Triple;

    extern Target TheChinxTarget;
    extern Target TheChinxelTarget;
}

#define GET_REGINFO_ENUM
#include "ChinxGenRegisterInfo.inc"

#define GET_INSTRINFO_ENUM
#include "ChinxGenInstrInfo.inc"

#define GET_SUBTARGETINFO_ENUM
#include "ChinxGenSubtargetInfo.inc"

#endif