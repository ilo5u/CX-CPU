#ifndef LLVM_LIB_TARGET_CHINX_CHINXTARGETOBJECTFILE_H
#define LLVM_LIB_TARGET_CHINX_CHINXTARGETOBJECTFILE_H

#include "ChinxTargetMachine.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"

// ----
// text
// ----
// data
// ----
// bss
// ----

namespace llvm {
	class ChinxTargetMachine;

	class ChinxTargetObjectFile : 
		public TargetLoweringObjectFileELF
	{
		MCSection *SmallDataSection;
		MCSection *SmallBSSSection;
		const ChinxTargetMachine *TM;

		public:
		void Initialize(MCContext &Ctx, const TargetMachine &TM) override;
	};
} // end namespace llvm

#endif

