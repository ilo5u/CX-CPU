#include "ChinxMCTargetDesc.h"

#include "llvm/MC/MachineLocation.h"
#include "llvm/MC/MCELFStreamer.h"
#include "llvm/MC/MCInstrAnalysis.h"
#include "llvm/MC/MCInstPrinter.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/FormattedStream.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define GET_INSTRINFO_MC_DESC
#include "ChinxGenInstrInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "ChinxGenSubtargetInfo.inc"

#define GET_REGINFO_MC_DESC
#include "ChinxGenRegisterInfo.inc"

extern "C" void LLVMInitializeChinxTargetMC() {

}