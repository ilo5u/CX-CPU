include "llvm/Target/Target.td"

include "ChinxRegisterInfo.td"
include "ChinxSchedule.td"
include "ChinxInstrInfo.td"
include "ChinxCallingConv.td"

def Feature_1 : SubtargetFeature<"fe_1", "HasDummy", "true", "Enable instructions.">;
def Feature_2 : SubtargetFeature<"fe_2", "HasDummy", "true", "Enable instructions.">;
def Feature_3 : SubtargetFeature<"fe_3", "HasDummy", "true", "Enable instructions.">;
def Feature_All : SubtargetFeature<"fe_all", "HasDummy", "true", "Enable instructions.", [
    Feature_1, Feature_2, Feature_3
]>;
def FeatureSet : SubtargetFeature<"set", "HasSet", "true", "Enable 'set' instruction.">;
def FeatureChinxI : SubtargetFeature<"chinxI", "ChinxArchVersion", "ChinxI", "ChinxI ISA Support",
                                     [Feature_All]>;
def FeatureChinxII : SubtargetFeature<"chinxII", "ChinxArchVersion", "ChinxII", "ChinxII ISA Support",
                                     [Feature_All, FeatureSet]>;

class Proc<string Name, list<SubtargetFeature> Features> :
    Processor<Name, ChinxGenericItineraries, Features>;

def : Proc<"chinxI", [FeatureChinxI]>;
def : Proc<"chinxII", [FeatureChinxII]>;

def ChinxInstrInfo : InstrInfo;

// Will generate ChinxGenAsmWrite.inc included by ChinxInstrPrinter.cpp,
// contents as follows,
// void ChinxInstrPrinter::printInstruction(const MCInst *MI, raw_ostream &O) {...}
// const char * ChinxInstrPrinter::getRegisterName(unsigned RegNo) {...}
def Chinx : Target {
    let InstructionSet = ChinxInstrInfo;
}
