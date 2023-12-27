class CPUXReg<bits<16> Enc, string n> : Register<n> {
  let HWEncoding = Enc;
  let Namespace = "CPUX";
}

class CPUXGPRReg<bits<16> Enc, string n> : CPUXReg<Enc, n>;
class CPUX0Reg<bits<16> Enc, string n> : CPUXReg<Enc, n>;

let Namespace = "CPUX" in {
  def ZERO : CPUX0Reg<0, "zero">, DwarfRegNum<[0]>;
}

def CPURegs: RegisterClass<"CPUX", [i32], 32, (add ZERO)>;
