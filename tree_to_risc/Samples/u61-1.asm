// Routine main
li t6, 1
mv t1, t6
li t8, 1
li t9, 0
bne t8, t9, L1
j L4
L4:
j L2
L1:
mv t0, t1
mv a0, t0
call string_of_int
mv t10, a0
mv t3, t10
mv t4, t3
la t11, L_str_0
mv t5, t11
mv a0, t4
mv a1, t5
call concat
mv t12, a0
la t13, L_str_1
mv t2, t13
j L3
L2:
la t14, L_float_0
flw f15, 0(t14)
fmv.s f6, f15
fmv.s fa0, f6
call string_of_float
mv t16, a0
mv t2, t16
L3:
mv t7, t2
mv a0, t7
call print
mv t17, a0
