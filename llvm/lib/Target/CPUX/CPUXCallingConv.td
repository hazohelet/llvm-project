def CSR_LP32 : CalleeSavedRegs<(add RA, SP, FP, S1, (sequence "S%u", 2, 11))>;

def RetCC_CPUX : CallingConv<[
  CCIfType<[i32], CCAssignToReg<[A0, A1]>>
]>;

def CC_LP32 : CallingConv<[
  CCIfType<[i1, i8, i16], CCPromoteToType<i32>>,
  CCIfType<[i32], CCAssignToReg<[A0, A1, A2, A3, A4, A5, A6, A7]>>,
  // stack-located arguments are aligned to 4 bytes
  CCIfType<[i32], CCAssignToStack<4, 4>>
]>;

def CC_STACK32 : CallingConv<[
  CCIfType<[i1, i8, i16], CCPromoteToType<i32>>,
  // stack-located arguments are aligned to 4 bytes
  CCIfType<[i32], CCAssignToStack<4, 4>>
]>;

def CC_CPUX : CallingConv<[
  CCDelegateTo<CC_LP32>
]>;
