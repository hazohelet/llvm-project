; RUN: llc -march=cpux -o - %s | FileCheck %s

define i32 @add(i32 %0, i32 %1) {
; CHECK-LABEL: add:
; CHECK:       # %bb.0:
; CHECK-NEXT:  add  a0, a1, a0
; CHECK-NEXT:  ret
  %3 = add i32 %1, %0
  ret i32 %3
}


define i32 @sub(i32 %0, i32 %1) {
; CHECK-LABEL: sub:
; CHECK:       # %bb.0:
; CHECK-NEXT:  sub a0, a0, a1
; CHECK-NEXT:  ret
  %3 = sub i32 %0, %1
  ret i32 %3
}


define i32 @shift_left(i32 %0, i32 %1) {
; CHECK-LABEL: shift_left:
; CHECK:       # %bb.0:
; CHECK-NEXT:  sll a0, a0, a1
; CHECK-NEXT:  ret
  %3 = shl i32 %0, %1
  ret i32 %3
}


define i32 @shift_left_unsigned(i32 %0, i32 %1) {
; CHECK-LABEL: shift_left_unsigned:
; CHECK:       # %bb.0:
; CHECK-NEXT:  sll a0, a0, a1
; CHECK-NEXT:  ret
  %3 = shl i32 %0, %1
  ret i32 %3
}


define i32 @shift_right(i32 %0, i32 %1) {
; CHECK-LABEL: shift_right:
; CHECK:       # %bb.0:
; CHECK-NEXT:  sra a0, a0, a1
; CHECK-NEXT:  ret
  %3 = ashr i32 %0, %1
  ret i32 %3
}


define i32 @shift_right_unsigned(i32 %0, i32 %1) {
; CHECK-LABEL: shift_right_unsigned:
; CHECK:       # %bb.0:
; CHECK-NEXT:  srl a0, a0, a1
; CHECK-NEXT:  ret
  %3 = lshr i32 %0, %1
  ret i32 %3
}


define i32 @_and(i32 %0, i32 %1) {
; CHECK-LABEL: _and:
; CHECK:       # %bb.0:
; CHECK-NEXT:  and  a0, a1, a0
; CHECK-NEXT:  ret
  %3 = and i32 %1, %0
  ret i32 %3
}


define i32 @_or(i32 %0, i32 %1) {
; CHECK-LABEL: _or:
; CHECK:       # %bb.0:
; CHECK-NEXT:  or  a0, a1, a0
; CHECK-NEXT:  ret
  %3 = or i32 %1, %0
  ret i32 %3
}


define i32 @_xor(i32 %0, i32 %1) {
; CHECK-LABEL: _xor:
; CHECK:       # %bb.0:
; CHECK-NEXT:  xor  a0, a1, a0
; CHECK-NEXT:  ret
  %3 = xor i32 %1, %0
  ret i32 %3
}


define i32 @equal(i32 %0, i32 %1) {
; CHECK-LABEL: equal:
; CHECK:       # %bb.0:
; CHECK-NEXT:  xor  a0, a0, a1
; CHECK-NEXT:  seqz  a0, a0
; CHECK-NEXT:  ret
  %3 = icmp eq i32 %0, %1
  %4 = zext i1 %3 to i32
  ret i32 %4
}


define i32 @not_equal(i32 %0, i32 %1) {
; CHECK-LABEL: not_equal:
; CHECK:       # %bb.0:
; CHECK-NEXT:  xor  a0, a0, a1
; CHECK-NEXT:  snez  a0, a0
; CHECK-NEXT:  ret
  %3 = icmp ne i32 %0, %1
  %4 = zext i1 %3 to i32
  ret i32 %4
}


define i32 @less(i32 %0, i32 %1) {
; CHECK-LABEL: less:
; CHECK:       # %bb.0:
; CHECK-NEXT:  slt  a0, a0, a1
; CHECK-NEXT:  ret
  %3 = icmp slt i32 %0, %1
  %4 = zext i1 %3 to i32
  ret i32 %4
}


define i32 @greater(i32 %0, i32 %1) {
; CHECK-LABEL: greater:
; CHECK:       # %bb.0:
; CHECK-NEXT:  slt  a0, a1, a0
; CHECK-NEXT:  ret
  %3 = icmp sgt i32 %0, %1
  %4 = zext i1 %3 to i32
  ret i32 %4
}


define i32 @less_equal(i32 %0, i32 %1) {
; CHECK-LABEL: less_equal:
; CHECK:       # %bb.0:
; CHECK-NEXT:  slt  a0, a1, a0
; CHECK-NEXT:  xori  a0, a0, 1
; CHECK-NEXT:  ret
  %3 = icmp sle i32 %0, %1
  %4 = zext i1 %3 to i32
  ret i32 %4
}


define i32 @greater_equal(i32 %0, i32 %1) {
; CHECK-LABEL: greater_equal:
; CHECK:       # %bb.0:
; CHECK-NEXT:  slt  a0, a0, a1
; CHECK-NEXT:  xori  a0, a0, 1
  %3 = icmp sge i32 %0, %1
  %4 = zext i1 %3 to i32
  ret i32 %4
}


define i32 @rotate_left(i32 %0) {
; CHECK-LABEL: rotate_left:
; CHECK:       # %bb.0:
; CHECK-NEXT:  srli a1, a0, 2
; CHECK-NEXT:  slli a0, a0, 30
; CHECK-NEXT:  or  a0, a0, a1
; CHECK-NEXT:  ret
  %2 = tail call i32 @llvm.fshl.i32(i32 %0, i32 %0, i32 30)
  ret i32 %2
}


declare i32 @llvm.fshl.i32(i32, i32, i32)
