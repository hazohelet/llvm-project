class Format<bits<3> val> {
  bits<3> Value = val;
}

def Pseudo : Format<0>;
def FrmR   : Format<1>;
def FrmI   : Format<2>;
def FrmS   : Format<3>;
def FrmU   : Format<4>;
def FrmB   : Format<5>;
def FrmJ   : Format<6>;

class CPUXInst<dag outs, dag ins, string asmstr, list<dag> pattern,
  InstrItinClass itin, Format f> : Instruction {
  field bits<32> Inst;
  Format Form = f;

  let Namespace = "CPUX";
  let Size = 4;
  bits<7> Opcode = 0;
  let Inst{6-0} = Opcode;

  let OutOperandList = outs;
  let InOperandList = ins;

  let AsmString = asmstr;
  let Pattern = pattern;
  let Itinerary = itin;

  bits<3> FormBits = Form.Value;

  let TSFlags{2-0} = FormBits;
  let DecoderNamespace = "CPUX";

  field bits<32> SoftFail = 0;
}

// R-type
class CPUX_R<bits<7> opcode, bits<3> funct3, bits<7> funct7,
  dag outs, dag ins, string asmstr, list<dag> pattern,
  InstrItinClass itin> : CPUXInst<outs, ins, asmstr, pattern, itin,
  FrmR> {
  bits<5> rd;
  bits<5> rs1;
  bits<5> rs2;

  let Inst{31-25} = funct7;
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = funct3;
  let Inst{11-7} = rd;
  let Inst{6-0} = opcode;
}

// I-type
class CPUX_I<bits<7> opcode, bits<3> funct3,
  dag outs, dag ins, string asmstr, list<dag> pattern,
  InstrItinClass itin> : CPUXInst<outs, ins, asmstr, pattern, itin,
  FrmI> {
  bits<5>  rd;
  bits<5>  rs1;
  bits<12> simm12;

  let Inst{31-20} = simm12;
  let Inst{19-15} = rs1;
  let Inst{14-12} = funct3;
  let Inst{11-7}  = rd;
  let Inst{6-0}   = opcode;
}

// S-type
class CPUX_S<bits<7> opcode, bits<3> funct3,
  dag outs, dag ins, string asmstr, list<dag> pattern, InstrItinClass itin> : CPUXInst<outs, ins, asmstr, pattern, itin, FrmS> {
  bits<5>  rs1;
  bits<5>  rs2;
  bits<12> simm12;

  let Inst{31-25} = simm12{11-5};
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = funct3;
  let Inst{11-7}  = simm12{4-0};
  let Inst{6-0}   = opcode;
}

// U-type
class CPUX_U<bits<7> opcode, dag outs, dag ins, string asmstr,
  list<dag> pattern, InstrItinClass itin>
  : CPUXInst<outs, ins, asmstr, pattern, itin, FrmU> {
  bits<5>  rd;
  bits<20> imm20;

  let Inst{31-12} = imm20;
  let Inst{11-7}  = rd;
  let Inst{6-0}   = opcode;
}

// B-type
class CPUX_B<bits<7> opcode, bits<3> funct3,
  dag outs, dag ins, string asmstr, list<dag> pattern,
  InstrItinClass itin>
  : CPUXInst<outs, ins, asmstr, pattern, itin, FrmB> {
  bits<5>  rs1;
  bits<5>  rs2;
  bits<12> imm12;

  let Inst{31} = imm12{11};
  let Inst{30-25} = imm12{9-4};
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = funct3;
  let Inst{11-8}  = imm12{3-0};
  let Inst{7-7}   = imm12{10};
  let Inst{6-0}   = opcode;
}

// J-type
class CPUX_J<bits<7> opcode, dag outs, dag ins, string asmstr,
  list<dag> pattern, InstrItinClass itin>
  : CPUXInst<outs, ins, asmstr, pattern, itin, FrmJ> {
  bits<5>  rd;
  bits<20> imm20;

  let Inst{31}    = imm20{19};
  let Inst{30-21} = imm20{9-0};
  let Inst{20}    = imm20{10};
  let Inst{19-12} = imm20{18-11};
  let Inst{11-7}  = rd;
  let Inst{6-0}   = opcode;
}

class CPUXPseudo<dag outs, dag ins, string asmstr, list<dag> pattern>:
  CPUXInst<outs, ins, asmstr, pattern, IIPseudo, Pseudo> {
  let isCodeGenOnly = 1;
  let isPseudo = 1;
}
