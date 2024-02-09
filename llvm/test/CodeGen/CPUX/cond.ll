; RUN: llc -march=cpux -o - %s | FileCheck %s

define i32 @arr_sum(i32 %0, ptr %1) {
; CHECK-LABEL: arr_sum:
; CHECK:       # %bb.0:
; CHECK-NEXT: 	li	 a3, 1
; CHECK-NEXT: 	li	 a2, 0
; CHECK-NEXT: 	blt  a0, a3, .BB0_2
; CHECK-NEXT: 	j	.BB0_1
; CHECK-NEXT: .BB0_1:
; CHECK-NEXT: 	li	 a2, 0
; CHECK-NEXT: 	j	.BB0_3
; CHECK-NEXT: .BB0_3:
; CHECK-NEXT: 	lw  a3, 0(a1)
; CHECK-NEXT: 	add  a2, a3, a2
; CHECK-NEXT: 	addi  a1, a1, 4
; CHECK-NEXT: 	addi  a0, a0, -1
; CHECK-NEXT: 	beqz	 a0, .BB0_2
; CHECK-NEXT: 	j	.BB0_3
; CHECK-NEXT: .BB0_2:
; CHECK-NEXT: 	mv	 a0, a2
; CHECK-NEXT: 	ret
  %3 = icmp sgt i32 %0, 0
  br i1 %3, label %6, label %4

4:
  %5 = phi i32 [ 0, %2 ], [ %11, %6 ]
  ret i32 %5

6:
  %7 = phi i32 [ %12, %6 ], [ 0, %2 ]
  %8 = phi i32 [ %11, %6 ], [ 0, %2 ]
  %9 = getelementptr inbounds i32, ptr %1, i32 %7
  %10 = load i32, ptr %9, align 4
  %11 = add nsw i32 %10, %8
  %12 = add nuw nsw i32 %7, 1
  %13 = icmp eq i32 %12, %0
  br i1 %13, label %4, label %6
}

define i32 @is_even(i32 %0) {
; CHECK-LABEL: is_even:
; CHECK:       # %bb.0:
; CHECK-NEXT:   xori  a0, a0, -1
; CHECK-NEXT:   ret
  %2 = and i32 %0, 1
  %3 = xor i32 %2, 1
  ret i32 %3
}

define i32 @is_odd(i32 %0) {
; CHECK-LABEL: is_odd:
; CHECK:       # %bb.0:
; CHECK-NEXT:  	lui  a1, 524288
; CHECK-NEXT:  	addi  a1, a1, 1
; CHECK-NEXT:  	and  a0, a0, a1
; CHECK-NEXT:  	addi  a0, a0, -1
; CHECK-NEXT:  	seqz	 a0, a0
; CHECK-NEXT:  	ret
  %2 = and i32 %0, -2147483647
  %3 = icmp eq i32 %2, 1
  %4 = zext i1 %3 to i32
  ret i32 %4
}

