include "CPUXInstrFormats.td"

// Lower 12 bits
def simm12: Operand<i32>, ImmLeaf<i32, [{return isInt<12>(Imm);}]>;
// Upper 20 bits filled, with lower 12 bits zeros
def simm20u: Operand<i32>, ImmLeaf<i32,
  [{return isInt<32>(Imm) && !(Imm & 0xfff);}]>;
def simm32: Operand<i32>, ImmLeaf<i32, [{return isInt<32>(Imm);}]>;


def LO12sext : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(SignExtend64<12>(N->getZExtValue()),
    SDLoc(N), N->getValueType(0));
  }]>;

def HI20 : SDNodeXForm<imm, [{
  return getImm(N, ((N->getZExtValue() + 0x800) >> 12) & 0xfffff);
  }]>;


// shamt field must fit in 5 bits.
def immZExt_Xlen : Operand<i32>, ImmLeaf<i32, [{
  return isUInt<5>(Imm);
}]>;

def calltarget : Operand<iPTR> {
  let EncoderMethod = "getJumpTargetOpValue";
}

// jal
def brtarget20    : Operand<OtherVT> {
  let EncoderMethod = "getBranch20TargetOpValue";
  let OperandType   = "OPERAND_PCREL";
}

// beq, bne
def brtarget12    : Operand<OtherVT> {
  let EncoderMethod = "getBranch12TargetOpValue";
  let OperandType   = "OPERAND_PCREL";
}

// CPUX Address Mode! SDNode frameindex could possibily be a match
// since load and store instructions from stack used it.
def addr_fi : ComplexPattern<iPTR, 1, "SelectAddrFI", [frameindex], []>;

class ArithLogicR<bits<7> opcode, bits<3> funct3,
  bits<7> funct7, string instr_asm, SDNode OpNode,
  RegisterClass RC> : CPUX_R<opcode, funct3, funct7,
    (outs RC:$rd), (ins RC:$rs1, RC:$rs2),
    !strconcat(instr_asm, "  $rd, $rs1, $rs2"),
    [(set RC:$rd, (OpNode RC:$rs1, RC:$rs2))], IIAlu> {
      let isReMaterializable = 1;
}

class ArithLogicI<bits<7> opcode, bits<3> funct3,
  string instr_asm, SDNode OpNode, Operand Od, RegisterClass RC>:
  CPUX_I<opcode, funct3, (outs RC:$rd), (ins RC:$rs1, Od:$simm12),
    !strconcat(instr_asm, "  $rd, $rs1, $simm12"),
    [(set RC:$rd, (OpNode RC:$rs1, Od:$simm12))], IIAlu> {
      let isReMaterializable = 1;
}

class ArithLogicU<bits<7> opcode, string instr_asm,
  RegisterClass RC, Operand Od> :
  CPUX_U<opcode, (outs RC:$rd), (ins Od:$imm20),
    !strconcat(instr_asm, "  $rd, $imm20"), [], IIAlu> {
      let isReMaterializable = 1;
}

def ADDI: ArithLogicI<0b0010011, 0b000, "addi", add, simm12, GPR>;

def LUI: ArithLogicU<0b0110111, "lui", GPR, simm20u>;
def ADD: ArithLogicR<0b0110011, 0b000, 0b0000000, "add", add, GPR>;


def : Pat<(simm12:$in), (ADDI ZERO, simm12:$in)>;
def : Pat<(simm20u:$in), (LUI (HI20 imm:$in))>;
def : Pat<(simm32:$imm), (ADDI (LUI (HI20 imm:$imm)), (LO12sext imm:$imm))>;

