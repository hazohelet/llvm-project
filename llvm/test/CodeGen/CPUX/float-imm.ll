; RUN: llc -march=cpux -o - %s | FileCheck %s

define float @iampi(i32 %0) {
; CHECK-LABEL: iampi:
; CHECK:       # %bb.0:
; CHECK-NEXT:  lui  a0, %hi
; CHECK-NEXT:  addi  a0, a0, %lo
; CHECK-NEXT:  flw  fa0, 0(a0)
; CHECK-NEXT:  ret
  ret float 0x40091EB860000000
}

define float @radian_to_degree(float %0) {
; CHECK-LABEL: radian_to_degree:
; CHECK:       # %bb.0:
; CHECK-NEXT:  lui  a0, %hi
; CHECK-NEXT:  addi  a0, a0, %lo
; CHECK-NEXT:  flw  ft0, 0(a0)
; CHECK-NEXT:  fmul.s  ft0, fa0, ft0
; CHECK-NEXT:  lui  a0, %hi
; CHECK-NEXT:  addi  a0, a0, %lo
; CHECK-NEXT:  flw  ft1, 0(a0)
; CHECK-NEXT:  fdiv.s  fa0, ft0, ft1
; CHECK-NEXT:  ret
  %2 = fmul float %0, 1.800000e+02
  %3 = fdiv float %2, 0x40091EB860000000
  ret float %3
}
