#include "Chinx.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

Target llvm::TheChinxTarget;
Target llvm::TheChinxelTarget;

extern "C" void LLVMInitializeChinxTargetInfo() {
    RegisterTarget<Triple::chinx, true>
            X(TheChinxTarget, "chinx", "Chinx");
    RegisterTarget<Triple::chinxel, true>
            Y(TheChinxelTarget, "chinxel", "Chinxel");
}