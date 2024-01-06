; RUN: llc -march=cpux -o - %s | FileCheck %s

define i32 @many_args(i32 %0, i32 %1, i32 %2, i32 %3, i32 %4, i32 %5, i32 %6, i32 %7, i32 %8, i32 %9) {

; CHECK-LABEL: many_args:
; CHECK:       # %bb.0:
; CHECK-NEXT:  add  a0, a1, a0
; CHECK-NEXT:  add  a0, a0, a2
; CHECK-NEXT:  add  a0, a0, a3
; CHECK-NEXT:  add  a0, a0, a4
; CHECK-NEXT:  add  a0, a0, a5
; CHECK-NEXT:  add  a0, a0, a6
; CHECK-NEXT:  add  a0, a0, a7
; CHECK-NEXT:  lw  a1, 0(sp)
; CHECK-NEXT:  add  a0, a0, a1
; CHECK-NEXT:  lw  a1, 4(sp)
; CHECK-NEXT:  add  a0, a0, a1
; CHECK-NEXT:  ret
  %11 = add i32 %1, %0
  %12 = add i32 %11, %2
  %13 = add i32 %12, %3
  %14 = add i32 %13, %4
  %15 = add i32 %14, %5
  %16 = add i32 %15, %6
  %17 = add i32 %16, %7
  %18 = add i32 %17, %8
  %19 = add i32 %18, %9
  ret i32 %19
}
