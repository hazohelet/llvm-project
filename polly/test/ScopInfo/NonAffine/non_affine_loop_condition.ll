; RUN: opt %loadNPMPolly -polly-allow-nonaffine-branches -polly-allow-nonaffine-loops                                   '-passes=print<polly-detect>,print<polly-function-scops>' -disable-output < %s 2>&1 | FileCheck %s
; RUN: opt %loadNPMPolly -polly-allow-nonaffine-branches -polly-allow-nonaffine-loops -polly-process-unprofitable=false '-passes=print<polly-detect>,print<polly-function-scops>' -disable-output < %s 2>&1 | FileCheck %s --check-prefix=PROFIT
; RUN: opt %loadNPMPolly -polly-allow-nonaffine-branches -polly-allow-nonaffine-loops -polly-detect-reductions=false    '-passes=print<polly-detect>,print<polly-function-scops>' -disable-output < %s 2>&1 | FileCheck %s -check-prefix=NO-REDUCTION
;
;    void f(int *A, int *C) {
;      for (int i = 0; i < 1024; i++) {
;        while (C[i])
;          A[i]++;
;      }
;    }
;
; CHECK:      Function: f
; CHECK-NEXT: Region: %bb1---%bb12
; CHECK-NEXT: Max Loop Depth:  1
; CHECK-NEXT: Invariant Accesses: {
; CHECK-NEXT: }
; CHECK-NEXT: Context:
; CHECK-NEXT: {  :  }
; CHECK-NEXT: Assumed Context:
; CHECK-NEXT: {  :  }
; CHECK-NEXT: Invalid Context:
; CHECK-NEXT: {  : false }
; CHECK:      Arrays {
; CHECK-NEXT:     i32 MemRef_C[*]; // Element size 4
; CHECK-NEXT:     i32 MemRef_A[*]; // Element size 4
; CHECK-NEXT: }
; CHECK-NEXT: Arrays (Bounds as pw_affs) {
; CHECK-NEXT:     i32 MemRef_C[*]; // Element size 4
; CHECK-NEXT:     i32 MemRef_A[*]; // Element size 4
; CHECK-NEXT: }
; CHECK-NEXT: Alias Groups (1):
; CHECK-NEXT:     {{\[\[}} <{ MemRef_C[(0)] }, { MemRef_C[(1024)] }> <{ MemRef_A[(0)] }, { MemRef_A[(1024)] }> {{\]\]}}
; CHECK-NEXT: Statements {
; CHECK-NEXT:     Stmt_bb3__TO__bb10
; CHECK-NEXT:         Domain :=
; CHECK-NEXT:             { Stmt_bb3__TO__bb10[i0] : 0 <= i0 <= 1023 };
; CHECK-NEXT:         Schedule :=
; CHECK-NEXT:             { Stmt_bb3__TO__bb10[i0] -> [i0] };
; CHECK-NEXT:         ReadAccess :=    [Reduction Type: NONE] [Scalar: 0]
; CHECK-NEXT:             { Stmt_bb3__TO__bb10[i0] -> MemRef_C[i0] };
; CHECK-NEXT:         ReadAccess :=    [Reduction Type: +] [Scalar: 0]
; CHECK-NEXT:             { Stmt_bb3__TO__bb10[i0] -> MemRef_A[i0] };
; CHECK-NEXT:         MayWriteAccess :=    [Reduction Type: +] [Scalar: 0]
; CHECK-NEXT:             { Stmt_bb3__TO__bb10[i0] -> MemRef_A[i0] };
; CHECK-NEXT: }

; PROFIT-NOT: Statements

; NO-REDUCTION-NOT: Reduction Type: +

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

define void @f(ptr %A, ptr %C) {
bb:
  br label %bb1

bb1:                                              ; preds = %bb11, %bb
  %indvars.iv = phi i64 [ %indvars.iv.next, %bb11 ], [ 0, %bb ]
  %exitcond = icmp ne i64 %indvars.iv, 1024
  br i1 %exitcond, label %bb2, label %bb12

bb2:                                              ; preds = %bb1
  br label %bb3

bb3:                                              ; preds = %bb6, %bb2
  %tmp = getelementptr inbounds i32, ptr %C, i64 %indvars.iv
  %tmp4 = load i32, ptr %tmp, align 4
  %tmp5 = icmp eq i32 %tmp4, 0
  br i1 %tmp5, label %bb10, label %bb6

bb6:                                              ; preds = %bb3
  %tmp7 = getelementptr inbounds i32, ptr %A, i64 %indvars.iv
  %tmp8 = load i32, ptr %tmp7, align 4
  %tmp9 = add nsw i32 %tmp8, 1
  store i32 %tmp9, ptr %tmp7, align 4
  br label %bb3

bb10:                                             ; preds = %bb3
  br label %bb11

bb11:                                             ; preds = %bb10
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  br label %bb1

bb12:                                             ; preds = %bb1
  ret void
}
