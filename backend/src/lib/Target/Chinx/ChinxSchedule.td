def ALU : FuncUnit;

def IIAlu : InstrItinClass;
def IILoad : InstrItinClass;
def IIStore : InstrItinClass;
def IIBranch : InstrItinClass;
def IIPseudo : InstrItinClass;

def ChinxGenericItineraries : ProcessorItineraries<[ALU], [], [
    InstrItinData<IIAlu, [InstrStage<1, [ALU]>]>,
    InstrItinData<IILoad, [InstrStage<2, [ALU]>]>,
    InstrItinData<IIStore, [InstrStage<2, [ALU]>]>,
    InstrItinData<IIBranch, [InstrStage<1, [ALU]>]>
]>;
