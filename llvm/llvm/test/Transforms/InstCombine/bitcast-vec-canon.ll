; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=instcombine -S | FileCheck %s

define double @a(<1 x i64> %y) {
; CHECK-LABEL: @a(
; CHECK-NEXT:    [[BC:%.*]] = bitcast <1 x i64> [[Y:%.*]] to <1 x double>
; CHECK-NEXT:    [[C:%.*]] = extractelement <1 x double> [[BC]], i64 0
; CHECK-NEXT:    ret double [[C]]
;
  %c = bitcast <1 x i64> %y to double
  ret double %c
}

define i64 @b(<1 x i64> %y) {
; CHECK-LABEL: @b(
; CHECK-NEXT:    [[TMP1:%.*]] = extractelement <1 x i64> [[Y:%.*]], i64 0
; CHECK-NEXT:    ret i64 [[TMP1]]
;
  %c = bitcast <1 x i64> %y to i64
  ret i64 %c
}

define <1 x i64> @c(double %y) {
; CHECK-LABEL: @c(
; CHECK-NEXT:    [[C:%.*]] = bitcast double [[Y:%.*]] to <1 x i64>
; CHECK-NEXT:    ret <1 x i64> [[C]]
;
  %c = bitcast double %y to <1 x i64>
  ret <1 x i64> %c
}

define <1 x i64> @d(i64 %y) {
; CHECK-LABEL: @d(
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <1 x i64> poison, i64 [[Y:%.*]], i64 0
; CHECK-NEXT:    ret <1 x i64> [[TMP1]]
;
  %c = bitcast i64 %y to <1 x i64>
  ret <1 x i64> %c
}

define x86_mmx @e(<1 x i64> %y) {
; CHECK-LABEL: @e(
; CHECK-NEXT:    [[TMP1:%.*]] = extractelement <1 x i64> [[Y:%.*]], i64 0
; CHECK-NEXT:    [[C:%.*]] = bitcast i64 [[TMP1]] to x86_mmx
; CHECK-NEXT:    ret x86_mmx [[C]]
;
  %c = bitcast <1 x i64> %y to x86_mmx
  ret x86_mmx %c
}

define <1 x i64> @f(x86_mmx %y) {
; CHECK-LABEL: @f(
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast x86_mmx [[Y:%.*]] to i64
; CHECK-NEXT:    [[C:%.*]] = insertelement <1 x i64> poison, i64 [[TMP1]], i64 0
; CHECK-NEXT:    ret <1 x i64> [[C]]
;
  %c = bitcast x86_mmx %y to <1 x i64>
  ret <1 x i64> %c
}

define double @g(x86_mmx %x) {
; CHECK-LABEL: @g(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = bitcast x86_mmx [[X:%.*]] to double
; CHECK-NEXT:    ret double [[TMP0]]
;
entry:
  %0 = bitcast x86_mmx %x to <1 x i64>
  %1 = bitcast <1 x i64> %0 to double
  ret double %1
}

; FP source is ok.

define <3 x i64> @bitcast_inselt_undef(double %x, i32 %idx) {
; CHECK-LABEL: @bitcast_inselt_undef(
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <3 x double> undef, double [[X:%.*]], i32 [[IDX:%.*]]
; CHECK-NEXT:    [[I:%.*]] = bitcast <3 x double> [[TMP1]] to <3 x i64>
; CHECK-NEXT:    ret <3 x i64> [[I]]
;
  %xb = bitcast double %x to i64
  %i = insertelement <3 x i64> undef, i64 %xb, i32 %idx
  ret <3 x i64> %i
}

; Integer source is ok; index is anything.

define <3 x float> @bitcast_inselt_undef_fp(i32 %x, i567 %idx) {
; CHECK-LABEL: @bitcast_inselt_undef_fp(
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <3 x i32> undef, i32 [[X:%.*]], i567 [[IDX:%.*]]
; CHECK-NEXT:    [[I:%.*]] = bitcast <3 x i32> [[TMP1]] to <3 x float>
; CHECK-NEXT:    ret <3 x float> [[I]]
;
  %xb = bitcast i32 %x to float
  %i = insertelement <3 x float> undef, float %xb, i567 %idx
  ret <3 x float> %i
}

define <vscale x 3 x float> @bitcast_inselt_undef_vscale(i32 %x, i567 %idx) {
; CHECK-LABEL: @bitcast_inselt_undef_vscale(
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <vscale x 3 x i32> undef, i32 [[X:%.*]], i567 [[IDX:%.*]]
; CHECK-NEXT:    [[I:%.*]] = bitcast <vscale x 3 x i32> [[TMP1]] to <vscale x 3 x float>
; CHECK-NEXT:    ret <vscale x 3 x float> [[I]]
;
  %xb = bitcast i32 %x to float
  %i = insertelement <vscale x 3 x float> undef, float %xb, i567 %idx
  ret <vscale x 3 x float> %i
}

declare void @use(i64)

; Negative test - extra use prevents canonicalization

define <3 x i64> @bitcast_inselt_undef_extra_use(double %x, i32 %idx) {
; CHECK-LABEL: @bitcast_inselt_undef_extra_use(
; CHECK-NEXT:    [[XB:%.*]] = bitcast double [[X:%.*]] to i64
; CHECK-NEXT:    call void @use(i64 [[XB]])
; CHECK-NEXT:    [[I:%.*]] = insertelement <3 x i64> undef, i64 [[XB]], i32 [[IDX:%.*]]
; CHECK-NEXT:    ret <3 x i64> [[I]]
;
  %xb = bitcast double %x to i64
  call void @use(i64 %xb)
  %i = insertelement <3 x i64> undef, i64 %xb, i32 %idx
  ret <3 x i64> %i
}

; Negative test - source type must be scalar

define <3 x i64> @bitcast_inselt_undef_vec_src(<2 x i32> %x, i32 %idx) {
; CHECK-LABEL: @bitcast_inselt_undef_vec_src(
; CHECK-NEXT:    [[XB:%.*]] = bitcast <2 x i32> [[X:%.*]] to i64
; CHECK-NEXT:    [[I:%.*]] = insertelement <3 x i64> undef, i64 [[XB]], i32 [[IDX:%.*]]
; CHECK-NEXT:    ret <3 x i64> [[I]]
;
  %xb = bitcast <2 x i32> %x to i64
  %i = insertelement <3 x i64> undef, i64 %xb, i32 %idx
  ret <3 x i64> %i
}

; Negative test - source type must be scalar

define <3 x i64> @bitcast_inselt_undef_from_mmx(x86_mmx %x, i32 %idx) {
; CHECK-LABEL: @bitcast_inselt_undef_from_mmx(
; CHECK-NEXT:    [[XB:%.*]] = bitcast x86_mmx [[X:%.*]] to i64
; CHECK-NEXT:    [[I:%.*]] = insertelement <3 x i64> undef, i64 [[XB]], i32 [[IDX:%.*]]
; CHECK-NEXT:    ret <3 x i64> [[I]]
;
  %xb = bitcast x86_mmx %x to i64
  %i = insertelement <3 x i64> undef, i64 %xb, i32 %idx
  ret <3 x i64> %i
}

; Reduce number of casts

define <2 x i64> @PR45748(double %x, double %y) {
; CHECK-LABEL: @PR45748(
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <2 x double> undef, double [[X:%.*]], i64 0
; CHECK-NEXT:    [[TMP2:%.*]] = insertelement <2 x double> [[TMP1]], double [[Y:%.*]], i64 1
; CHECK-NEXT:    [[I1:%.*]] = bitcast <2 x double> [[TMP2]] to <2 x i64>
; CHECK-NEXT:    ret <2 x i64> [[I1]]
;
  %xb = bitcast double %x to i64
  %i0 = insertelement <2 x i64> undef, i64 %xb, i32 0
  %yb = bitcast double %y to i64
  %i1 = insertelement <2 x i64> %i0, i64 %yb, i32 1
  ret <2 x i64> %i1
}