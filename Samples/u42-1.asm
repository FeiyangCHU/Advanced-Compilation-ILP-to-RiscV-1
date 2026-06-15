// Routine main
li t1, 1
mv t0, t1
mv a0, t0
call float_of_int
fmv.s f3, fa0
fmv.s f1, f3
la t5, L_float_0
flw f6, 0(t5)
fsub.s f7, f6, f1
fmv.s f2, f7
fmv.s fa0, f2
call string_of_float
mv t8, a0
mv t3, t8
mv t4, t3
mv a0, t4
call print
mv t9, a0
