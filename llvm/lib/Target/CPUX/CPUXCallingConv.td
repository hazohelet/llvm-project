def CSR_LP32 : CalleeSavedRegs<(add RA, SP, FP, S1,
                 (sequence "S%u", 2, 5),
                 F8, F9,
                 (sequence "F%u", 18, 22))>;

def RetCC_CPUX : CallingConv<[
  CCIfType<[i32], CCAssignToReg<[A0, A1]>>,
  CCIfType<[f32], CCAssignToReg<[F10]>>
]>;

def CC_LP32 : CallingConv<[
  CCIfType<[i1, i8, i16], CCPromoteToType<i32>>,
  CCIfType<[i32], CCAssignToReg<[A0, A1, A2, A3, A4, A5, A6, A7]>>,
  CCIfType<[f32], CCAssignToReg<[F10, F11, F12, F13, F14, F15, F16, F17]>>,
  // stack-located arguments are aligned to 4 bytes
  CCIfType<[i32], CCAssignToStack<4, 4>>,
  CCIfType<[f32], CCAssignToStack<4, 4>>
]>;

def CC_CPUX : CallingConv<[
  CCDelegateTo<CC_LP32>
]>;
