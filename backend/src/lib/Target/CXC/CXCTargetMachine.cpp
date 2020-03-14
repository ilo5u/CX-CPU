#include "CXCTargetMachine.h"
#include "CXC.h"

#include "llvm/IR/LegacyPassManager.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/Support/TargetRegistry.h"
using namespace llvm;

#define DEBUG_TYPE "cxc"

extern "C" void LLVMInitializeCXCTarget() {
    
}