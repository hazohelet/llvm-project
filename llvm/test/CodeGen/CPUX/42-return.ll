; RUN: llc -march=cpux -o - %s | FileCheck %s

define i32 @return_42() {
; CHECK-LABEL: return_42:
; CHECK:       # %bb.0:
; CHECK-NEXT:  li     a0, 42
; CHECK-NEXT:  ret
entry:
  ret i32 42
}

