def ALU     : FuncUnit;
def FPUALU  : FuncUnit;

def IIAlu    : InstrItinClass;
def IILoad   : InstrItinClass;
def IIStore  : InstrItinClass;
def IIBranch : InstrItinClass;

def IIFADD : InstrItinClass;
def IIFSUB : InstrItinClass;
def IIFMUL : InstrItinClass;
def IIFDIV : InstrItinClass;
def IIFCVT : InstrItinClass;
def IIFHALF : InstrItinClass;
def IIFSQRT : InstrItinClass;
def IIFOTHER : InstrItinClass;

def IIPseudo : InstrItinClass;

def CPUXGenericItineraries : ProcessorItineraries<[ALU, FPUALU], [], [
  InstrItinData<IIAlu    , [InstrStage<1, [ALU]>]>,
  InstrItinData<IILoad   , [InstrStage<3, [ALU]>]>,
  InstrItinData<IIStore  , [InstrStage<1, [ALU]>]>,
  InstrItinData<IIBranch , [InstrStage<1, [ALU]>]>,

  InstrItinData<IIFADD,  [InstrStage<3, [FPUALU]>]>,
  InstrItinData<IIFSUB,  [InstrStage<3, [FPUALU]>]>,
  InstrItinData<IIFMUL,  [InstrStage<2, [FPUALU]>]>,
  InstrItinData<IIFDIV,  [InstrStage<4, [FPUALU]>]>,
  InstrItinData<IIFCVT,  [InstrStage<2, [FPUALU]>]>,
  InstrItinData<IIFHALF, [InstrStage<2, [FPUALU]>]>,
  InstrItinData<IIFSQRT, [InstrStage<2, [FPUALU]>]>,
  InstrItinData<IIFOTHER, [InstrStage<1, [FPUALU]>]>,
]>;
