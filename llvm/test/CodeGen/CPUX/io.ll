; RUN: llc -march=cpux -o - %s | FileCheck %s

define i32 @read_int() {
; CHECK-LABEL: read_int:
; CHECK:       # %bb.0:
; CHECK-NEXT:  lw  a0, 12(zero)
; CHECK-NEXT:  ret
  %1 = load volatile i32, ptr inttoptr (i32 12 to ptr), align 4
  ret i32 %1
}

define void @print_newline() {
; CHECK-LABEL: print_newline:
; CHECK:       # %bb.0:
; CHECK-NEXT:  li       a0, 10
; CHECK-NEXT:  sw  a0, 12(zero)
; CHECK-NEXT:  ret
  store volatile i32 10, ptr inttoptr (i32 12 to ptr), align 4
  ret void
}
