def SDT_CPUXCall : SDTypeProfile<0, 1, [SDTCisVT<0, iPTR>]>;

// For select operands:
// 0: Dest
// 1: Cond LHS
// 2: Cond RHS
// 3: Cond Opcode
// 4: True Value
// 5: False Value
def SDT_CPUXSelectCC : SDTypeProfile<1, 5, [SDTCisSameAs<1, 2>,
                                            SDTCisSameAs<0, 4>,
                                            SDTCisSameAs<4, 5>]>;

def CPUXRet : SDNode<"CPUXISD::Ret", SDTNone,
  [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

def CPUXTailCall : SDNode<"CPUXISD::TailCall", SDT_CPUXCall,
                          [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue, SDNPVariadic]>;

def SelectCC : SDNode<"CPUXISD::SELECT_CC", SDT_CPUXSelectCC, [SDNPInGlue]>;

def SDT_CPUXCallSeqStart : SDCallSeqStart<[SDTCisVT<0, i32>, SDTCisVT<1, i32>]>;
def SDT_CPUXCallSeqEnd   : SDCallSeqEnd  <[SDTCisVT<0, i32>, SDTCisVT<1, i32>]>;

def CPUXCall : SDNode<"CPUXISD::CALL", SDT_CPUXCall, [SDNPHasChain,
  SDNPOptInGlue, SDNPOutGlue, SDNPVariadic]>;
def CPUXCallSeqStart : SDNode<"ISD::CALLSEQ_START", SDT_CPUXCallSeqStart,
                              [SDNPHasChain, SDNPOutGlue]>;
def CPUXCallSeqEnd   : SDNode<"ISD::CALLSEQ_END", SDT_CPUXCallSeqEnd,
                              [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;

include "CPUXInstrFormats.td"

// Lower 12 bits
def simm12: Operand<i32>, ImmLeaf<i32, [{return isInt<12>(Imm);}]>;
// Upper 20 bits filled, with lower 12 bits zeros
def simm20u: Operand<i32>, ImmLeaf<i32,
  [{return isInt<32>(Imm) && !(Imm & 0xfff);}]>;
def simm32: Operand<i32>, ImmLeaf<i32, [{return isInt<32>(Imm);}]>;

def simm12_plus1 : ImmLeaf<i32,
  [{return (isInt<12>(Imm) && Imm != -2048) || Imm == 2048;}]>;

def NegImm : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(-N->getSExtValue(), SDLoc(N),
                                   N->getValueType(0));
}]>;

def CallSymbol : AsmOperandClass {
  let Name = "CallSymbol";
  let RenderMethod = "addImmOperands";
}

def call_symbol : Operand<i32> {
  let ParserMatchClass = CallSymbol;
}

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

class ShiftI<bits<7> opcode, bits<3> funct3, bit arithshift,
             string instr_asm, SDNode OpNode>:
  CPUX_ISHIFT<opcode, funct3, arithshift, (outs GPR:$rd),
       (ins GPR:$rs1, immZExt_Xlen:$shamt),
       !strconcat(instr_asm, " $rd, $rs1, $shamt"),
       [(set GPR:$rd, (OpNode GPR:$rs1, immZExt_Xlen:$shamt))], IIAlu> {}

class ShiftR<bits<7> opcode, bits<7> funct7, bits<3> funct3,
             /*bits<4> isRotate,*/ string instr_asm, SDNode OpNode,
             RegisterClass RC>:
  CPUX_R<opcode, funct3, funct7, (outs RC:$rd), (ins RC:$rs1, RC:$rs2),
  !strconcat(instr_asm, " $rd, $rs1, $rs2"),
  [(set GPR:$rd, (OpNode RC:$rs1, RC:$rs2))], IIAlu> {}

def JALR : ArithLogicI_J<0b1100111, 0b000, "jalr", simm12, GPR>;

def: InstAlias<"jr $rs",     (JALR ZERO, GPR:$rs, 0)>;
def: InstAlias<"jalr $rs",   (JALR RA,   GPR:$rs, 0)>;
def: InstAlias<"ret",         (JALR ZERO,      RA, 0), 2>;

