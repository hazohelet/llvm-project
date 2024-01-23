; RUN: llc -march=cpux -o - %s | FileCheck %s

define i32 @sum_tail(i32 %0, i32 %1) {
; CHECK-LABEL: sum_tail:
; CHECK:       # %bb.0:
; CHECK-NEXT:  	addi  sp, sp, -16
; CHECK-NEXT:  	sw  ra, 12(sp)
; CHECK-NEXT:  	sw  sp, 8(sp)
; CHECK-NEXT:  	beqz	 a0, .BB0_2
; CHECK-NEXT:  	j	.BB0_1
; CHECK-NEXT:  .BB0_1:
; CHECK-NEXT:  	add  a1, a1, a0
; CHECK-NEXT:  	addi  a0, a0, -1
; CHECK-NEXT:  	call sum_tail
; CHECK-NEXT:  	mv	 a1, a0
; CHECK-NEXT:  .BB0_2:
; CHECK-NEXT:  	mv	 a0, a1
; CHECK-NEXT:  	lw  sp, 8(sp)
; CHECK-NEXT:  	lw  ra, 12(sp)
; CHECK-NEXT:  	addi  sp, sp, 16
; CHECK-NEXT:  	ret
  %3 = icmp eq i32 %0, 0
  br i1 %3, label %4, label %5

4:                                                ; preds = %2
  br label %9

5:                                                ; preds = %2
  %6 = sub i32 %0, 1
  %7 = add i32 %1, %0
  %8 = call i32 @sum_tail(i32 %6, i32 %7)
  br label %9

9:                                                ; preds = %4, %5
  %10 = phi i32 [ %8, %5 ], [ %1, %4 ]
  br label %11

11:                                               ; preds = %9
  ret i32 %10
}

define i32 @sum(i32 %0) {
; CHECK-LABEL: sum:
; CHECK:       # %bb.0:
; CHECK-NEXT:  	addi  sp, sp, -16
; CHECK-NEXT:  	sw  ra, 12(sp)
; CHECK-NEXT:  	sw  sp, 8(sp)
; CHECK-NEXT:  	li	 a1, 0
; CHECK-NEXT:  	call sum_tail
; CHECK-NEXT:  	lw  sp, 8(sp)
; CHECK-NEXT:  	lw  ra, 12(sp)
; CHECK-NEXT:  	addi  sp, sp, 16
; CHECK-NEXT:  	ret
  %2 = call i32 @sum_tail(i32 %0, i32 0)
  ret i32 %2
}

define i32 @main() {
; CHECK-LABEL: main:
; CHECK:       # %bb.0:
; CHECK-NEXT:	  addi  sp, sp, -16
; CHECK-NEXT:	  sw  ra, 12(sp)
; CHECK-NEXT:	  sw  sp, 8(sp)
; CHECK-NEXT:	  li	 a0, 20
; CHECK-NEXT:	  call sum
; CHECK-NEXT:	  lw  sp, 8(sp)
; CHECK-NEXT:	  lw  ra, 12(sp)
; CHECK-NEXT:	  addi  sp, sp, 16
; CHECK-NEXT:	  ret
  %1 = call i32 @sum(i32 20)
  ret i32 %1
}
