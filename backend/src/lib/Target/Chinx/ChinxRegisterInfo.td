class ChinxReg<bits<16> Enc, string n> : Register<n> {
    let HWEncoding = Enc;
    let Namespace = "Chinx";
}

let Namespace = "Chinx" in {
    def ZERO : ChinxReg<0, "zero">, DwarfRegNum<[0]>;
    def AT : ChinxReg<1, "1">, DwarfRegNum<[1]>;
    def V0 : ChinxReg<2, "2">, DwarfRegNum<[2]>;
    def V1 : ChinxReg<3, "3">, DwarfRegNum<[3]>;
    def A0 : ChinxReg<4, "4">, DwarfRegNum<[4]>;
    def A1 : ChinxReg<5, "5">, DwarfRegNum<[5]>;
    def A2 : ChinxReg<6, "6">, DwarfRegNum<[6]>;
    def A3 : ChinxReg<7, "7">, DwarfRegNum<[7]>;
    def T0 : ChinxReg<8, "8">, DwarfRegNum<[8]>;
    def T1 : ChinxReg<9, "9">, DwarfRegNum<[9]>;
    def T2 : ChinxReg<10, "10">, DwarfRegNum<[10]>;
    def T3 : ChinxReg<11, "11">, DwarfRegNum<[11]>;
    def T4 : ChinxReg<12, "12">, DwarfRegNum<[12]>;
    def T5 : ChinxReg<13, "13">, DwarfRegNum<[13]>;
    def T6 : ChinxReg<14, "14">, DwarfRegNum<[14]>;
    def T7 : ChinxReg<15, "15">, DwarfRegNum<[15]>;
    def T8 : ChinxReg<16, "16">, DwarfRegNum<[16]>;
    def T9 : ChinxReg<17, "17">, DwarfRegNum<[17]>;
    def S0 : ChinxReg<18, "18">, DwarfRegNum<[18]>;
    def S1 : ChinxReg<19, "19">, DwarfRegNum<[19]>;
    def S2 : ChinxReg<20, "20">, DwarfRegNum<[20]>;
    def S3 : ChinxReg<21, "21">, DwarfRegNum<[21]>;
    def S4 : ChinxReg<22, "22">, DwarfRegNum<[22]>;
    def S5 : ChinxReg<23, "23">, DwarfRegNum<[23]>;
    def S6 : ChinxReg<24, "24">, DwarfRegNum<[24]>;
    def S7 : ChinxReg<25, "25">, DwarfRegNum<[25]>;
    def K0 : ChinxReg<26, "26">, DwarfRegNum<[26]>;
    def K1 : ChinxReg<27, "27">, DwarfRegNum<[27]>;
    def GP : ChinxReg<28, "gp">, DwarfRegNum<[28]>;
    def SP : ChinxReg<29, "sp">, DwarfRegNum<[29]>;
    def FP : ChinxReg<30, "fp">, DwarfRegNum<[30]>;
    def RA : ChinxReg<31, "ra">, DwarfRegNum<[31]>;
}

def CPURegs : RegisterClass<"Chinx", [i32], 32, (add
    ZERO, AT,
    V0, V1, A0, A1, A2, A3,
    T0, T1, T2, T3, T4, T5, T6, T7, T8, T9,
    S0, S1, S2, S3, S4, S5, S6, S7,
    K0, K1,
    GP, SP, FP, RA)>;

def WRERegs : RegisterClass<"Chinx", [i32], 32, (add (sub CPURegs, K0, K1))>;
def MEMRegs : RegisterClass<"Chinx", [i32], 32, (add (sub CPURegs, ZERO, K0, K1, RA))>;