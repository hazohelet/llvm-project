; RUN: llc -march=cpux -o - %s | FileCheck %s

@what = external global [100 x float], align 4

define float @get_idx(i32 %0) {
; CHECK-LABEL: get_idx:
; CHECK:       # %bb.0:
; CHECK-NEXT:  slli a0, a0, 2
; CHECK-NEXT:  lui  a1, %hi(what)
; CHECK-NEXT:  addi  a1, a1, %lo(what)
; CHECK-NEXT:  add  a0, a1, a0
; CHECK-NEXT:  flw  fa0, 0(a0)
; CHECK-NEXT:  fsw  fa0, 32(a0)
; CHECK-NEXT:  ret
  %2 = getelementptr inbounds [100 x float], ptr @what, i32 0, i32 %0
  %3 = load float, ptr %2, align 4
  %4 = add nsw i32 %0, 8
  %5 = getelementptr inbounds [100 x float], ptr @what, i32 0, i32 %4
  store float %3, ptr %5, align 4
  ret float %3
}
