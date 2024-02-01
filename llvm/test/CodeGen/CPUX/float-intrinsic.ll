; RUN: llc -march=cpux -o - %s | FileCheck %s

define float @square_root(float %0) {
; CHECK-LABEL: square_root:
; CHECK:       # %bb.0:
; CHECK-NEXT:  fsqrt.s fa0, fa0
; CHECK-NEXT:  ret
  %2 = tail call float @llvm.sqrt.f32(float %0)
  ret float %2
}

define float @itof(i32 %0) {
; CHECK-LABEL: itof:
; CHECK:       # %bb.0:
; CHECK-NEXT:  fcvt.s.w fa0, a0
; CHECK-NEXT:  ret
  %2 = sitofp i32 %0 to float
  ret float %2
}

define i32 @ftoi(float %0) {
; CHECK-LABEL: ftoi:
; CHECK:       # %bb.0:
; CHECK-NEXT:  fcvt.w.s a0, fa0
; CHECK-NEXT:  ret
  %2 = fptosi float %0 to i32
  ret i32 %2
}

declare float @llvm.sqrt.f32(float)
