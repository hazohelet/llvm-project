; RUN: llc -march=cpux -o - %s | FileCheck %s

%struct.S = type { i32, i32 }

define [2 x i32] @return_struct(ptr %0) {
; CHECK-LABEL: return_struct:
; CHECK:       # %bb.0:
; CHECK-NEXT:  li       a1, 124
; CHECK-NEXT:  sw  a1, 4(a0)
; CHECK-NEXT:  li       a1, 99
; CHECK-NEXT:  sw  a1, 0(a0)
; CHECK-NEXT:  li       a0, 1
; CHECK-NEXT:  li       a1, 2
; CHECK-NEXT:  ret
  store i32 99, ptr %0, align 4
  %2 = getelementptr inbounds %struct.S, ptr %0, i32 0, i32 1
  store i32 124, ptr %2, align 4
  ret [2 x i32] [i32 1, i32 2]
}
