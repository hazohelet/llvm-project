; RUN: llc -march=cpux -o - %s | FileCheck %s

define i32 @mincaml_read_int() {
; CHECK-LABEL: mincaml_read_int:
; CHECK:       # %bb.0:
; CHECK-NEXT:  lw  a0, 12(zero)
; CHECK-NEXT:  ret
  %1 = load volatile i32, ptr inttoptr (i32 12 to ptr), align 4
  ret i32 %1
}

declare float @mincaml_read_float()

define void @mincaml_print_char(i32 %0) {
; CHECK-LABEL: mincaml_print_char:
; CHECK:       # %bb.0:
; CHECK-NEXT:   sw  a0, 8(zero)
; CHECK-NEXT:   ret
  store volatile i32 %0, ptr inttoptr (i32 8 to ptr), align 4
  ret void
}

define void @print_int(i32 %0) {
; CHECK-LABEL: print_int:
; CHECK:       # %bb.0:
; CHECK-NEXT:  addi  sp, sp, -16
; CHECK-NEXT:  sw  ra, 12(sp)
; CHECK-NEXT:  sw  sp, 8(sp)
; CHECK-NEXT:  sw  s1, 4(sp)
; CHECK-NEXT:  mv   s1, a0
; CHECK-NEXT:  li   a0, -1
; CHECK-NEXT:  blt  a0, s1, .BB2_2
; CHECK-NEXT:  j  .BB2_1
; CHECK-NEXT:.BB2_1:
; CHECK-NEXT:  li   a0, 45
; CHECK-NEXT:  call mincaml_print_char
; CHECK-NEXT:  sub  s1, zero, s1
; CHECK-NEXT:.BB2_2:
; CHECK-NEXT:  li   a0, 900
; CHECK-NEXT:  blt  s1, a0, .BB2_4
; CHECK-NEXT:  j  .BB2_3
; CHECK-NEXT:.BB2_3:
; CHECK-NEXT:  li   a0, 57
; CHECK-NEXT:  call mincaml_print_char
; CHECK-NEXT:  addi  s1, s1, -900
; CHECK-NEXT:  j  .BB2_21
; CHECK-NEXT:.BB2_4:
; CHECK-NEXT:  li   a0, 800
; CHECK-NEXT:  blt  s1, a0, .BB2_6
; CHECK-NEXT:  j  .BB2_5
; CHECK-NEXT:.BB2_5:
; CHECK-NEXT:  li   a0, 56
; CHECK-NEXT:  call mincaml_print_char
; CHECK-NEXT:  addi  s1, s1, -800
; CHECK-NEXT:  j  .BB2_21
; CHECK-NEXT:.BB2_6:
; CHECK-NEXT:  li   a0, 700
; CHECK-NEXT:  blt  s1, a0, .BB2_8
; CHECK-NEXT:  j  .BB2_7
; CHECK-NEXT:.BB2_7:
; CHECK-NEXT:  li   a0, 55
; CHECK-NEXT:  call mincaml_print_char
; CHECK-NEXT:  addi  s1, s1, -700
; CHECK-NEXT:  j  .BB2_21
; CHECK-NEXT:.BB2_8:
; CHECK-NEXT:  li   a0, 600
; CHECK-NEXT:  blt  s1, a0, .BB2_10
; CHECK-NEXT:  j  .BB2_9
; CHECK-NEXT:.BB2_9:
; CHECK-NEXT:  li   a0, 54
; CHECK-NEXT:  call mincaml_print_char
; CHECK-NEXT:  addi  s1, s1, -600
; CHECK-NEXT:  j  .BB2_21
; CHECK-NEXT:.BB2_10:
; CHECK-NEXT:  li   a0, 500
; CHECK-NEXT:  blt  s1, a0, .BB2_12
; CHECK-NEXT:  j  .BB2_11
; CHECK-NEXT:.BB2_11:
; CHECK-NEXT:  li   a0, 53
; CHECK-NEXT:  call mincaml_print_char
; CHECK-NEXT:  addi  s1, s1, -500
; CHECK-NEXT:  j  .BB2_21
; CHECK-NEXT:.BB2_12:
; CHECK-NEXT:  li   a0, 400
; CHECK-NEXT:  blt  s1, a0, .BB2_14
; CHECK-NEXT:  j  .BB2_13
; CHECK-NEXT:.BB2_13:
; CHECK-NEXT:  li   a0, 52
; CHECK-NEXT:  call mincaml_print_char
; CHECK-NEXT:  addi  s1, s1, -400
; CHECK-NEXT:  j  .BB2_21
; CHECK-NEXT:.BB2_14:
; CHECK-NEXT:  li   a0, 300
; CHECK-NEXT:  blt  s1, a0, .BB2_16
; CHECK-NEXT:  j  .BB2_15
; CHECK-NEXT:.BB2_15:
; CHECK-NEXT:  li   a0, 51
; CHECK-NEXT:  call mincaml_print_char
; CHECK-NEXT:  addi  s1, s1, -300
; CHECK-NEXT:  j  .BB2_21
; CHECK-NEXT:.BB2_16:
; CHECK-NEXT:  li   a0, 200
; CHECK-NEXT:  blt  s1, a0, .BB2_18
; CHECK-NEXT:  j  .BB2_17
; CHECK-NEXT:.BB2_17:
; CHECK-NEXT:  li   a0, 50
; CHECK-NEXT:  call mincaml_print_char
; CHECK-NEXT:  addi  s1, s1, -200
; CHECK-NEXT:  j  .BB2_21
; CHECK-NEXT:.BB2_18:
; CHECK-NEXT:  li   a0, 100
; CHECK-NEXT:  blt  s1, a0, .BB2_20
; CHECK-NEXT:  j  .BB2_19
; CHECK-NEXT:.BB2_19:
; CHECK-NEXT:  li   a0, 49
; CHECK-NEXT:  call mincaml_print_char
; CHECK-NEXT:  addi  s1, s1, -100
; CHECK-NEXT:  j  .BB2_21
; CHECK-NEXT:.BB2_20:
; CHECK-NEXT:  li   a0, 48
; CHECK-NEXT:  call mincaml_print_char
; CHECK-NEXT:.BB2_21:
; CHECK-NEXT:  li   a0, 90
; CHECK-NEXT:  blt  s1, a0, .BB2_23
; CHECK-NEXT:  j  .BB2_22
; CHECK-NEXT:.BB2_22:
; CHECK-NEXT:  li   a0, 57
; CHECK-NEXT:  call mincaml_print_char
; CHECK-NEXT:  addi  s1, s1, -90
; CHECK-NEXT:  j  .BB2_40
; CHECK-NEXT:.BB2_23:
; CHECK-NEXT:  li   a0, 80
; CHECK-NEXT:  blt  s1, a0, .BB2_25
; CHECK-NEXT:  j  .BB2_24
; CHECK-NEXT:.BB2_24:
; CHECK-NEXT:  li   a0, 56
; CHECK-NEXT:  call mincaml_print_char
; CHECK-NEXT:  addi  s1, s1, -80
; CHECK-NEXT:  j  .BB2_40
; CHECK-NEXT:.BB2_25:
; CHECK-NEXT:  li   a0, 70
; CHECK-NEXT:  blt  s1, a0, .BB2_27
; CHECK-NEXT:  j  .BB2_26
; CHECK-NEXT:.BB2_26:
; CHECK-NEXT:  li   a0, 55
; CHECK-NEXT:  call mincaml_print_char
; CHECK-NEXT:  addi  s1, s1, -70
; CHECK-NEXT:  j  .BB2_40
; CHECK-NEXT:.BB2_27:
; CHECK-NEXT:  li   a0, 60
; CHECK-NEXT:  blt  s1, a0, .BB2_29
; CHECK-NEXT:  j  .BB2_28
; CHECK-NEXT:.BB2_28:
; CHECK-NEXT:  li   a0, 54
; CHECK-NEXT:  call mincaml_print_char
; CHECK-NEXT:  addi  s1, s1, -60
; CHECK-NEXT:  j  .BB2_40
; CHECK-NEXT:.BB2_29:
; CHECK-NEXT:  li   a0, 50
; CHECK-NEXT:  blt  s1, a0, .BB2_31
; CHECK-NEXT:  j  .BB2_30
; CHECK-NEXT:.BB2_30:
; CHECK-NEXT:  li   a0, 53
; CHECK-NEXT:  call mincaml_print_char
; CHECK-NEXT:  addi  s1, s1, -50
; CHECK-NEXT:  j  .BB2_40
; CHECK-NEXT:.BB2_31:
; CHECK-NEXT:  li   a0, 40
; CHECK-NEXT:  blt  s1, a0, .BB2_33
; CHECK-NEXT:  j  .BB2_32
; CHECK-NEXT:.BB2_32:
; CHECK-NEXT:  li   a0, 52
; CHECK-NEXT:  call mincaml_print_char
; CHECK-NEXT:  addi  s1, s1, -40
; CHECK-NEXT:  j  .BB2_40
; CHECK-NEXT:.BB2_33:
; CHECK-NEXT:  li   a0, 30
; CHECK-NEXT:  blt  s1, a0, .BB2_35
; CHECK-NEXT:  j  .BB2_34
; CHECK-NEXT:.BB2_34:
; CHECK-NEXT:  li   a0, 51
; CHECK-NEXT:  call mincaml_print_char
; CHECK-NEXT:  addi  s1, s1, -30
; CHECK-NEXT:  j  .BB2_40
; CHECK-NEXT:.BB2_35:
; CHECK-NEXT:  li   a0, 20
; CHECK-NEXT:  blt  s1, a0, .BB2_37
; CHECK-NEXT:  j  .BB2_36
; CHECK-NEXT:.BB2_36:
; CHECK-NEXT:  li   a0, 50
; CHECK-NEXT:  call mincaml_print_char
; CHECK-NEXT:  addi  s1, s1, -20
; CHECK-NEXT:  j  .BB2_40
; CHECK-NEXT:.BB2_37:
; CHECK-NEXT:  li   a0, 10
; CHECK-NEXT:  blt  s1, a0, .BB2_39
; CHECK-NEXT:  j  .BB2_38
; CHECK-NEXT:.BB2_38:
; CHECK-NEXT:  li   a0, 49
; CHECK-NEXT:  call mincaml_print_char
; CHECK-NEXT:  addi  s1, s1, -10
; CHECK-NEXT:  j  .BB2_40
; CHECK-NEXT:.BB2_39:
; CHECK-NEXT:  li   a0, 48
; CHECK-NEXT:  call mincaml_print_char
; CHECK-NEXT:.BB2_40:
; CHECK-NEXT:  addi  a0, s1, 48
; CHECK-NEXT:  call mincaml_print_char
; CHECK-NEXT:  lw  s1, 4(sp)
; CHECK-NEXT:  lw  sp, 8(sp)
; CHECK-NEXT:  lw  ra, 12(sp)
; CHECK-NEXT:  addi  sp, sp, 16
; CHECK-NEXT:  ret
  %2 = icmp sge i32 %0, 0
  br i1 %2, label %3, label %4

3:                                                ; preds = %1
  br label %6

4:                                                ; preds = %1
  call void @mincaml_print_char(i32 45)
  %5 = sub i32 0, %0
  br label %6

6:                                                ; preds = %3, %4
  %7 = phi i32 [ %5, %4 ], [ %0, %3 ]
  br label %8

8:                                                ; preds = %6
  %9 = icmp sge i32 %7, 900
  br i1 %9, label %10, label %12

10:                                               ; preds = %8
  call void @mincaml_print_char(i32 57)
  %11 = sub i32 %7, 900
  br label %69

12:                                               ; preds = %8
  %13 = icmp sge i32 %7, 800
  br i1 %13, label %14, label %16

14:                                               ; preds = %12
  call void @mincaml_print_char(i32 56)
  %15 = sub i32 %7, 800
  br label %66

16:                                               ; preds = %12
  %17 = icmp sge i32 %7, 700
  br i1 %17, label %18, label %20

18:                                               ; preds = %16
  call void @mincaml_print_char(i32 55)
  %19 = sub i32 %7, 700
  br label %63

20:                                               ; preds = %16
  %21 = icmp sge i32 %7, 600
  br i1 %21, label %22, label %24

22:                                               ; preds = %20
  call void @mincaml_print_char(i32 54)
  %23 = sub i32 %7, 600
  br label %60

24:                                               ; preds = %20
  %25 = icmp sge i32 %7, 500
  br i1 %25, label %26, label %28

26:                                               ; preds = %24
  call void @mincaml_print_char(i32 53)
  %27 = sub i32 %7, 500
  br label %57

28:                                               ; preds = %24
  %29 = icmp sge i32 %7, 400
  br i1 %29, label %30, label %32

30:                                               ; preds = %28
  call void @mincaml_print_char(i32 52)
  %31 = sub i32 %7, 400
  br label %54

32:                                               ; preds = %28
  %33 = icmp sge i32 %7, 300
  br i1 %33, label %34, label %36

34:                                               ; preds = %32
  call void @mincaml_print_char(i32 51)
  %35 = sub i32 %7, 300
  br label %51

36:                                               ; preds = %32
  %37 = icmp sge i32 %7, 200
  br i1 %37, label %38, label %40

38:                                               ; preds = %36
  call void @mincaml_print_char(i32 50)
  %39 = sub i32 %7, 200
  br label %48

40:                                               ; preds = %36
  %41 = icmp sge i32 %7, 100
  br i1 %41, label %42, label %44

42:                                               ; preds = %40
  call void @mincaml_print_char(i32 49)
  %43 = sub i32 %7, 100
  br label %45

44:                                               ; preds = %40
  call void @mincaml_print_char(i32 48)
  br label %45

45:                                               ; preds = %42, %44
  %46 = phi i32 [ %7, %44 ], [ %43, %42 ]
  br label %47

47:                                               ; preds = %45
  br label %48

48:                                               ; preds = %38, %47
  %49 = phi i32 [ %46, %47 ], [ %39, %38 ]
  br label %50

50:                                               ; preds = %48
  br label %51

51:                                               ; preds = %34, %50
  %52 = phi i32 [ %49, %50 ], [ %35, %34 ]
  br label %53

53:                                               ; preds = %51
  br label %54

54:                                               ; preds = %30, %53
  %55 = phi i32 [ %52, %53 ], [ %31, %30 ]
  br label %56

56:                                               ; preds = %54
  br label %57

57:                                               ; preds = %26, %56
  %58 = phi i32 [ %55, %56 ], [ %27, %26 ]
  br label %59

59:                                               ; preds = %57
  br label %60

60:                                               ; preds = %22, %59
  %61 = phi i32 [ %58, %59 ], [ %23, %22 ]
  br label %62

62:                                               ; preds = %60
  br label %63

63:                                               ; preds = %18, %62
  %64 = phi i32 [ %61, %62 ], [ %19, %18 ]
  br label %65

65:                                               ; preds = %63
  br label %66

66:                                               ; preds = %14, %65
  %67 = phi i32 [ %64, %65 ], [ %15, %14 ]
  br label %68

68:                                               ; preds = %66
  br label %69

69:                                               ; preds = %10, %68
  %70 = phi i32 [ %67, %68 ], [ %11, %10 ]
  br label %71

71:                                               ; preds = %69
  %72 = icmp sge i32 %70, 90
  br i1 %72, label %73, label %75

73:                                               ; preds = %71
  call void @mincaml_print_char(i32 57)
  %74 = sub i32 %70, 90
  br label %132

75:                                               ; preds = %71
  %76 = icmp sge i32 %70, 80
  br i1 %76, label %77, label %79

77:                                               ; preds = %75
  call void @mincaml_print_char(i32 56)
  %78 = sub i32 %70, 80
  br label %129

79:                                               ; preds = %75
  %80 = icmp sge i32 %70, 70
  br i1 %80, label %81, label %83

81:                                               ; preds = %79
  call void @mincaml_print_char(i32 55)
  %82 = sub i32 %70, 70
  br label %126

83:                                               ; preds = %79
  %84 = icmp sge i32 %70, 60
  br i1 %84, label %85, label %87

85:                                               ; preds = %83
  call void @mincaml_print_char(i32 54)
  %86 = sub i32 %70, 60
  br label %123

87:                                               ; preds = %83
  %88 = icmp sge i32 %70, 50
  br i1 %88, label %89, label %91

89:                                               ; preds = %87
  call void @mincaml_print_char(i32 53)
  %90 = sub i32 %70, 50
  br label %120

91:                                               ; preds = %87
  %92 = icmp sge i32 %70, 40
  br i1 %92, label %93, label %95

93:                                               ; preds = %91
  call void @mincaml_print_char(i32 52)
  %94 = sub i32 %70, 40
  br label %117

95:                                               ; preds = %91
  %96 = icmp sge i32 %70, 30
  br i1 %96, label %97, label %99

97:                                               ; preds = %95
  call void @mincaml_print_char(i32 51)
  %98 = sub i32 %70, 30
  br label %114

99:                                               ; preds = %95
  %100 = icmp sge i32 %70, 20
  br i1 %100, label %101, label %103

101:                                              ; preds = %99
  call void @mincaml_print_char(i32 50)
  %102 = sub i32 %70, 20
  br label %111

103:                                              ; preds = %99
  %104 = icmp sge i32 %70, 10
  br i1 %104, label %105, label %107

105:                                              ; preds = %103
  call void @mincaml_print_char(i32 49)
  %106 = sub i32 %70, 10
  br label %108

107:                                              ; preds = %103
  call void @mincaml_print_char(i32 48)
  br label %108

108:                                              ; preds = %105, %107
  %109 = phi i32 [ %70, %107 ], [ %106, %105 ]
  br label %110

110:                                              ; preds = %108
  br label %111

111:                                              ; preds = %101, %110
  %112 = phi i32 [ %109, %110 ], [ %102, %101 ]
  br label %113

113:                                              ; preds = %111
  br label %114

114:                                              ; preds = %97, %113
  %115 = phi i32 [ %112, %113 ], [ %98, %97 ]
  br label %116

116:                                              ; preds = %114
  br label %117

117:                                              ; preds = %93, %116
  %118 = phi i32 [ %115, %116 ], [ %94, %93 ]
  br label %119

119:                                              ; preds = %117
  br label %120

120:                                              ; preds = %89, %119
  %121 = phi i32 [ %118, %119 ], [ %90, %89 ]
  br label %122

122:                                              ; preds = %120
  br label %123

123:                                              ; preds = %85, %122
  %124 = phi i32 [ %121, %122 ], [ %86, %85 ]
  br label %125

125:                                              ; preds = %123
  br label %126

126:                                              ; preds = %81, %125
  %127 = phi i32 [ %124, %125 ], [ %82, %81 ]
  br label %128

128:                                              ; preds = %126
  br label %129

129:                                              ; preds = %77, %128
  %130 = phi i32 [ %127, %128 ], [ %78, %77 ]
  br label %131

131:                                              ; preds = %129
  br label %132

132:                                              ; preds = %73, %131
  %133 = phi i32 [ %130, %131 ], [ %74, %73 ]
  br label %134

134:                                              ; preds = %132
  %135 = add i32 48, %133
  call void @mincaml_print_char(i32 %135)
  ret void
}

define i32 @main() {
; CHECK-LABEL: main:
; CHECK:       # %bb.0:
; CHECK-NEXT:  addi  sp, sp, -16
; CHECK-NEXT:  sw  ra, 12(sp)
; CHECK-NEXT:  sw  sp, 8(sp)
; CHECK-NEXT:  call mincaml_read_int
; CHECK-NEXT:  call print_int
; CHECK-NEXT:  li   a0, 0
; CHECK-NEXT:  lw  sp, 8(sp)
; CHECK-NEXT:  lw  ra, 12(sp)
; CHECK-NEXT:  addi  sp, sp, 16
; CHECK-NEXT:  ret
  %1 = call i32 @mincaml_read_int()
  call void @print_int(i32 %1)
  ret i32 0
}

!llvm.ident = !{!0}

!0 = !{!"mlc @ 64c4b07593efa4914d053650ba48d8dc4dec6303"}
