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
## include/llvm/Support/ELFRelocs/CXCPU.def
This definition file can reference to 'Mips.def'.
```cpp
#ifndef ELF_RELOC
#error "ELF_RELOC must be defined"
#endif

ELF_RELOC(R_CXCPU_NONE,                0)
ELF_RELOC(R_CXCPU_32,                  2)
ELF_RELOC(R_CXCPU_HI16,                5)
ELF_RELOC(R_CXCPU_LO16,                6)
ELF_RELOC(R_CXCPU_GPREL16,             7)
ELF_RELOC(R_CXCPU_LITERAL,             8)
ELF_RELOC(R_CXCPU_GOT16,               9)
ELF_RELOC(R_CXCPU_PC16,               10)
ELF_RELOC(R_CXCPU_CALL16,             11)
ELF_RELOC(R_CXCPU_GPREL32,            12)
ELF_RELOC(R_CXCPU_PC24,               13)
ELF_RELOC(R_CXCPU_GOT_HI16,           22)
ELF_RELOC(R_CXCPU_GOT_LO16,           23)
ELF_RELOC(R_CXCPU_RELGOT,             36)
ELF_RELOC(R_CXCPU_TLS_GD,             42)
ELF_RELOC(R_CXCPU_TLS_LDM,            43)
ELF_RELOC(R_CXCPU_TLS_DTPREL_HI16,    44)
ELF_RELOC(R_CXCPU_TLS_DTPREL_LO16,    45)
ELF_RELOC(R_CXCPU_TLS_GOTTPREL,       46)
ELF_RELOC(R_CXCPU_TLS_TPREL32,        47)
ELF_RELOC(R_CXCPU_TLS_TPREL_HI16,     49)
ELF_RELOC(R_CXCPU_TLS_TPREL_LO16,     50)
ELF_RELOC(R_CXCPU_GLOB_DAT,           51)
ELF_RELOC(R_CXCPU_JUMP_SLOT,  
```
## lib/Support/Triple.cpp
The modified strings can reference to mips.
```cpp
const char *Triple::getArchTypeName(ArchType Kind) {
  switch (Kind) {
  // modified
  case cxcpu:       return "cxcpu";
  case cxcpuel:     return "cxcpuel";
  }
}

const char *Triple::getArchTypePrefix(ArchType Kind) {
  switch (Kind) {
  // modified
  case cxcpu:
  case cxcpuel:     return "cxcpu";
  }
}

Triple::ArchType Triple::getArchTypeForLLVMName(StringRef Name) {
    // modified
    .Case("cxcpu", cxcpu)
    .Case("cxcpuel", cxcpuel)
}

static Triple::ArchType parseArch(StringRef ArchName) {
    // modified, may reference mips
    .Cases("cxcpu", "cxcpueb", "cxcpuallegrex", Triple::cxcpu)
    .Cases("cxcpuel", "cxcpuallegrexel", Triple::cxcpuel)
}

static Triple::ObjectFormatType getDefaultFormat(const Triple &T) {
  switch (T.getArch()) {
  // modified
  case Triple::cxcpu:
  case Triple::cxcpuel:
    return Triple::ELF;
  }
}

static unsigned getArchPointerBitWidth(llvm::Triple::ArchType Arch) {
  switch (Arch) {
  // modified
  case llvm::Triple::cxcpu:
  case llvm::Triple::cxcpuel:
    return 32;
}

Triple Triple::get32BitArchVariant() const {
  switch (getArch()) {
  // modified
  case Triple::cxcpu:
  case Triple::cxcpuel:
    // Already 32-bit.
    break;
  }
}
```
