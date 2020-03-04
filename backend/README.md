# Preface
[Referenced sheet: Chen Chung-Shu.TutorialLLVMBackend,Release 3.9.1,2018](http://jonathan2251.github.io/lbd/doc.html#generale-cpu0-document)
# Modified Files
## cmake/config-ix.cmake
Add 'CXCPU' as the identity of new processor.
Relatively, 'cxcpu' would be used as a parameter when compile c source files.
```cpp
elseif(LLVM_NATIVE_ARCH MATHCES "cxcpu")
  set(LLVM_NATIVE_ARCH CXCPU)
```
## CMakeLists.txt
Add 'CXCPU' as the identity of a new target machine.
```cpp
set(LLVM_ALL_TARGETS
  CXCPU
  )
```
## include/llvm/ADT/Triple.h
Add the identity of architecture[big/little-endian] about the new target machine.
```cpp
class Triple {
public:
  enum ArchType {
    cxcpu,
    cxcpuel,
    LastArchType = cxcpuel
  };
};
```
## include/llvm/Object/ELFObjectFile.h
Selection of big or little endian model.
```cpp
switch(EF.getHeader()->e_ident[ELF:EI_CLASS]){
  case ELF::ELFCLASS32:
    switch(EF.getHeader()->e_machine){
      case ELF::EM_CXCPU:
        return "ELF32-cxcpu";
    }
}

switch(EF.getHeader()->e_machine){
  case ELF::EM_CXCPU:
  switch(EF.getHeader()->e_ident[ELF::EI_CLASS]){
    case ELF::ELFCALSS32:
      return IsLittleEndian ? Triple::cxcpuel : cxcpu;
    default:
      report_fatal_error("Invalid ELFCLASS!");
  }
}
```
## include/llvm/Support/ELF.h
Add e_flags of CX-CPU.
```cpp
enum {
  EM_CXCPU         = 236  // CX CPU architecture 
};

// Specific e_flags for CXCPU
enum {
  EF_CXCPU_NOREORDER = 0x00000001; // Don't reorder instructions
  EF_CXCPU_PIC       = 0x00000002; // Position independent code
  EF_CXCPU_ARCH_32   = 0x50000000; // CXCPU32 instruction set per linux not elf.h
  EF_CXCPU_ARCH      = 0xf0000000; // Mask for applying EF_CXCPU_ARCH_ variant
};

// ELF Relocation types for CXCPU
enum {
#include "ELFRelocs/CXCPU.def"
};
```

## lib/MC/MCSubtargetInfo.cpp
Add flag to disable the unrecognized message about CX-CPU.
```cpp
// Modified with CX-CPU
bool CXCPUDisableUnrecognizedMessage = false;

void MCSubtargetInfo::InitMCProcessorInfo(StringRef CPU, StringRef FS) {
#if 1 // Disable unrecognized processor message about CX-CPU.
  if (TargetTriple.getArch() == llvm::Triple::cxcpu ||
      TargetTriple.getArch() == llvm::Triple::cxcpuel)
    CXCPUDisableUnrecognizedMessage = true;
#endif
}

const MCSchedModel &MCSubtargetInfo::getSchedModelForCPU(StringRef CPU) const {
#if 1 // Disable recognized processor message. For CXCPU
  if (TargetTriple.getArch() != llvm::Triple::cxcpu &&
      TargetTriple.getArch() != llvm::Triple::cxcpuel)
#endif
      errs() << "'" << CPU
             << "' is not a recognized processor for this target"
             << " (ignoring processor)\n";
}
```

## lib/MC/SubtargetFeature.cpp
Disable the unrecognized message about CX-CPU.
```cpp
FeatureBitset
SubtargetFeatures::ToggleFeature(FeatureBitset Bits, StringRef Feature,
                                 ArrayRef<SubtargetFeatureKV> FeatureTable) {
#if 1 // Do not show unrecognized message about CX-CPU.
    if (!CXCPUDisableUnrecognizedMessage)
#endif
    errs() << "'" << Feature
           << "' is not a recognized feature for this target"
           << " (ignoring feature)\n";
}

FeatureBitset
SubtargetFeatures::ApplyFeatureFlag(FeatureBitset Bits, StringRef Feature,
                                    ArrayRef<SubtargetFeatureKV> FeatureTable) {
#if 1 // Do not show unrecognized message about CX-CPU.
    if (!CXCPUDisableUnrecognizedMessage)
#endif
    errs() << "'" << Feature
           << "' is not a recognized feature for this target"
           << " (ignoring feature)\n";
}

FeatureBitset
SubtargetFeatures::getFeatureBits(StringRef CPU,
                                  ArrayRef<SubtargetFeatureKV> CPUTable,
                                  ArrayRef<SubtargetFeatureKV> FeatureTable) {
#if 1 // Do not show unrecognized message about CX-CPU.
      if (!CXCPUDisableUnrecognizedMessage)
#endif
      errs() << "'" << CPU
             << "' is not a recognized processor for this target"
             << " (ignoring processor)\n";
}
```

## lib/Object/ELF.cpp
```cpp
StringRef getELFRelocationTypeName(uint32_t Machine, uint32_t Type) {
  case ELF::EM_CXCPU:
    switch (Type) {
#include "llvm/Support/ELFRelocs/CXCPU.def"
    default:
      break;
    }
}
```

