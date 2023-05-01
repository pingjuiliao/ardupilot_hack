; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s --check-prefix=DEFAULTCPU
; RUN: llc < %s -mcpu=x86-64 -mtriple=x86_64-unknown-unknown | FileCheck %s --check-prefix=X64CPU

define void @merge_8_float_zero_stores(ptr %ptr) {
; DEFAULTCPU-LABEL: merge_8_float_zero_stores:
; DEFAULTCPU:       # %bb.0:
; DEFAULTCPU-NEXT:    movq $0, (%rdi)
; DEFAULTCPU-NEXT:    movq $0, 8(%rdi)
; DEFAULTCPU-NEXT:    movq $0, 16(%rdi)
; DEFAULTCPU-NEXT:    movq $0, 24(%rdi)
; DEFAULTCPU-NEXT:    retq
;
; X64CPU-LABEL: merge_8_float_zero_stores:
; X64CPU:       # %bb.0:
; X64CPU-NEXT:    xorps %xmm0, %xmm0
; X64CPU-NEXT:    movups %xmm0, (%rdi)
; X64CPU-NEXT:    movups %xmm0, 16(%rdi)
; X64CPU-NEXT:    retq
  %idx1 = getelementptr float, ptr %ptr, i64 1
  %idx2 = getelementptr float, ptr %ptr, i64 2
  %idx3 = getelementptr float, ptr %ptr, i64 3
  %idx4 = getelementptr float, ptr %ptr, i64 4
  %idx5 = getelementptr float, ptr %ptr, i64 5
  %idx6 = getelementptr float, ptr %ptr, i64 6
  %idx7 = getelementptr float, ptr %ptr, i64 7
  store float 0.0, ptr %ptr, align 4
  store float 0.0, ptr %idx1, align 4
  store float 0.0, ptr %idx2, align 4
  store float 0.0, ptr %idx3, align 4
  store float 0.0, ptr %idx4, align 4
  store float 0.0, ptr %idx5, align 4
  store float 0.0, ptr %idx6, align 4
  store float 0.0, ptr %idx7, align 4
  ret void
}