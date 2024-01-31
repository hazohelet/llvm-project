; RUN: llc -march=cpux -o - %s | FileCheck %s

define i32 @what({ i32, i32, i32 } %0) {
  %2 = extractvalue { i32, i32, i32 } %0, 1
  ret i32 %2
}

define i32 @main() {
; CHECK-LABEL: main:
; CHECK:       # %bb.0:
; CHECK-NEXT:   li       a0, 3
; CHECK-NEXT:   li       a1, 4
; CHECK-NEXT:   li       a2, 5
; CHECK-NEXT:   tail what

  %1 = tail call i32 @what({ i32, i32, i32 } { i32 3, i32 4, i32 5 })
  ret i32 %1
}
