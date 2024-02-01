; RUN: llc -march=cpux -o - %s | FileCheck %s

define float @what(float %0, i32 %1, i32 %2, float %3) {
; CHECK-LABEL: what:
; CHECK:       # %bb.0:
; CHECK-NEXT:  mv       a2, a0
; CHECK-NEXT:  fmv.s    ft0, fa0
; CHECK-NEXT:  mv       a0, a1
; CHECK-NEXT:  mv       a1, a2
; CHECK-NEXT:  fmv.s    fa0, fa1
; CHECK-NEXT:  fmv.s    fa1, ft0
; CHECK-NEXT:  tail iamfive
  %5 = tail call float @iamfive(i32 %2, i32 %1, float %3, float %0) #2
  ret float %5
}

declare float @iamfive(i32, i32, float, float)
