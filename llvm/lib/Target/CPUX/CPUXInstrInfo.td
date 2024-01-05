def CPUXRet : SDNode<"CPUXISD::Ret", SDTNone,
  [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

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

// Jlalr does not use OpNode
class ArithLogicI_J<bits<7> opcode, bits<3> funct3,
                    string instr_asm, Operand Od, RegisterClass RC> :
  CPUX_I<opcode, funct3, (outs RC:$rd), (ins RC:$rs1, Od:$simm12),
  !strconcat(instr_asm, "  $rd, $rs1, $simm12"), [], IIAlu> {
  }

class ArithLogicU<bits<7> opcode, string instr_asm,
  RegisterClass RC, Operand Od> :
  CPUX_U<opcode, (outs RC:$rd), (ins Od:$imm20),
    !strconcat(instr_asm, "  $rd, $imm20"), [], IIAlu> {
      let isReMaterializable = 1;
}

def JALR : ArithLogicI_J<0b1100111, 0b000, "jalr", simm12, GPR>;

def: InstAlias<"jr $rs",     (JALR ZERO, GPR:$rs, 0)>;
def: InstAlias<"jalr $rs",   (JALR RA,   GPR:$rs, 0)>;
def: InstAlias<"ret",         (JALR ZERO,      RA, 0), 2>;

let canFoldAsLoad = 1 in
class LoadMemory<bits<7> opcode, bits<3> funct3, string instr_asm,
  RegisterClass RC> :
  CPUX_I<opcode, funct3, (outs RC:$rd), (ins GPR:$rs1, simm12:$simm12),
    !strconcat(instr_asm, "  $rd, ${simm12}(${rs1})"),
    [], IILoad>;

class StoreMemory<bits<7> opcode, bits<3> funct3, string instr_asm,
  RegisterClass RC> :
  CPUX_S<opcode, funct3, (outs), (ins RC:$rs2, GPR:$rs1, simm12:$simm12),
    !strconcat(instr_asm, "  $rs2, ${simm12}(${rs1})"),
    [], IIStore>;

class AlignedLoad<PatFrag Node> :
  PatFrag<(ops node:$ptr), (Node node:$ptr), [{
  LoadSDNode *LD = cast<LoadSDNode>(N);
  return LD->getMmoeryVT().getSizeInBits() / 8 <= LD->getAlignment();
}]>;

class AlignedStore<PatFrag Node> :
  PatFrag<(ops node:$val, node:$ptr), (Node node:$val, node:$ptr), [{
  StoreSDNode *ST = cast<StoreSDNode>(N);
  return SD->getMemoryVT().getSizeInBits() / 8 <= ST->getAlignment();
}]>;

def ADDI: ArithLogicI<0b0010011, 0b000, "addi", add, simm12, GPR>;
def: InstAlias<"li  $rs, $imm", (ADDI GPR:$rs, ZERO, simm12:$imm)>;

def LUI: ArithLogicU<0b0110111, "lui", GPR, simm20u>;
def ADD: ArithLogicR<0b0110011, 0b000, 0b0000000, "add", add, GPR>;

let isReturn=1, isTerminator=1, hasDelaySlot=0, isBarrier=1, hasCtrlDep=1 in
  def RetRA : CPUXPseudo<(outs), (ins), "", [(CPUXRet)]>;

def load_a          : AlignedLoad<load>;
def sextloadi8_a    : AlignedLoad<sextloadi8>;
def zextloadi8_a    : AlignedLoad<zextloadi8>;
def sextloadi32_a   : AlignedLoad<sextloadi32>;

def store_a        : AlignedStore<store>;
def trucstorei32_a : AlignedStore<truncstorei32>;

def LW   : LoadMemory <0b0000011, 0b010, "lw", GPR>;
def SW   : StoreMemory<0b0100011, 0b010, "sw", GPR>;

def : Pat<(add (i32 addr_fi:$rs1), simm12:$simm12),
          (ADDI (i32 addr_fi:$rs1), simm12:$simm12)>;

multiclass LoadPattern<PatFrag LoadOp, CPUXInst Inst> {
  def : Pat<(LoadOp simm12:$simm12)                    , (Inst ZERO, simm12:$simm12)>;
  def : Pat<(LoadOp simm32:$imm)                       ,
            (Inst (LUI (HI20 imm:$imm)), (LO12sext imm:$imm))>;
  def : Pat<(LoadOp GPR:$rs1)                          , (Inst GPR:$rs1, 0)>;
  def : Pat<(LoadOp addr_fi:$rs1)                      , (Inst addr_fi:$rs1, 0)>;
  def : Pat<(LoadOp (add GPR:$rs1, simm12:$simm12))    , (Inst GPR:$rs1, simm12:$simm12)>;
  def : Pat<(LoadOp (add addr_fi:$rs1, simm12:$simm12)), (Inst addr_fi:$rs1, simm12:$simm12)>;
}

multiclass StorePattern<PatFrag StoreOp, CPUXInst Inst, RegisterClass RC> {
  def : Pat<(StoreOp RC:$rs2, simm12:$simm12)         , (Inst RC:$rs2, ZERO, simm12:$simm12)>;
  def : Pat<(StoreOp RC:$rs2, simm32:$imm)         ,
            (Inst RC:$rs2, (LUI (HI20 imm:$imm)), (LO12sext imm:$imm))>;
  def : Pat<(StoreOp RC:$rs2, GPR:$rs1)               , (Inst RC:$rs2, GPR:$rs1, 0)>;
  def : Pat<(StoreOp RC:$rs2, addr_fi:$rs1)           , (Inst RC:$rs2, addr_fi:$rs1, 0)>;
  def : Pat<(StoreOp RC:$rs2, (add GPR:$rs1, simm12:$simm12)),
    (Inst RC:$rs2, GPR:$rs1, simm12:$simm12)>;
  def : Pat<(StoreOp RC:$rs2, (add addr_fi:$rs1, simm12:$simm12)),
    (Inst RC:$rs2, addr_fi:$rs1, simm12:$simm12)>;
}

defm : LoadPattern<load, LW>;
defm : LoadPattern<sextloadi8, LW>;
defm : LoadPattern<extloadi8, LW>;
defm : LoadPattern<zextloadi8, LW>;
defm : StorePattern<store, SW, GPR>;

def : Pat<(simm12:$in), (ADDI ZERO, simm12:$in)>;
def : Pat<(simm20u:$in), (LUI (HI20 imm:$in))>;
def : Pat<(simm32:$imm), (ADDI (LUI (HI20 imm:$imm)), (LO12sext imm:$imm))>;