let isCall = 1 in
class JumpLink<bits<7> opcode, string opstr, DAGOperand opnd>:
  CPUX_J<opcode, (outs GPR:$rd), (ins opnd:$imm20),
  !strconcat(opstr, "  $rd, $imm20"), [], IIAlu>;

def JAL : JumpLink<0b1101111, "jal", brtarget20>;
def : InstAlias<"j $offset",   (JAL ZERO, brtarget20:$offset)>;
def : InstAlias<"jal $offset", (JAL RA,   brtarget20:$offset)>;

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

let isCall = 1, isTerminator = 1, isReturn = 1, isBarrier = 1, hasDelaySlot = 0,
    hasExtraSrcRegAllocReq = 1 in {
  def PseudoTAILCALL : CPUXPseudo<(outs), (ins call_symbol:$target),
      "tail $target", []>;
}

class AlignedLoad<PatFrag Node> :
  PatFrag<(ops node:$ptr), (Node node:$ptr), [{
  LoadSDNode *LD = cast<LoadSDNode>(N);
  return LD->getMemoryVT().getSizeInBits() / 8 <= LD->getAlignment();
}]>;

class AlignedStore<PatFrag Node> :
  PatFrag<(ops node:$val, node:$ptr), (Node node:$val, node:$ptr), [{
  StoreSDNode *ST = cast<StoreSDNode>(N);
  return SD->getMemoryVT().getSizeInBits() / 8 <= ST->getAlignment();
}]>;

class SetCC_R<bits<7> opcode, bits<3> funct3, bits<7> funct7,
   string instr_asm, PatFrag cond_op, RegisterClass RC> :
   CPUX_R<opcode, funct3, funct7, (outs RC:$rd), (ins RC:$rs1, RC:$rs2),
   !strconcat(instr_asm, " $rd, $rs1, $rs2"),
   [(set GPR:$rd, (cond_op RC:$rs1, RC:$rs2))], IIAlu> {
     let isReMaterializable = 1;
}

class SetCC_I<bits<7> opcode, bits<3> funct3,
  string instr_asm, PatFrag cond_op, Operand Od, RegisterClass RC> :
  CPUX_I<opcode, funct3, (outs RC:$rd), (ins RC:$rs1, Od:$simm12),
    !strconcat(instr_asm, " $rd, $rs1, $simm12"),
    [(set GPR:$rd, (cond_op RC:$rs1, Od:$simm12))], IIAlu> {
    let isReMaterializable = 1;
}

class CBranch12<bits<7> opcode, bits<3> funct3,
  string instr_asm, RegisterClass RC> :
  CPUX_B<opcode, funct3, (outs), (ins RC:$rs1, RC:$rs2, brtarget12:$imm12),
  !strconcat(instr_asm, "  $rs1, $rs2, $imm12"), [], IIAlu> {
    let isBranch = 1;
    let isTerminator = 1;
}

def BEQ  : CBranch12<0b1100011, 0b000, "beq", GPR>;
def BEQTWO: CBranch12<0b1100011, 0b000, "beq.2", GPR>;
def BEQ99: CBranch12<0b1100011, 0b000, "beq.99", GPR>;
def BNE  : CBranch12<0b1100011, 0b001, "bne", GPR>;
def BLT  : CBranch12<0b1100011, 0b100, "blt", GPR>;
def BGE  : CBranch12<0b1100011, 0b101, "bge", GPR>;
def BLTU : CBranch12<0b1100011, 0b110, "bltu", GPR>;
def BGEU : CBranch12<0b1100011, 0b111, "bgeu", GPR>;

def: InstAlias<"beqz  $rs, $imm12", (BEQ  GPR:$rs, ZERO,    brtarget12:$imm12)>;
def: InstAlias<"bnez  $rs, $imm12", (BNE  GPR:$rs, ZERO,    brtarget12:$imm12)>;
def: InstAlias<"bltz  $rs, $imm12", (BLT  GPR:$rs, ZERO,    brtarget12:$imm12)>;
def: InstAlias<"bgtz  $rs, $imm12", (BLT  ZERO,    GPR:$rs, brtarget12:$imm12)>;
def: InstAlias<"bgez  $rs, $imm12", (BGE  GPR:$rs, ZERO,    brtarget12:$imm12)>;
def: InstAlias<"blez  $rs, $imm12", (BGE  ZERO,    GPR:$rs, brtarget12:$imm12)>;



