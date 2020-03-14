def ALU : FuncUnit;
def IMUL : FuncUnit;

def IIAlu    : InstrItinClass;
def IILoad   : InstrItinClass;
def IIStore  : InstrItinClass;
def IIBranch : InstrItinClass;

def IIPseudo : InstrItinClass;

def CXCGenericItineraries : ProcessorItineraries<[ALU, IMUL], [], [
    InstrItinData<IIAlu     , [InstrStage<1, [ALU]>]>,
    InstrItinData<IILoad    , [InstrStage<1, [ALU]>]>,
    InstrItinData<IIStore   , [InstrStage<1, [ALU]>]>,
    InstrItinData<IIBranch  , [InstrStage<1, [ALU]>]>
]>;