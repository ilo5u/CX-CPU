#include "ChinxMCTargetDesc.h"
#include "InstPrinter/ChinxInstPrinter.h"
#include "ChinxMCAsmInfo.h"

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

/// select the Chinx Architecture Feature for the given triple and cpu name.
/// The function will be called at command 'llvm-objdump -d' for Chinx elf input.
static StringRef selectChinxArchFeature(const Triple& TT, StringRef CPU) {
    std::string ChinxArchFeature;
    if (CPU.empty() || CPU == "generic") {
        if (TT.getArch() == Triple::chinx || TT.getArch() == Triple::chinxel) {
            if (CPU.empty() || CPU == "chinxII") {
                ChinxArchFeature = "+chinxII";
            } else {
                if (CPU == "chinxI") {
                    ChinxArchFeature = "+chinxI";
                }
            }
        }
    }
    return ChinxArchFeature;
}

static MCInstrInfo * createChinxMCInstrInfo() {
	MCInstrInfo *X = new MCInstrInfo();
	InitChinxMCInstrInfo(X);
	return X;
}

static MCRegisterInfo * createChinxMCRegisterInfo(const Triple& TT) {
    MCRegisterInfo *X = new MCRegisterInfo();
    InitChinxMCRegisterInfo(X, Chinx::K1); // defined in ChinxGenRegisterInfo.inc
    return X;
}

static MCSubtargetInfo * createChinxMCSubtargetInfo(const Triple& TT,
                                                    StringRef CPU, StringRef FS) {
    std::string ArchFS = selectChinxArchFeature(TT, CPU);
    if (!FS.empty()) {
        if (!ArchFS.empty())
            ArchFS = ArchFS + "," + FS.str();
        else
            ArchFS = FS;
    }
    // createChinxMCSubtargetInfoImpl defined in ChinxGenSubtargetInfo.inc
    return createChinxMCSubtargetInfoImpl(TT, CPU, ArchFS);
}

static MCAsmInfo * createChinxMCAsmInfo(const MCRegisterInfo& MRI,
                                        const Triple& TT) {
    MCAsmInfo * MAI = new ChinxMCAsmInfo(TT);
    unsigned SP = MRI.getDwarfRegNum(Chinx::SP, true);
    MCCFIInstruction Inst = MCCFIInstruction::createDefCfa(nullptr, SP, 0);
    MAI->addInitialFrameState(Inst);
    return MAI;
}

static MCInstPrinter * createChinxMCInstPrinter(const Triple& T,
                                                unsigned SyntaxVariant,
                                                const MCAsmInfo& MAI,
                                                const MCInstrInfo& MII,
                                                const MCRegisterInfo& MRI) {
    return new ChinxInstPrinter(MAI, MII, MRI);
}

namespace {
    class ChinxMCInstrAnalysis : public MCInstrAnalysis {
        public:
        ChinxMCInstrAnalysis(const MCInstrInfo *Info) : MCInstrAnalysis(Info) {}
    };
}

static MCInstrAnalysis *createChinxMCInstrAnalysis(const MCInstrInfo *Info) {
    return new ChinxMCInstrAnalysis(Info);
}

extern "C" void LLVMInitializeChinxTargetMC() {
    for (Target *T : {&TheChinxTarget, &TheChinxelTarget}) {
        // Register the MC asm info.
        RegisterMCAsmInfoFn X(*T, createChinxMCAsmInfo);

        // Register the MC instruction info.
        TargetRegistry::RegisterMCInstrInfo(*T, createChinxMCInstrInfo);

        // Register the MC register info.
        TargetRegistry::RegisterMCRegInfo(*T, createChinxMCRegisterInfo);

        // Register the MC subtarget info.
        TargetRegistry::RegisterMCSubtargetInfo(*T, createChinxMCSubtargetInfo);

        // Register the MC instruction analyzer.
        TargetRegistry::RegisterMCInstrAnalysis(*T, createChinxMCInstrAnalysis);

        // Register the MCInstPrinter.
        TargetRegistry::RegisterMCInstPrinter(*T, createChinxMCInstPrinter);
    }
}
