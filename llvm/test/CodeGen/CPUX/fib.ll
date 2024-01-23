; RUN: llc -march=cpux -o - %s | FileCheck %s

define i32 @fib(i32 %0) {
; CHECK-LABEL: fib:
; CHECK:       # %bb.0:
; CHECK-NEXT:  	addi  sp, sp, -16
; CHECK-NEXT:  	sw  ra, 12(sp)
; CHECK-NEXT:  	sw  sp, 8(sp)
; CHECK-NEXT:  	sw  s1, 4(sp)
; CHECK-NEXT:  	sw  s2, 0(sp)
; CHECK-NEXT:  	mv	 s1, a0
; CHECK-NEXT:  	li	 a0, 2
; CHECK-NEXT:  	blt  s1, a0, .BB0_2
; CHECK-NEXT:  	j	.BB0_1
; CHECK-NEXT:   .BB0_1:
; CHECK-NEXT:   	addi  a0, s1, -1
; CHECK-NEXT:   	call fib
; CHECK-NEXT:   	mv	 s2, a0
; CHECK-NEXT:   	addi  a0, s1, -2
; CHECK-NEXT:   	call fib
; CHECK-NEXT:   	add  s1, s2, a0
; CHECK-NEXT:   .BB0_2:
; CHECK-NEXT:   	mv	 a0, s1
; CHECK-NEXT:   	lw  s2, 0(sp)
; CHECK-NEXT:   	lw  s1, 4(sp)
; CHECK-NEXT:   	lw  sp, 8(sp)
; CHECK-NEXT:   	lw  ra, 12(sp)
; CHECK-NEXT:   	addi  sp, sp, 16
; CHECK-NEXT:   	ret
  %2 = icmp sge i32 %0, 2
  br i1 %2, label %3, label %9

3:                                                ; preds = %1
  %4 = sub i32 %0, 1
  %5 = call i32 @fib(i32 %4)
  %6 = sub i32 %0, 2
  %7 = call i32 @fib(i32 %6)
  %8 = add i32 %5, %7
  br label %10

9:                                                ; preds = %1
  br label %10

10:                                               ; preds = %3, %9
  %11 = phi i32 [ %0, %9 ], [ %8, %3 ]
  br label %12

12:                                               ; preds = %10
  ret i32 %11
}

define i32 @main() {
; CHECK-LABEL: main:
; CHECK:       # %bb.0:
; CHECK-NEXT:   addi  sp, sp, -16
; CHECK-NEXT:   sw  ra, 12(sp)
; CHECK-NEXT:   sw  sp, 8(sp)
; CHECK-NEXT:   li	 a0, 10
; CHECK-NEXT:   call fib
; CHECK-NEXT:   lw  sp, 8(sp)
; CHECK-NEXT:   lw  ra, 12(sp)
; CHECK-NEXT:   addi  sp, sp, 16
; CHECK-NEXT:   ret
  %1 = call i32 @fib(i32 10)
  ret i32 %1
}
