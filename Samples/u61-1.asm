// Routine main
li t9, 1
mv t1, t9
li t10, 1
mv t3, t10
li t11, 0
beq t3, t11, L2
j L1
L1:
mv t0, t1
mv a0, t0
call string_of_int
mv t12, a0
mv t5, t12
mv t6, t5
la t13, L_str_0
mv t7, t13
mv a0, t6
mv a1, t7
call concat
mv t14, a0
la t15, L_str_1
mv t4, t15
mv t2, t4
j L3
L2:
la t16, L_float_0
flw f17, 0(t16)
fcvt.w.s t2, f17
L3:
mv t8, t2
mv a0, t8
call print
mv t18, a0