let isBarrier = 1, isBranch = 1, isTerminator = 1 in
  def PseudoBR : CPUXPseudo<(outs), (ins brtarget20:$simm20u), "",
  [(br bb:$simm20u)]>, PseudoInstExpansion<(JAL ZERO, brtarget20:$simm20u)>;

let usesCustomInserter = 1 in
class SelectCC_rrirr<RegisterClass RC, RegisterClass cmpty>
  : CPUXPseudo<(outs RC:$dst),
    (ins cmpty:$lhs, cmpty:$rhs, simm12:$imm, RC:$truev, RC:$falsev), "",
    [(set RC:$dst, (SelectCC cmpty:$lhs, cmpty:$rhs, (i32 imm:$imm), RC:$truev, RC:$falsev))]>;

def Select_GPR_Using_CC_GPR : SelectCC_rrirr<GPR, GPR>;
def Select_GPR_Using_CC_FPR : SelectCC_rrirr<FPR, GPR>;

let Defs = [SP], Uses = [SP], hasSideEffects = 1 in {
  def ADJCALLSTACKDOWN : CPUXPseudo<(outs), (ins simm12:$amt1, simm12:$amt2), "",
                                    [(CPUXCallSeqStart timm:$amt1, timm:$amt2)]>;
  def ADJCALLSTACKUP   : CPUXPseudo<(outs), (ins simm12:$amt1, simm12:$amt2), "",
                                    [(CPUXCallSeqEnd timm:$amt1, timm:$amt2)]>;
}

let isCall = 1, Defs = [RA], isCodeGenOnly = 0 in {
  def PseudoCALL : CPUXPseudo<(outs), (ins call_symbol:$target), "call $target", []>;
}
def : Pat<(CPUXCall tglobaladdr:$func),  (PseudoCALL tglobaladdr:$func)>;
def : Pat<(CPUXCall texternalsym:$func), (PseudoCALL texternalsym:$func)>;

def : Pat<(CPUXTailCall tglobaladdr:$dst),  (PseudoTAILCALL tglobaladdr:$dst)>;
def : Pat<(CPUXTailCall texternalsym:$dst), (PseudoTAILCALL texternalsym:$dst)>;

def ADDI: ArithLogicI<0b0010011, 0b000, "addi", add, simm12, GPR>;
def XORI: ArithLogicI<0b0010011, 0b100, "xori", xor, simm12, GPR>;
def ORI:  ArithLogicI<0b0010011, 0b110, "ori",  or,  simm12, GPR>;
def ANDI: ArithLogicI<0b0010011, 0b111, "andi", and, simm12, GPR>;

def: InstAlias<"li  $rs, $imm", (ADDI GPR:$rs, ZERO, simm12:$imm)>;
def: InstAlias<"mv  $rd, $rs", (ADDI GPR:$rd, GPR:$rs, 0)>;

class GPTwoOp<bits<7> opcode, bits<3> rm, bits<7> funct7,
              string instr_asm>:
  CPUX_R<opcode, rm, funct7, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
         !strconcat(instr_asm, " $rd, $rs1, $rs2"), [], IIAlu> {
  let isReMaterializable = 1;
}

def LUI: ArithLogicU<0b0110111, "lui", GPR, simm20u>;
def ADD: ArithLogicR<0b0110011, 0b000, 0b0000000, "add", add, GPR>;
def ADDSCALE: GPTwoOp<0b1010011, 0b000, 0b0010000, "add.scale">;
def SUB: ArithLogicR<0b0110011, 0b000, 0b0100000, "sub", sub, GPR>;

def AND: ArithLogicR<0b0110011, 0b111, 0b0000000, "and", and, GPR>;
def OR : ArithLogicR<0b0110011, 0b110, 0b0000000, "or",  or,  GPR>;
def XOR: ArithLogicR<0b0110011, 0b100, 0b0000000, "xor", xor, GPR>;

def SLL: ShiftR<0b0110011, 0b0000000, 0b001, /*0x0,*/ "sll", shl, GPR>;
def SRL: ShiftR<0b0110011, 0b0000000, 0b101, /*0x0,*/ "srl", srl, GPR>;
def SRA: ShiftR<0b0110011, 0b0100000, 0b101, /*0x0,*/ "sra", sra, GPR>;

