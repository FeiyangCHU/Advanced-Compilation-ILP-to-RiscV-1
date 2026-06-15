// Routine main
li t4, 1
mv t0, t4
mv a0, t0
call float_of_int
fmv.s f5, fa0
fmv.s f1, f5
la t6, L_float_0
flw f7, 0(t6)
feq.s t8, f7, f1
beqz t8, L4
j L7
L7:
j L5
L4:
li t9, 1
mv t2, t9
j L6
L5:
li t10, 0
mv t2, t10
L6:
li t11, 0
bne t2, t11, L1
j L8
L8:
j L2
L1:
la t12, L_str_0
mv t1, t12
j L3
L2:
la t13, L_str_1
mv t1, t13
L3:
mv t3, t1
mv a0, t3
call print
mv t14, a0
