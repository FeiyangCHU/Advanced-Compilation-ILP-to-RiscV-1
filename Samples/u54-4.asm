// Routine L1
fmv.s fi0, fa0
li t1, 2
mv t0, t1
mv a0, t0
call float_of_int
fmv.s f6, fa0
fmv.s f2, f6
fmul.s f7, f2, fi0
fmv.s f1, f7
fmv.s fa0, f1
// Routine main
la t8, L_float_0
flw f9, 0(t8)
fmv.s f3, f9
fmv.s fa0, f3
call L1
fmv.s f10, fa0
fmv.s f4, f10
fmv.s f5, f4
fmv.s fa0, f5
call string_of_float
mv t11, a0
mv t6, t11
mv t7, t6
mv a0, t7
call print
mv t12, a0
