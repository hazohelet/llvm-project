; RUN: llc -march=cpux -o - %s | FileCheck %s

define void @void_return() {
; CHECK-LABEL: void_return:
; CHECK:       # %bb.0:
; CHECK-NEXT:  ret
entry:
  ret void
}

