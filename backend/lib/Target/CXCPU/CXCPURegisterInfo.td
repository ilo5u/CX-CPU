//===-- CXCPURegisterInfo.td - CXCPU Register defs -----------*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Declarations that describe the CXCPU register file
//===----------------------------------------------------------------------===//

class Unallocatable {
  bit isAllocatable = 0;
}

// We have banks of 32 registers each.
class CXCPUReg<bits<16> Enc, string n> : Register<n> {
  let HWEncoding = Enc;
  let Namespace = "CXCPU";
}

// CXCPU CPU Registers
class CXCPUGPRReg<bits<16> Enc, string n> : CXCPUReg<Enc, n>;

// Accumulator Registers
// class ACCReg<bits<16> Enc, string n, list<Register> subregs>
//    : CXCPURegWithSubRegs<Enc, n, subregs> {
//   let SubRegIndices = [sub_lo, sub_hi];
//   let CoveredBySubRegs = 1;
// }

//===----------------------------------------------------------------------===//
//  Registers
//===----------------------------------------------------------------------===//

let Namespace = "CXCPU" in {
  // General Purpose Registers
  def ZERO : CXCPUGPRReg< 0, "zero">, DwarfRegNum<[0]>;
  def AT   : CXCPUGPRReg< 1, "1">,    DwarfRegNum<[1]>;
  def V0   : CXCPUGPRReg< 2, "2">,    DwarfRegNum<[2]>;
  def V1   : CXCPUGPRReg< 3, "3">,    DwarfRegNum<[3]>;
  def A0   : CXCPUGPRReg< 4, "4">,    DwarfRegNum<[4]>;
  def A1   : CXCPUGPRReg< 5, "5">,    DwarfRegNum<[5]>;
  def A2   : CXCPUGPRReg< 6, "6">,    DwarfRegNum<[6]>;
  def A3   : CXCPUGPRReg< 7, "7">,    DwarfRegNum<[7]>;
  def T0   : CXCPUGPRReg< 8, "8">,    DwarfRegNum<[8]>;
  def T1   : CXCPUGPRReg< 9, "9">,    DwarfRegNum<[9]>;
  def T2   : CXCPUGPRReg< 10, "10">,  DwarfRegNum<[10]>;
  def T3   : CXCPUGPRReg< 11, "11">,  DwarfRegNum<[11]>;
  def T4   : CXCPUGPRReg< 12, "12">,  DwarfRegNum<[12]>;
  def T5   : CXCPUGPRReg< 13, "13">,  DwarfRegNum<[13]>;
  def T6   : CXCPUGPRReg< 14, "14">,  DwarfRegNum<[14]>;
  def T7   : CXCPUGPRReg< 15, "15">,  DwarfRegNum<[15]>;
  def S0   : CXCPUGPRReg< 16, "16">,  DwarfRegNum<[16]>;
  def S1   : CXCPUGPRReg< 17, "17">,  DwarfRegNum<[17]>;
  def S2   : CXCPUGPRReg< 18, "18">,  DwarfRegNum<[18]>;
  def S3   : CXCPUGPRReg< 19, "19">,  DwarfRegNum<[19]>;
  def S4   : CXCPUGPRReg< 20, "20">,  DwarfRegNum<[20]>;
  def S5   : CXCPUGPRReg< 21, "21">,  DwarfRegNum<[21]>;
  def S6   : CXCPUGPRReg< 22, "22">,  DwarfRegNum<[22]>;
  def S7   : CXCPUGPRReg< 23, "23">,  DwarfRegNum<[23]>;
  def T8   : CXCPUGPRReg< 24, "24">,  DwarfRegNum<[24]>;
  def T9   : CXCPUGPRReg< 25, "25">,  DwarfRegNum<[25]>;
  def K0   : CXCPUGPRReg< 26, "26">,  DwarfRegNum<[26]>;
  def K1   : CXCPUGPRReg< 27, "27">,  DwarfRegNum<[27]>;
  def GP   : CXCPUGPRReg< 28, "gp">,  DwarfRegNum<[28]>;
  def SP   : CXCPUGPRReg< 29, "sp">,  DwarfRegNum<[29]>;
  def FP   : CXCPUGPRReg< 30, "fp">,  DwarfRegNum<[30]>;
  def RA   : CXCPUGPRReg< 31, "ra">,  DwarfRegNum<[31]>;

  // Hi/Lo registers
  def HI : CXCPUReg<0, "hi">, DwarfRegNum<[32]>;
  def LO : CXCPUReg<1, "lo">, DwarfRegNum<[33]>;

  // Co-processor registers
  def PC  : CXCPUCP0Reg<0, "pc">,   DwarfRegNum<[34]>;
  def EPC : CXCPUCP0Reg<1, "epc">,  DwarfRegNum<[35]>;
}

//===----------------------------------------------------------------------===//
// Register Classes
//===----------------------------------------------------------------------===//

class CXCPUGPRRegs :
  RegisterClass<"CXCPU", [i32], 32, (add
  // Reserved
  ZERO, AT,
  // Return Values and Arguments
  V0, V1, A0, A1, A2, A3,
  // Not preserved across procedure calls
  T0, T1, T2, T3, T4, T5, T6, T7,
  // Callee save
  S0, S1, S2, S3, S4, S5, S6, S7,
  // Not preserved across procedure calls
  T8, T9,
  // Reserved
  K0, K1, GP, SP, FP, RA)>;

// Status Registers class
def CPUSWReg : RegisterClass<"CXCPU", [i32], 32, (add K1)>, Unallocatable;

def CPURAReg : RegisterClass<"CXCPU", [i32], 32, (add RA)>, Unallocatable;

def CPUSPReg : RegisterClass<"CXCPU", [i32], 32, (add SP)>, Unallocatable;

/// Hi/Lo Registers
def LO32 : RegisterClass<"CXCPU", [i32], 32, (add LO)>;
def HI32 : RegisterClass<"CXCPU", [i32], 32, (add HI)>;

// Co-processor 0 Register class
def CP0Regs : RegisterClass<"CXCPU", [i32], 32, (add PC, EPC)>;

// Accumulator Registers
// def ACC64 : RegisterClass<"CXCPU", [untyped], 64, (add AC0)> {
//   let Size = 64;
// }

def CPUGPROuts : RegisterClass<"CXCPU", [i32], 32, (add (sub CPUGPRRegs, K1))>;
