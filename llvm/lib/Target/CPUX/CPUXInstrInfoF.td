def FLW : LoadMemory <0b0000111, 0b010, "flw", FPR>;
def FSW : StoreMemory<0b0000111, 0b010, "fsw", FPR>;

defm : LoadPattern <load, FLW>;
defm : StorePattern<store, FSW, FPR>;

def FADD : ArithLogicR<0b1010011, 0b000, 0b0000000, "fadd.s", fadd, FPR>;
def FSUB : ArithLogicR<0b1010011, 0b000, 0b0000100, "fsub.s", fsub, FPR>;
def FMUL : ArithLogicR<0b1010011, 0b000, 0b0001000, "fmul.s", fmul, FPR>;
def FDIV : ArithLogicR<0b1010011, 0b000, 0b0001100, "fdiv.s", fdiv, FPR>;
