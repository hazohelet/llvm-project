; RUN: llc -march=cpux -o - %s | FileCheck %s

define internal float @mincaml_floor(float %0) {
; CHECK-LABEL: mincaml_floor:
; CHECK:       # %bb.0:
; CHECK-NEXT:  	ffloor.s fa0, fa0
  %2 = call float @llvm.floor.f32(float %0)
  ret float %2
}

define internal float @mincaml_fhalf_fdiv(float %0) {
; CHECK-LABEL: mincaml_fhalf_fdiv:
; CHECK:       # %bb.0:
; CHECK-NEXT:  	fhalf.s fa0, fa0
  %2 = fdiv float %0, 2.000000e+00
  ret float %2
}

define internal float @mincaml_fhalf_fmul(float %0) local_unnamed_addr #0 {
; CHECK-LABEL: mincaml_fhalf_fmul:
; CHECK:       # %bb.0:
; CHECK-NEXT:  	fhalf.s fa0, fa0
  %2 = fmul float %0, 5.000000e-01
  ret float %2
}

declare float @llvm.floor.f32(float) #0

attributes #0 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }

