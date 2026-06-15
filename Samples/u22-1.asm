// Routine main
li t0, 22
li t3, 1
mv t2, t3
li t4, 0
beq t2, t4, L2
j L1
L1:
li t5, 1
mv t1, t5
j L3
L2:
la t6, L_float_0
flw f7, 0(t6)
fcvt.w.s t1, f7
