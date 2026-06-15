// Routine L1
fmv.s fi0, fa0
li t1, 2
mv t0, t1
mv a0, t0
call float_of_int
fmv.s f5, fa0
fmv.s f1, f5
fmul.s f6, f1, fi0
fmv.s fa0, f6
// Routine main
la t7, L_float_0
flw f8, 0(t7)
fmv.s f2, f8
fmv.s fa0, f2
call L1
fmv.s f9, fa0
fmv.s f3, f9
fmv.s f4, f3
fmv.s fa0, f4
call string_of_float
mv t10, a0
mv t5, t10
mv t6, t5
mv a0, t6
call print
mv t11, a0
