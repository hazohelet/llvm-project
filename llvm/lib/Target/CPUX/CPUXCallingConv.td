def CSR_LP32 : CalleeSavedRegs<(add RA, SP, FP, S1, (sequence "S%u", 2, 11))>;

def RetCC_CPUX : CallingConv<[
  CCIfType<[i32], CCAssignToReg<[A0, A1]>>
]>;
