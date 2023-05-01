; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -indvars -S < %s | FileCheck %s

; Check the case where one exit has a pointer EC, and the other doesn't.
; Note that this test case is really really fragile.  Removing any
; instruction in the below causes the result to differ.  Note that the lack
; of a data layout (with pointer size info) is critical to getting a pointer
; EC returned by SCEV.

@global = external global [0 x i8], align 1

define void @foo() {
; CHECK-LABEL: @foo(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    br label [[BB3:%.*]]
; CHECK:       bb3:
; CHECK-NEXT:    [[TMP6:%.*]] = load i8, i8* getelementptr inbounds ([0 x i8], [0 x i8]* @global, i64 0, i64 1), align 1
; CHECK-NEXT:    br i1 false, label [[BB7:%.*]], label [[BB11:%.*]]
; CHECK:       bb7:
; CHECK-NEXT:    [[TMP8:%.*]] = zext i8 [[TMP6]] to i64
; CHECK-NEXT:    br i1 true, label [[BB11]], label [[BB3]]
; CHECK:       bb11:
; CHECK-NEXT:    ret void
;
bb:
  br label %bb3

bb3:                                              ; preds = %bb7, %bb2
  %tmp = phi i8* [ %tmp4, %bb7 ], [ getelementptr inbounds ([0 x i8], [0 x i8]* @global, i64 0, i64 2), %bb ]
  %tmp4 = getelementptr inbounds i8, i8* %tmp, i64 -1
  %tmp6 = load i8, i8* %tmp4, align 1
  %tmp5 = icmp ugt i8* %tmp4, getelementptr inbounds ([0 x i8], [0 x i8]* @global, i64 0, i64 500)
  br i1 %tmp5, label %bb7, label %bb11

bb7:                                              ; preds = %bb3
  %tmp8 = zext i8 %tmp6 to i64
  %tmp10 = icmp eq i16 0, 0
  br i1 %tmp10, label %bb11, label %bb3

bb11:                                             ; preds = %bb7, %bb3
  ret void
}