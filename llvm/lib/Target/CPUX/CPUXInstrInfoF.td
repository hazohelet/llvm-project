class FPCompDestR<bits<7> opcode, bits<3> funct3, bits<7> funct7,
                  string instr_asm, SDPatternOperator OpNode> :
  CPUX_R<opcode, funct3, funct7, (outs GPR:$rd), (ins FPR:$rs1, FPR:$rs2),
    !strconcat(instr_asm, " $rd, $rs1, $rs2"),
    [(set GPR:$rd, (OpNode FPR:$rs1, FPR:$rs2))], IIAlu> {
  let isReMaterializable = 1;
}

def SDT_CPUXFHalf
    : SDTypeProfile<1, 1, [SDTCisVT<0, f32>, SDTCisVT<1, f32>]>;
def CPUXFHalf: SDNode<"CPUXISD::FHalf", SDT_CPUXFHalf>;


def FLW : LoadMemory <0b0000111, 0b010, "flw", FPR>;
def FSW : StoreMemory<0b0000111, 0b010, "fsw", FPR>;

defm : LoadPattern <load, FLW>;
defm : StorePattern<store, FSW, FPR>;

def FADD : ArithLogicR<0b1010011, 0b000, 0b0000000, "fadd.s", fadd, FPR>;
def FSUB : ArithLogicR<0b1010011, 0b000, 0b0000100, "fsub.s", fsub, FPR>;
def FMUL : ArithLogicR<0b1010011, 0b000, 0b0001000, "fmul.s", fmul, FPR>;
def FDIV : ArithLogicR<0b1010011, 0b000, 0b0001100, "fdiv.s", fdiv, FPR>;

class FPSingleOp<bits<7> opcode, bits<3> rm, bits<7> funct7,
                 string instr_asm, RegisterClass DstRC, RegisterClass SrcRC> :
  CPUX_R<opcode, rm, funct7, (outs DstRC:$rd), (ins SrcRC:$rs1),
         !strconcat(instr_asm, " $rd, $rs1"), [], IIAlu> {
  let isReMaterializable = 1;
  let rs2 = 0b00000;
}

class FPTwoOp<bits<7> opcode, bits<3> rm, bits<7> funct7,
              string instr_asm>:
  CPUX_R<opcode, rm, funct7, (outs FPR:$rd), (ins FPR:$rs1, FPR:$rs2),
         !strconcat(instr_asm, " $rd, $rs1, $rs2"), [], IIAlu> {
  let isReMaterializable = 1;
}

def FSIGNJ  : FPTwoOp<0b1010011, 0b000, 0b0010000, "fsgnj.s">;
def FSIGNJN : FPTwoOp<0b1010011, 0b001, 0b0010000, "fsgnjn.s">;
def FSIGNJX : FPTwoOp<0b1010011, 0b010, 0b0010000, "fsgnjx.s">;
def FSQRT : FPSingleOp<0b1010011, 0b000, 0b0101100, "fsqrt.s", FPR, FPR>;
def FHALF : FPSingleOp<0b1010011, 0b000, 0b0101100, "fhalf.s", FPR, FPR>;
def FFLOOR: FPSingleOp<0b1110111, 0b010, 0b0111100, "ffloor.s", FPR, FPR>;
def FCVTWS: FPSingleOp<0b1010011, 0b000, 0b1100000, "fcvt.w.s", GPR, FPR>;
def FCVTSW: FPSingleOp<0b1010011, 0b000, 0b1101000, "fcvt.s.w", FPR, GPR>;

def : Pat<(CPUXFHalf FPR:$rs1),  (FHALF $rs1)>;

def : Pat<(fsqrt FPR:$rs1), (FSQRT $rs1)>;
def : Pat<(f32 (ffloor FPR:$rs1)), (FFLOOR $rs1)>;
def : Pat<(fneg  FPR:$rs1), (FSIGNJN $rs1, $rs1)>;
def : Pat<(fabs  FPR:$rs1), (FSIGNJX $rs1, $rs1)>;
def : InstAlias<"fmv.s  $rd, $rs1", (FSIGNJ  FPR:$rd, FPR:$rs1, FPR:$rs1)>;
def : InstAlias<"fneg.s $rd, $rs1", (FSIGNJN FPR:$rd, FPR:$rs1, FPR:$rs1)>;
def : InstAlias<"fabs.s $rd, $rs1", (FSIGNJX FPR:$rd, FPR:$rs1, FPR:$rs1)>;

def : Pat<(fp_to_sint FPR:$rs1), (FCVTWS $rs1)>;
def : Pat<(sint_to_fp GPR:$rs1), (FCVTSW $rs1)>;

def FLE : FPCompDestR<0b1010011, 0b000, 0b1010001, "fle.s", setle>;
def FLT : FPCompDestR<0b1010011, 0b001, 0b1010001, "flt.s", setlt>;
def FEQ : FPCompDestR<0b1010011, 0b010, 0b1010001, "feq.s", seteq>;

def : Pat<(setole FPR:$rs1, FPR:$rs2), (FLE $rs1, $rs2)>;
def : Pat<(setogt FPR:$rs1, FPR:$rs2), (FLE $rs2, $rs1)>;
def : Pat<(setolt FPR:$rs1, FPR:$rs2), (FLT $rs1, $rs2)>;
def : Pat<(setoge FPR:$rs1, FPR:$rs2), (FLT $rs2, $rs1)>;
def : Pat<(setoeq FPR:$rs1, FPR:$rs2), (FEQ $rs1, $rs2)>;

def : Pat<(setule FPR:$rs1, FPR:$rs2), (FLE $rs1, $rs2)>;
def : Pat<(setugt FPR:$rs1, FPR:$rs2), (FLE $rs2, $rs1)>;
def : Pat<(setult FPR:$rs1, FPR:$rs2), (FLT $rs1, $rs2)>;
def : Pat<(setuge FPR:$rs1, FPR:$rs2), (FLT $rs2, $rs1)>;
def : Pat<(setueq FPR:$rs1, FPR:$rs2), (FEQ $rs1, $rs2)>;

def : Pat<(setune FPR:$rs1, FPR:$rs2), (XORI (FEQ $rs1, $rs2), 1)>;

def : Pat<(setgt  FPR:$rs1, FPR:$rs2), (FLE $rs2, $rs1)>;
def : Pat<(setge  FPR:$rs1, FPR:$rs2), (FLT $rs2, $rs1)>;
