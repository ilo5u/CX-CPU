#ifndef LLVM_LIB_TARGET_CXC_MCTARGETDESC_CXCMCTARGETDESC_H
#define LLVM_LIB_TARGET_CXC_MCTARGETDESC_CXCMCTARGETDESC_H

#include "CXCConfig.h"
#include "llvm/Support/DataTypes.h"

namespace llvm {
    class Target;
    class Triple;

    extern Target TheCXCTarget;
    extern Target TheCXCelTarget;
}

#define GET_REGINFO_ENUM
#include "CXCGenRegisterInfo.inc"

#define GET_INSTRINFO_ENUM
#include "CXCGenInstrInfo.inc"

#define GET_SUBTARGETINFO_ENUM
#include "CXCGenSubtargetInfo.inc"

#endif