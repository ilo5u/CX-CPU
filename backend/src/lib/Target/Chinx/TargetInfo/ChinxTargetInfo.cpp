#include "Chinx.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

Target &llvm::getTheChinxTarget() {
  static Target TheChinxTarget;
  return TheChinxTarget;
}

extern "C" void LLVMInitializeChinxTargetInfo() {
    RegisterTarget<Triple::chinx, true>
            X(getTheChinxTarget(), "chinx", "Chinx", "Chinx");
}