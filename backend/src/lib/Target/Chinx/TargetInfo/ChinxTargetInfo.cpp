#include "Chinx.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

Target &llvm::getTheChinxTarget() {
  static Target TheChinxTarget;
  return TheChinxTarget;
}
//Target llvm::TheChinxelTarget;

extern "C" void LLVMInitializeChinxTargetInfo() {
    RegisterTarget<Triple::chinx, true>
            X(getTheChinxTarget(), "chinx", "Chinx", "Chinx");
    //RegisterTarget<Triple::chinxel, true>
    //        Y(TheChinxelTarget, "chinxel", "Chinxel");
}