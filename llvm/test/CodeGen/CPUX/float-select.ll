; RUN: llc -march=cpux -o - %s | FileCheck %s

define float @sel(float %0, float %1, float %2, float %3) local_unnamed_addr #0 {
; CHECK-LABEL: sel:
; CHECK:      # %bb.0:
; CHECK-NEXT:	  fle.s a0, fa0, fa1
; CHECK-NEXT:	  bnez	 a0, .BB0_2
; CHECK:      # %bb.1:
; CHECK-NEXT:  	fmv.s	 fa3, fa2
; CHECK-NEXT: .BB0_2:
; CHECK-NEXT:	  fmv.s	 fa0, fa3
; CHECK-NEXT:	  ret
  %5 = fcmp ole float %0, %1
  %. = select i1 %5, float %3, float %2
  ret float %.
}
