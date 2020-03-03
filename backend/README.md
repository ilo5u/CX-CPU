# Preface
referenced sheet: Chen Chung-Shu.TutorialLLVMBackend,Release 3.9.1,2018
[referenced website](http://jonathan2251.github.io/lbd/doc.html#generale-cpu0-document)

# cmake/config-ix.cmake
Add 'CXCPU' as the identity of new processor.
Relatively, 'cxcpu' would be used as a parameter when compile c source files.
```cpp
elseif(LLVM_NATIVE_ARCH MATHCES "cxcpu")
  set(LLVM_NATIVE_ARCH CXCPU)
```

# CMakeLists.txt
Add 'CXCPU' as the identity of a new target machine.
```cpp
set(LLVM_ALL_TARGETS
  CXCPU
  )
```

# include/llvm/ADT/Triple.h
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

# include/llvm/Object/ELFObjectFile.h
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
