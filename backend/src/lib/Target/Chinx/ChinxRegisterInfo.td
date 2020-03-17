class ChinxReg<bits<16> Enc, string n> : Register<n> {
    let HWEncoding = Enc;
    let Namespace = "Chinx";
}

class ChinxGPRReg<bits<16> Enc, string n> : ChinxReg<Enc, n>;

class ChinxC0Reg<bits<16> Enc, string n> : ChinxReg<Enc, n>;

let Namespace = "Chinx" in {
    def ZERO : ChinxGPRReg<0, "zero">, DwarfRegNum<[0]>;
    def AT : ChinxGPRReg<1, "1">, DwarfRegNum<[1]>;
    def V0 : ChinxGPRReg<2, "2">, DwarfRegNum<[2]>;
    def V1 : ChinxGPRReg<3, "3">, DwarfRegNum<[3]>;
    def A0 : ChinxGPRReg<4, "4">, DwarfRegNum<[4]>;
    def A1 : ChinxGPRReg<5, "5">, DwarfRegNum<[5]>;
    def A2 : ChinxGPRReg<6, "6">, DwarfRegNum<[6]>;
    def A3 : ChinxGPRReg<7, "7">, DwarfRegNum<[7]>;
    def T0 : ChinxGPRReg<8, "8">, DwarfRegNum<[8]>;
    def T1 : ChinxGPRReg<9, "9">, DwarfRegNum<[9]>;
    def T2 : ChinxGPRReg<10, "10">, DwarfRegNum<[10]>;
    def T3 : ChinxGPRReg<11, "11">, DwarfRegNum<[11]>;
    def T4 : ChinxGPRReg<12, "12">, DwarfRegNum<[12]>;
    def T5 : ChinxGPRReg<13, "13">, DwarfRegNum<[13]>;
    def T6 : ChinxGPRReg<14, "14">, DwarfRegNum<[14]>;
    def T7 : ChinxGPRReg<15, "15">, DwarfRegNum<[15]>;
    def T8 : ChinxGPRReg<16, "16">, DwarfRegNum<[16]>;
    def T9 : ChinxGPRReg<17, "17">, DwarfRegNum<[17]>;
    def S0 : ChinxGPRReg<18, "18">, DwarfRegNum<[18]>;
    def S1 : ChinxGPRReg<19, "19">, DwarfRegNum<[19]>;
    def S2 : ChinxGPRReg<20, "20">, DwarfRegNum<[20]>;
    def S3 : ChinxGPRReg<21, "21">, DwarfRegNum<[21]>;
    def S4 : ChinxGPRReg<22, "22">, DwarfRegNum<[22]>;
    def S5 : ChinxGPRReg<23, "23">, DwarfRegNum<[23]>;
    def S6 : ChinxGPRReg<24, "24">, DwarfRegNum<[24]>;
    def S7 : ChinxGPRReg<25, "25">, DwarfRegNum<[25]>;
    def K0 : ChinxGPRReg<26, "26">, DwarfRegNum<[26]>;
    def K1 : ChinxGPRReg<27, "27">, DwarfRegNum<[27]>;
    def GP : ChinxGPRReg<28, "gp">, DwarfRegNum<[28]>;
    def SP : ChinxGPRReg<29, "sp">, DwarfRegNum<[29]>;
    def FP : ChinxGPRReg<30, "fp">, DwarfRegNum<[30]>;
    def RA : ChinxGPRReg<31, "ra">, DwarfRegNum<[31]>;

    def PC : ChinxC0Reg<0, "pc">, DwarfRegNum<[32]>;
    def EPC : ChinxC0Reg<1, "epc">, DwarfRegNum<[33]>;
}

def CPURegs : RegisterClass<"Chinx", [i32], 32, (add
    ZERO, AT,
    V0, V1, A0, A1, A2, A3,
    T0, T1, T2, T3, T4, T5, T6, T7, T8, T9,
    S0, S1, S2, S3, S4, S5, S6, S7,
    K0, K1,
    GP, SP, FP, RA)>;

def C0Regs : RegisterClass<"Chinx", [i32], 32, (add PC, EPC)>;

def GPROut : RegisterClass<"Chinx", [i32], 32, (add CPURegs)>;