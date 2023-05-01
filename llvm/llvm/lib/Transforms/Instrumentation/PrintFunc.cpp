#include "llvm/Transforms/Instrumentation/PrintFunc.h"

namespace llvm {

PreservedAnalyses PrintFuncPass::run(Module& M, ModuleAnalysisManager& AM) {
  LLVMContext& C = M.getContext();
  IntegerType* Int32Ty = IntegerType::getInt32Ty(C);
  // IntegerType* Int64Ty = IntegerType::getInt64Ty(C);
  PointerType* Ptr8Ty = PointerType::getInt8PtrTy(C); 
  ConstantPointerNull* NullPtr8 = ConstantPointerNull::get(Ptr8Ty);
  
  FunctionCallee FputsFunc = M.getOrInsertFunction("fputs", FunctionType::get(Int32Ty, {Ptr8Ty, Ptr8Ty}, false));
  FunctionCallee FprintfFunc = M.getOrInsertFunction("fprintf", FunctionType::get(Int32Ty, {Ptr8Ty}, true));
  FunctionCallee FopenFunc = M.getOrInsertFunction("fopen", FunctionType::get(Ptr8Ty, {Int32Ty, Ptr8Ty}, false));
  FunctionCallee GetpidFunc = M.getOrInsertFunction("getpid", FunctionType::get(Int32Ty, {}, false));
  FunctionCallee StrcmpFunc = M.getOrInsertFunction("strcmp", FunctionType::get(Int32Ty, {Ptr8Ty, Ptr8Ty}, false));
  
  GlobalVariable* FilePtrGV = new GlobalVariable(M, Ptr8Ty, false, GlobalValue::CommonLinkage, NullPtr8, "__print_func_ofile");
  GlobalVariable* PrevFuncGV = new GlobalVariable(M, Ptr8Ty, false, GlobalValue::CommonLinkage, NullPtr8, "__print_func_prev_func");

  for (auto &F: M) {
    if (F.isDeclaration()) {
      continue;
    }
    BasicBlock& BB = F.getEntryBlock();
    BasicBlock* CheckBB = &BB;
    BasicBlock* SetupBB = CheckBB->splitBasicBlock(CheckBB->getFirstInsertionPt(), "__print_func_setup");
    BasicBlock* ChkRecurBB = SetupBB->splitBasicBlock(SetupBB->getFirstInsertionPt(), "__print_func_chk_recur");
    BasicBlock* PrintBB = ChkRecurBB->splitBasicBlock(ChkRecurBB->getFirstInsertionPt(), "__print_func_print");
    BasicBlock* RetBB = PrintBB->splitBasicBlock(PrintBB->getFirstInsertionPt(), "__print_func_ret");
  
    std::string SrcFile = F.getParent()->getSourceFileName();
    std::string s = SrcFile + ":" + F.getName().str() + "| pid:%8u\n";

    // CheckBB
    IRBuilder<> CheckIRB(CheckBB->getTerminator());
    LoadInst* LdFilePtr = CheckIRB.CreateLoad(Ptr8Ty, FilePtrGV);
    Value* TestFilePtrGV = CheckIRB.CreateICmpEQ(LdFilePtr, NullPtr8);
    CheckIRB.CreateCondBr(TestFilePtrGV, SetupBB, ChkRecurBB);
    CheckBB->getTerminator()->eraseFromParent();

    // SetupBB
    IRBuilder<> SetupIRB(SetupBB->getTerminator());
    Value* TraceFileName = SetupIRB.CreateGlobalStringPtr("trace.txt");
    Value* WriteMode = SetupIRB.CreateGlobalStringPtr("w+");
    Value* FileStructPtr = SetupIRB.CreateCall(FopenFunc, {TraceFileName, WriteMode});
    SetupIRB.CreateStore(FileStructPtr, FilePtrGV);
    Value* SuccessStr = SetupIRB.CreateGlobalStringPtr("[LLVM_TRACE] Success fd open\n");
    LoadInst* LdFilePtr3 = SetupIRB.CreateLoad(Ptr8Ty, FilePtrGV);
    SetupIRB.CreateCall(FputsFunc, {SuccessStr, LdFilePtr3});
    SetupIRB.CreateBr(PrintBB);
   
    // CheckRecursive
    IRBuilder<> ChkRecurIRB(ChkRecurBB->getTerminator());
    Value* LdPrevFunc = ChkRecurIRB.CreateLoad(Ptr8Ty, PrevFuncGV);
    Value* FuncNameForChk = ChkRecurIRB.CreateGlobalStringPtr(s);
    CallInst* StrcmpCall = ChkRecurIRB.CreateCall(StrcmpFunc, {LdPrevFunc, FuncNameForChk});
    Value* TestStrcmp = ChkRecurIRB.CreateICmpEQ(StrcmpCall, ChkRecurIRB.getInt32(0));
    ChkRecurIRB.CreateCondBr(TestStrcmp, RetBB, PrintBB);
    ChkRecurBB->getTerminator()->eraseFromParent();
    
    // PrintBB
    IRBuilder<> PrintIRB(PrintBB->getTerminator());
    Value* Pid = PrintIRB.CreateCall(GetpidFunc, {});
    Value* FuncName = PrintIRB.CreateGlobalStringPtr(s);
    LoadInst* LdFilePtrAgain = PrintIRB.CreateLoad(Ptr8Ty, FilePtrGV);
    PrintIRB.CreateCall(FprintfFunc, {LdFilePtrAgain, FuncName, Pid});
    PrintIRB.CreateStore(FuncName, PrevFuncGV);
    PrintIRB.CreateBr(RetBB);
  }
  return PreservedAnalyses::all();
}

} // namespace llvm
