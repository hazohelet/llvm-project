let Namespace = "CPUX" in {
  class CPUXReg<bits<5> Enc, string n, list<string> alt=[]>
    : Register<n> {
    let HWEncoding{4-0} = Enc;
    let AltNames = alt;
  }
}

class CPUXGPRReg<bits<5> Enc, string n, list<string> alt>
  : CPUXReg<Enc, n, alt>;
let Namespace = "CPUX" in {
  def ZERO: CPUXGPRReg<0, "x0", ["zero"]>, DwarfRegNum<[0]>;
  def RA  : CPUXGPRReg<1, "x1", ["ra"]>,        DwarfRegNum<[1]>;
  def SP  : CPUXGPRReg<2, "x2", ["sp"]>,        DwarfRegNum<[2]>;
  def GP  : CPUXGPRReg<3, "x3", ["gp"]>,        DwarfRegNum<[3]>;
  def TP  : CPUXGPRReg<4, "x4", ["tp"]>,       DwarfRegNum<[4]>;
  def T0  : CPUXGPRReg<5, "x5", ["t0"]>,       DwarfRegNum<[5]>;
  def T1  : CPUXGPRReg<6, "x6", ["t1"]>,       DwarfRegNum<[6]>;
  def T2  : CPUXGPRReg<7, "x7", ["t2"]>,       DwarfRegNum<[7]>;
  def FP  : CPUXGPRReg<8, "x8", ["s0", "fp"]>, DwarfRegNum<[8]>;
  def S1  : CPUXGPRReg<9, "x9", ["s1"]>,       DwarfRegNum<[9]>;

  def A0  : CPUXGPRReg<10, "x10", ["a0"]>,     DwarfRegNum<[10]>;
  def A1  : CPUXGPRReg<11, "x11", ["a1"]>,     DwarfRegNum<[11]>;
  def A2  : CPUXGPRReg<12, "x12", ["a2"]>,     DwarfRegNum<[12]>;
  def A3  : CPUXGPRReg<13, "x13", ["a3"]>,     DwarfRegNum<[13]>;
  def A4  : CPUXGPRReg<14, "x14", ["a4"]>,     DwarfRegNum<[14]>;
  def A5  : CPUXGPRReg<15, "x15", ["a5"]>,     DwarfRegNum<[15]>;
  def A6  : CPUXGPRReg<16, "x16", ["a6"]>,     DwarfRegNum<[16]>;
  def A7  : CPUXGPRReg<17, "x17", ["a7"]>,     DwarfRegNum<[17]>;

  def S2  : CPUXGPRReg<18, "x18", ["s2"]>,     DwarfRegNum<[18]>;
  def S3  : CPUXGPRReg<19, "x19", ["s3"]>,     DwarfRegNum<[19]>;
  def S4  : CPUXGPRReg<20, "x20", ["s4"]>,     DwarfRegNum<[20]>;
  def S5  : CPUXGPRReg<21, "x21", ["s5"]>,     DwarfRegNum<[21]>;
  def S6  : CPUXGPRReg<22, "x22", ["s6"]>,     DwarfRegNum<[22]>;
  def S7  : CPUXGPRReg<23, "x23", ["s7"]>,     DwarfRegNum<[23]>;
  def S8  : CPUXGPRReg<24, "x24", ["s8"]>,     DwarfRegNum<[24]>;
  def S9  : CPUXGPRReg<25, "x25", ["s9"]>,     DwarfRegNum<[25]>;
  def S10 : CPUXGPRReg<26, "x26", ["s10"]>,    DwarfRegNum<[26]>;
  def S11 : CPUXGPRReg<27, "x27", ["s11"]>,    DwarfRegNum<[27]>;
  def T3  : CPUXGPRReg<28, "x28", ["t3"]>,     DwarfRegNum<[28]>;
  def T4  : CPUXGPRReg<29, "x29", ["t4"]>,     DwarfRegNum<[29]>;
  def T5  : CPUXGPRReg<30, "x30", ["t5"]>,     DwarfRegNum<[30]>;
  def T6  : CPUXGPRReg<31, "x31", ["t6"]>,     DwarfRegNum<[31]>;
}

def GPR: RegisterClass<"CPUX", [i32], 32, (add
  ZERO,
  A0, A1, A2, A3, A4, A5, A6, A7,
  T0, T1, T2, T3, T4, T5, T6,
  FP, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11,
  RA, SP, GP, TP
  )> {
  let RegInfos = RegInfoByHwMode<
  [DefaultMode], [RegInfo<32, 32, 32>]
  >;
}

