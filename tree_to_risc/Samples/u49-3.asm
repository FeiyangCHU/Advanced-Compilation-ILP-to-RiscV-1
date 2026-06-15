// Routine main
li t1, 2
mv t0, t1
mv a0, t0
call float_of_int
fmv.s f3, fa0
fmv.s f1, f3
la t6, L_float_0
flw f7, 0(t6)
fdiv.s f8, f7, f1
fmv.s f2, f8
fmv.s fa0, f2
call string_of_float
mv t9, a0
mv t3, t9
mv t4, t3
la t10, L_str_0
mv t5, t10
mv a0, t4
mv a1, t5
call concat
