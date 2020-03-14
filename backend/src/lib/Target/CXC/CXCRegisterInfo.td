// we have banks of 32 registers each.
class CXCReg<bits<32> Enc, string n> : Register<n> {
    // for tablegen(... -gen-emitter) in CMakeLists.txt
    let HWEncoding = Enc;
    let Namespace = "CXC";
}

// GPR register class
class CXCGPRReg<bits<32> Enc, string n> : CXCReg<Enc, n>;

// Co-processor 0 register class
class CXCC0Reg<bits<32> Enc, string n> : CXCReg<Enc, n>;

let Namespace = "CXC" in {
    def ZERO    : CXCGPRReg<0, "zero">   , DwarfRegNum<[0]>;
    def AT      : CXCGPRReg<1, "1">      , DwarfRegNum<[1]>;
    def V0      : CXCGPRReg<2, "2">      , DwarfRegNum<[2]>;
    def V1      : CXCGPRReg<3, "3">      , DwarfRegNum<[3]>;
    def A0      : CXCGPRReg<4, "4">      , DwarfRegNum<[4]>;
    def A1      : CXCGPRReg<5, "5">      , DwarfRegNum<[5]>;
    def A2      : CXCGPRReg<6, "6">      , DwarfRegNum<[6]>;
    def A3      : CXCGPRReg<7, "7">      , DwarfRegNum<[7]>;
    def T0      : CXCGPRReg<8, "8">      , DwarfRegNum<[8]>;
    def T1      : CXCGPRReg<9, "9">      , DwarfRegNum<[9]>;
    def T2      : CXCGPRReg<10, "10">    , DwarfRegNum<[10]>;
    def T3      : CXCGPRReg<11, "11">    , DwarfRegNum<[11]>;
    def T4      : CXCGPRReg<12, "12">    , DwarfRegNum<[12]>;
    def T5      : CXCGPRReg<13, "13">    , DwarfRegNum<[13]>;
    def T6      : CXCGPRReg<14, "14">    , DwarfRegNum<[14]>;
    def T7      : CXCGPRReg<15, "15">    , DwarfRegNum<[15]>;
    def T8      : CXCGPRReg<16, "16">    , DwarfRegNum<[16]>;
    def T9      : CXCGPRReg<17, "17">    , DwarfRegNum<[17]>;
    def S0      : CXCGPRReg<18, "18">    , DwarfRegNum<[18]>;
    def S1      : CXCGPRReg<19, "19">    , DwarfRegNum<[19]>;
    def S2      : CXCGPRReg<20, "20">    , DwarfRegNum<[20]>;
    def S3      : CXCGPRReg<21, "21">    , DwarfRegNum<[21]>;
    def S4      : CXCGPRReg<22, "22">    , DwarfRegNum<[22]>;
    def S5      : CXCGPRReg<23, "23">    , DwarfRegNum<[23]>;
    def S6      : CXCGPRReg<24, "24">    , DwarfRegNum<[24]>;
    def S7      : CXCGPRReg<25, "25">    , DwarfRegNum<[25]>;
    def K0      : CXCGPRReg<26, "26">    , DwarfRegNum<[26]>;
    def K1      : CXCGPRReg<27, "27">    , DwarfRegNum<[27]>;
    def GP      : CXCGPRReg<28, "gp">    , DwarfRegNum<[28]>;
    def SP      : CXCGPRReg<29, "sp">    , DwarfRegNum<[29]>;
    def FP      : CXCGPRReg<30, "fp">    , DwarfRegNum<[30]>;
    def RA      : CXCGPRReg<31, "ra">    , DwarfRegNum<[31]>;

    def PC      : CXCC0Reg<0, "pc">      , DwarfRegNum<[32]>;
    def EPC     : CXCC0Reg<1, "epc">     , DwarfRegNum<[33]>;
}

def CPURegs : RegisterClass<"CXC", [i32], 32, (add
    // reserved
    ZERO, AT,
    // return values and arguments
    V0, V1, A0, A1, A2, A3,
    // not preserved across procedure calls
    T0, T1, T2, T3, T4, T5, T6, T7, T8, T9,
    // callee saves
    S0, S1, S2, S3, S4, S5, S6, S7,
    // reserved
    K0, K1,
    GP, SP, FP, RA
)>;

def C0Regs : RegisterClass<"CXC", [i32], 32, (add PC, EPC)>;

def GRPOut : RegisterClass<"CXC", [i32], 32, (add CPURegs)>;