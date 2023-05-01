#ifndef LLVM_TRANSFORM_INSTRUMENTATION_PRINT_FUNC_H
#define LLVM_TRANSFORM_INSTRUMENTATION_PRINT_FUNC_H
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/PassManager.h"
#include "llvm/Support/raw_ostream.h"

namespace llvm {

class PrintFuncPass: public PassInfoMixin<PrintFuncPass> {
 public:
  PreservedAnalyses run(Module&, ModuleAnalysisManager&);
  static bool isRequired() {return true;}
}; // PrintFuncPass

} // namespace llvm

#endif // LLVM_TRANSFORM_INSTRUMENTATION_PRINT_FUNC_H