def SLLI: ShiftI<0b0010011, 0b001, 0, "slli", shl>;
def SRLI: ShiftI<0b0010011, 0b101, 0, "srli", srl>;
def SRAI: ShiftI<0b0010011, 0b101, 0, "srai", sra>;

def SLTI : SetCC_I<0b0010011, 0b010, "slti", setlt, simm12, GPR>;
def SLTIU: SetCC_I<0b0010011, 0b011, "sltiu", setult, simm12, GPR>;
def SLT  : SetCC_R<0b0110011, 0b010, 0b0000000, "slt", setlt, GPR>;
def SLTU : SetCC_R<0b0110011, 0b011, 0b0000000, "sltu", setult, GPR>;

def: InstAlias<"seqz  $rd, $rs", (SLTIU GPR:$rd, GPR:$rs, 1)>;
def: InstAlias<"snez  $rd, $rs", (SLTU GPR:$rd, ZERO, GPR:$rs)>;

def : Pat<(add GPR:$rs1, (shl GPR:$rs2, 2)), (ADDSCALE GPR:$rs2, GPR:$rs1)>;
def : Pat<(add (shl GPR:$rs1, 2), GPR:$rs2), (ADDSCALE GPR:$rs1, GPR:$rs2)>;

def : Pat<(seteq  GPR:$rs1, GPR:$rs2), (SLTIU (XOR GPR:$rs1, GPR:$rs2), 1)>;
def : Pat<(setne  GPR:$rs1, GPR:$rs2), (SLTU ZERO, (XOR GPR:$rs1, GPR:$rs2))>;
def : Pat<(setugt GPR:$rs1, GPR:$rs2), (SLTU GPR:$rs2, GPR:$rs1)>;
def : Pat<(setuge GPR:$rs1, GPR:$rs2), (XORI (SLTU GPR:$rs1, GPR:$rs2), 1)>;
def : Pat<(setule GPR:$rs1, GPR:$rs2), (XORI (SLTU GPR:$rs2, GPR:$rs1), 1)>;
def : Pat<(setgt  GPR:$rs1, GPR:$rs2), (SLT  GPR:$rs2, GPR:$rs1)>;
def : Pat<(setge  GPR:$rs1, GPR:$rs2), (XORI (SLT GPR:$rs1, GPR:$rs2), 1)>;
def : Pat<(setle  GPR:$rs1, GPR:$rs2), (XORI (SLT GPR:$rs2, GPR:$rs1), 1)>;

def : Pat<(seteq GPR:$rs1, 0), (SLTIU GPR:$rs1, 1)>;
def : Pat<(seteq GPR:$rs1, GPR:$rs2), (SLTIU (XOR GPR:$rs1, GPR:$rs2), 1)>;
def : Pat<(seteq GPR:$rs1, simm12_plus1:$imm12),
          (SLTIU (ADDI GPR:$rs1, (NegImm simm12_plus1:$imm12)), 1)>;
def : Pat<(seteq GPR:$rs1, -2048),
          (SLTIU (XORI GPR:$rs1, -2048), 1)>;
def : Pat<(setne GPR:$rs1, 0), (SLTU ZERO, GPR:$rs1)>;
def : Pat<(setne GPR:$rs1, GPR:$rs2), (SLTU ZERO, (XOR GPR:$rs1, GPR:$rs2))>;
def : Pat<(setne GPR:$rs1, simm12_plus1:$imm12),
          (SLTU ZERO, (ADDI GPR:$rs1, (NegImm simm12_plus1:$imm12)))>;
def : Pat<(setne GPR:$rs1, -2048),
          (SLTU ZERO, (XORI GPR:$rs1, -2048))>;
def : Pat<(setne GPR:$rs1, -1), (SLTIU GPR:$rs1, -1)>;


let isReturn=1, isTerminator=1, hasDelaySlot=0, isBarrier=1, hasCtrlDep=1 in
  def RetRA : CPUXPseudo<(outs), (ins), "", [(CPUXRet)]>;

def load_a          : AlignedLoad<load>;
def sextloadi8_a    : AlignedLoad<sextloadi8>;
def zextloadi8_a    : AlignedLoad<zextloadi8>;
def sextloadi32_a   : AlignedLoad<sextloadi32>;

