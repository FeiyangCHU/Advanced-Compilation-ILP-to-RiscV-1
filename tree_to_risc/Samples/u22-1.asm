// Routine main
li t1, 22
li t2, 1
li t3, 0
bne t2, t3, L1
j L4
L4:
j L2
L1:
li t4, 1
mv t0, t4
mv a0, t0
call float_of_int
fmv.s f5, fa0
fmv.s f1, f5
j L3
L2:
la t6, L_float_0
flw f7, 0(t6)
fmv.s f1, f7
