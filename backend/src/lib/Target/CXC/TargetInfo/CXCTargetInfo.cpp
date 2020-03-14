#include "CXC.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/TargetRegistry.h"
using namespace llvm;

Target llvm::TheCXCTarget;

extern "C" void LLVMInitializeCXCTargetInfo() {
    RegisterTarget<Triple::CXC,
        true> X(TheCXCTarget, "cxc", "CXC");
}