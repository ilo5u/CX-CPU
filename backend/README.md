# /cmake/config-ix.cmake
...
elseif(LLVM_NATIVE_ARCH MATHCES "cxcpu")
  set(LLVM_NATIVE_ARCH CXCPU)
...

# /CMakeLists.txt
set(LLVM_ALL_TARGETS
  ...
  CXCPU
  )

# /include/llvm/ADT/Triple.h
class Triple {
public:
  enum ArchType {
    ...
    cxcpu,
    LastArchType = cxcpu
  };
  ...
};
