//===-- ChinxInstrInfo.cpp - Chinx Instruction Information ------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the Chinx implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#include "ChinxInstrInfo.h"
#include "ChinxTargetMachine.h"
#include "ChinxMachineFunction.h"

#include "llvm/ADT/STLExtras.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define GET_INSTRINFO_CTOR_DTOR
#include "ChinxGenInstrInfo.inc"

// Pin the vtable to this file.
void ChinxInstrInfo::anchor() {}

ChinxInstrInfo::ChinxInstrInfo(const ChinxSubtarget &ST)
    : RI(ST), Subtarget(ST) {}

const ChinxInstrInfo* ChinxInstrInfo::create(ChinxSubtarget &ST) {
	return new ChinxInstrInfo{ST};
}

const ChinxRegisterInfo &ChinxInstrInfo::getRegisterInfo() const {
	return RI;
}

/// Return the number of bytes of code the specified instruction may be.
unsigned ChinxInstrInfo::GetInstSizeInBytes(const MachineInstr &MI) const {
	switch (MI.getOpcode()) {
	default:
		return MI.getDesc().getSize();
	}
}

void ChinxInstrInfo::storeRegToStack(MachineBasicBlock &MBB,
	MachineBasicBlock::iterator I, unsigned SrcReg, bool isKill, int FI,
	const TargetRegisterClass *RC, const TargetRegisterInfo *TRI, int64_t Offset) const {
	DebugLoc DL;
	MachineMemOperand *MMO = GetMemOperand(MBB, FI, MachineMemOperand::MOStore);
	unsigned Opc = Chinx::SW;
	assert(Opc && "Register class not handled!");
	BuildMI(MBB, I, DL, get(Opc)).addReg(SrcReg, getKillRegState(isKill))
		.addFrameIndex(FI).addImm(Offset).addMemOperand(MMO);
}

void ChinxInstrInfo::loadRegFromStack(MachineBasicBlock &MBB,
	MachineBasicBlock::iterator I, unsigned DestReg, int FI,
	const TargetRegisterClass *TRC,
	const TargetRegisterInfo *TRI, int64_t Offset) const {
	DebugLoc DL;
	if (I != MBB.end()) DL = I->getDebugLoc();
	MachineMemOperand *MMO = GetMemOperand(MBB, FI, MachineMemOperand::MOLoad);
	unsigned Opc = Chinx::LW;
	assert(Opc && "Register class not handled!");
	BuildMI(MBB, I, DL, get(Opc), DestReg).addFrameIndex(FI).addImm(Offset)
		.addMemOperand(MMO);
}

/// Expand Pseudo instructions into real backend instructions
bool ChinxInstrInfo::expandPostRAPseudo(MachineInstr &MI) const {
	//@expandPostRAPseudo-body
	MachineBasicBlock &MBB = *MI.getParent();

	switch (MI.getDesc().getOpcode()) {
	default:
		return false;
	case Chinx::RetRA:
		expandRetRA(MBB, MI);
		break;
	}
	MBB.erase(MI);
	return true;
}

/// Adjust SP by Amount bytes.
void ChinxInstrInfo::adjustStackPtr(unsigned SP, int64_t Amount,
	MachineBasicBlock &MBB, MachineBasicBlock::iterator I) const {
	DebugLoc DL = I != MBB.end() ? I->getDebugLoc() : DebugLoc();
	unsigned ADD = Chinx::ADD; // add ra,rb,rc
	unsigned ADDI = Chinx::ADDI; // addi ra,rb,imm16
	// Suppose that the stack size would only
	// arrange from -2^15 to 2^15 - 1.
    assert(isInt<16>(Amount));
	// addiu sp, sp, amount
	BuildMI(MBB, I, DL, get(ADDI), SP).addReg(SP).addImm(Amount);
}

void ChinxInstrInfo::expandRetRA(MachineBasicBlock &MBB,
	MachineBasicBlock::iterator I) const {
	BuildMI(MBB, I, I->getDebugLoc(), get(Chinx::RET)).addReg(Chinx::RA);
}

MachineMemOperand * ChinxInstrInfo::GetMemOperand(MachineBasicBlock &MBB,
	int FI,	MachineMemOperand::Flags Flags) const {
  MachineFunction &MF = *MBB.getParent();
  MachineFrameInfo &MFI = MF.getFrameInfo();
  unsigned Align = MFI.getObjectAlignment(FI);

  return MF.getMachineMemOperand(MachinePointerInfo::getFixedStack(MF, FI),
    Flags, MFI.getObjectSize(FI), Align);
}

