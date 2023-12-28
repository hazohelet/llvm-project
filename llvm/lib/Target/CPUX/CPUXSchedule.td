def ALU     : FuncUnit;
def IMULDIV : FuncUnit;

def IIAlu    : InstrItinClass;
def IILoad   : InstrItinClass;
def IIStore  : InstrItinClass;
def IIBranch : InstrItinClass;

def IIPseudo : InstrItinClass;

def CPUXGenericItineraries : ProcessorItineraries<[ALU, IMULDIV], [], [
  InstrItinData<IIAlu    , [InstrStage<1, [ALU]>]>,
  InstrItinData<IILoad   , [InstrStage<3, [ALU]>]>,
  InstrItinData<IIStore  , [InstrStage<1, [ALU]>]>,
  InstrItinData<IIBranch , [InstrStage<1, [ALU]>]>,
]>;
