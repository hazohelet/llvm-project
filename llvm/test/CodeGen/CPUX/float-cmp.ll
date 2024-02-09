; RUN: llc -march=cpux -o - %s | FileCheck %s

define i32 @gt(float %0, float %1) {
; CHECK-LABEL: gt:
; CHECK:       # %bb.0:
; CHECK-NEXT:  fle.s a0, fa1, fa0
; CHECK-NEXT:  ret
  %3 = fcmp ogt float %0, %1
  %4 = zext i1 %3 to i32
  ret i32 %4
}

define i32 @ge(float %0, float %1) {
; CHECK-LABEL: ge:
; CHECK:       # %bb.0:
; CHECK-NEXT:  flt.s a0, fa1, fa0
; CHECK-NEXT:  ret
  %3 = fcmp oge float %0, %1
  %4 = zext i1 %3 to i32
  ret i32 %4
}

define i32 @lt(float %0, float %1) {
; CHECK-LABEL: lt:
; CHECK:       # %bb.0:
; CHECK-NEXT:  flt.s a0, fa0, fa1
; CHECK-NEXT:  ret
  %3 = fcmp olt float %0, %1
  %4 = zext i1 %3 to i32
  ret i32 %4
}

define i32 @le(float %0, float %1) {
; CHECK-LABEL: le:
; CHECK:       # %bb.0:
; CHECK-NEXT:  fle.s a0, fa0, fa1
; CHECK-NEXT:  ret
  %3 = fcmp ole float %0, %1
  %4 = zext i1 %3 to i32
  ret i32 %4
}

define i32 @eq(float %0, float %1) {
; CHECK-LABEL: eq:
; CHECK:       # %bb.0:
; CHECK-NEXT:  feq.s a0, fa0, fa1
; CHECK-NEXT:  ret
  %3 = fcmp oeq float %0, %1
  %4 = zext i1 %3 to i32
  ret i32 %4
}

define i32 @neq(float %0, float %1) {
; CHECK-LABEL: neq:
; CHECK:       # %bb.0:
; CHECK-NEXT:  feq.s a0, fa0, fa1
; CHECK-NEXT:  xori  a0, a0, 1
; CHECK-NEXT:  ret
  %3 = fcmp une float %0, %1
  %4 = zext i1 %3 to i32
  ret i32 %4
}