def store_a        : AlignedStore<store>;
def trucstorei32_a : AlignedStore<truncstorei32>;

def LW   : LoadMemory <0b0000011, 0b010, "lw", GPR>;
def LWTWO: LoadMemory <0b0000011, 0b010, "lw.two", GPR>;
def LWSIX: LoadMemory <0b0000011, 0b010, "lw.six", GPR>;
def SW   : StoreMemory<0b0100011, 0b010, "sw", GPR>;

def : Pat<(add (i32 addr_fi:$rs1), simm12:$simm12),
          (ADDI (i32 addr_fi:$rs1), simm12:$simm12)>;

def : Pat<(load (add (shl GPR:$rs1, 2), simm12:$simm12))    , (LWTWO GPR:$rs1, simm12:$simm12)>;
def : Pat<(load (add (shl GPR:$rs1, 6), simm12:$simm12))    , (LWSIX GPR:$rs1, simm12:$simm12)>;

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


def : Pat<(brcond (i32 (setne GPR:$lhs, 0)), bb:$dst),
        (BNE GPR:$lhs, ZERO, bb:$dst)>;
def : Pat<(brcond (i32 (seteq GPR:$lhs, 0)), bb:$dst),
        (BEQ GPR:$lhs, ZERO, bb:$dst)>;

def : Pat<(brcond (i32 (seteq GPR:$lhs, 2)), bb:$dst),
        (BEQTWO GPR:$lhs, ZERO, bb:$dst)>;
def : Pat<(brcond (i32 (seteq GPR:$lhs, 99)), bb:$dst),
        (BEQ99 GPR:$lhs, ZERO, bb:$dst)>;

def : Pat<(brcond (i32 (seteq GPR:$lhs, GPR:$rhs)), bb:$dst),
        (BEQ GPR:$lhs, GPR:$rhs, bb:$dst)>;
def : Pat<(brcond (i32 (setueq GPR:$lhs, GPR:$rhs)), bb:$dst),
        (BEQ GPR:$lhs, GPR:$rhs, bb:$dst)>;
def : Pat<(brcond (i32 (setne GPR:$lhs, GPR:$rhs)), bb:$dst),
        (BNE GPR:$lhs, GPR:$rhs, bb:$dst)>;
def : Pat<(brcond (i32 (setune GPR:$lhs, GPR:$rhs)), bb:$dst),
        (BNE GPR:$lhs, GPR:$rhs, bb:$dst)>;
def : Pat<(brcond (i32 (setlt GPR:$lhs, GPR:$rhs)), bb:$dst),
        (BLT GPR:$lhs, GPR:$rhs, bb:$dst)>;
def : Pat<(brcond (i32 (setult GPR:$lhs, GPR:$rhs)), bb:$dst),
        (BLTU GPR:$lhs, GPR:$rhs, bb:$dst)>;
def : Pat<(brcond (i32 (setgt GPR:$lhs, GPR:$rhs)), bb:$dst),
        (BLT GPR:$rhs, GPR:$lhs, bb:$dst)>;
def : Pat<(brcond (i32 (setugt GPR:$lhs, GPR:$rhs)), bb:$dst),
        (BLTU GPR:$rhs, GPR:$lhs, bb:$dst)>;
def : Pat<(brcond (i32 (setle GPR:$lhs, GPR:$rhs)), bb:$dst),
        (BGE GPR:$rhs, GPR:$lhs, bb:$dst)>;
def : Pat<(brcond (i32 (setule GPR:$lhs, GPR:$rhs)), bb:$dst),
        (BGEU GPR:$rhs, GPR:$lhs, bb:$dst)>;
def : Pat<(brcond (i32 (setge GPR:$lhs, GPR:$rhs)), bb:$dst),
        (BGE GPR:$lhs, GPR:$rhs, bb:$dst)>;
def : Pat<(brcond (i32 (setuge GPR:$lhs, GPR:$rhs)), bb:$dst),
        (BGEU GPR:$lhs, GPR:$rhs, bb:$dst)>;
def : Pat<(brcond GPR:$cond, bb:$dst),
        (BNE GPR:$cond, ZERO, bb:$dst)>;

include "CPUXInstrInfoF.td"
