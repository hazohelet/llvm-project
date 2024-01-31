; RUN: llc -march=cpux -o - %s | FileCheck %s

define float @float_add(float %0, float %1) {
; CHECK-LABEL: float_add:
; CHECK:       fadd.s  fa0, fa0, fa1
  %3 = fadd float %0, %1
  ret float %3
}

define float @float_sub(float %0, float %1) {
; CHECK-LABEL: float_sub:
; CHECK:       fsub.s  fa0, fa0, fa1
  %3 = fsub float %0, %1
  ret float %3
}

define float @float_mul(float %0, float %1) {
; CHECK-LABEL: float_mul:
; CHECK:       fmul.s  fa0, fa0, fa1
  %3 = fmul float %0, %1
  ret float %3
}

define float @float_div(float %0, float %1) {
; CHECK-LABEL: float_div:
; CHECK:       fdiv.s  fa0, fa0, fa1
  %3 = fdiv float %0, %1
  ret float %3
}
