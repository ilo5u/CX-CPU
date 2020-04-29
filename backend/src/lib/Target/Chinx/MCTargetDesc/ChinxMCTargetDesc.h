#ifndef LLVM_LIB_TARGET_CHINX_MCTARGETDESC_CHINXMCTARGETDESC_H
#define LLVM_LIB_TARGET_CHINX_MCTARGETDESC_CHINXMCTARGETDESC_H

#include "llvm/Support/DataTypes.h"

namespace llvm {
    class MCAsmBackend;
    class MCCodeEmitter;
    class MCContext;
    class MCInstrInfo;
    class MCObjectWriter;
    class MCRegisterInfo;
    class MCSubtargetInfo;
    class StringRef;
    class raw_ostream;
    class Target;
    class Triple;

	Target &getTheChinxTarget();
}

#define GET_REGINFO_ENUM
#include "ChinxGenRegisterInfo.inc"

#define GET_INSTRINFO_ENUM
#include "ChinxGenInstrInfo.inc"

#define GET_SUBTARGETINFO_ENUM
#include "ChinxGenSubtargetInfo.inc"

#endif