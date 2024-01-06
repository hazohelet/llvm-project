; RUN: llc -march=cpux -o - %s | FileCheck %s

define i32 @adder(i32 %0, i32 %1) {
; CHECK-LABEL: adder:
; CHECK:       # %bb.0:
; CHECK-NEXT:  addi  sp, sp, -8
; CHECK-NEXT:  sw  a1, 0(sp)
; CHECK-NEXT:  sw  a0, 4(sp)
; CHECK-NEXT:  add  a0, a0, a1
; CHECK-NEXT:  addi  sp, sp, 8
; CHECK-NEXT:  ret
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  store i32 %0, ptr %3, align 4
  store i32 %1, ptr %4, align 4
  %5 = load i32, ptr %3, align 4
  %6 = load i32, ptr %4, align 4
  %7 = add i32 %5, %6
  ret i32 %7
}
