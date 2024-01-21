; RUN: llc -march=cpux -o - %s | FileCheck %s

define i32 @get_max(i32 %0, i32 %1) {
; CHECK-LABEL: get_max:
; CHECK:       # %bb.0:
; CHECK-NEXT:   slt a2, a1, a0
; CHECK-NEXT:   bnez     a2, .BB0_2
; CHECK:       # %bb.1:
; CHECK-NEXT:   mv       a0, a1
; CHECK-NEXT:  .BB0_2:
; CHECK-NEXT:   ret
  %3 = tail call i32 @llvm.smax.i32(i32 %0, i32 %1)
  ret i32 %3
}

declare i32 @llvm.smax.i32(i32, i32)
