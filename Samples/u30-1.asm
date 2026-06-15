// Routine main
li t2, 22
mv t1, t2
la t3, L_float_0
flw f4, 0(t3)
fmv.s f2, f4
mv t0, t1
mv a0, t0
call float_of_int
fmv.s f5, fa0
fmv.s f1, f5
