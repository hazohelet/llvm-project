; RUN: llc -march=cpux -o - %s | FileCheck %s

%struct.anon = type { i32, i32 }

@glob_int = external local_unnamed_addr global i32, align 4
@glob_arr = external local_unnamed_addr global [3 x i32], align 4
@glob_struct = external local_unnamed_addr global %struct.anon, align 4

define void @update_glob_int() {
; CHECK-LABEL: update_glob_int:
; CHECK:       # %bb.0:
; CHECK-NEXT:  lui  a0, %hi(glob_int)
; CHECK-NEXT:  lw  a1, %lo(glob_int)(a0)
; CHECK-NEXT:  addi  a1, a1, 42
; CHECK-NEXT:  sw  a1, %lo(glob_int)(a0)
; CHECK-NEXT:  ret
  %1 = load i32, ptr @glob_int, align 4
  %2 = add i32 %1, 42
  store i32 %2, ptr @glob_int, align 4
  ret void
}

define void @update_glob_arr() {
; CHECK-LABEL: update_glob_arr:
; CHECK:       # %bb.0:
; CHECK-NEXT:  lui  a0, %hi(glob_arr+8)
; CHECK-NEXT:  lw  a1, %lo(glob_arr+8)(a0)
; CHECK-NEXT:  addi  a1, a1, 52
; CHECK-NEXT:  sw  a1, %lo(glob_arr+8)(a0)
; CHECK-NEXT:  ret
  %1 = load i32, ptr getelementptr inbounds ([3 x i32], ptr @glob_arr, i32 0, i32 2), align 4
  %2 = add i32 %1, 52
  store i32 %2, ptr getelementptr inbounds ([3 x i32], ptr @glob_arr, i32 0, i32 2), align 4
  ret void
}

define void @update_glob_struct() {
; CHECK-LABEL: update_glob_struct:
; CHECK:       # %bb.0:
; CHECK-NEXT:  lui  a0, %hi(glob_struct)
; CHECK-NEXT:  addi  a0, a0, %lo(glob_struct)
; CHECK-NEXT:  lw  a1, 0(a0)
; CHECK-NEXT:  lw  a2, 4(a0)
; CHECK-NEXT:  add  a1, a2, a1
; CHECK-NEXT:  sw  a1, 4(a0)
; CHECK-NEXT:  ret
  %1 = load i32, ptr @glob_struct, align 4
  %2 = load i32, ptr getelementptr inbounds (%struct.anon, ptr @glob_struct, i32 0, i32 1), align 4
  %3 = add i32 %2, %1
  store i32 %3, ptr getelementptr inbounds (%struct.anon, ptr @glob_struct, i32 0, i32 1), align 4
  ret void
}
