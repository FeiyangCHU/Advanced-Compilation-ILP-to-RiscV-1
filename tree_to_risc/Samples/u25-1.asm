// Routine main
li t0, 1
li t1, 0
bne t0, t1, L1
j L4
L4:
j L2
L1:
la t2, L_float_0
flw f3, 0(t2)
fmv.s f1, f3
j L3
L2:
la t4, L_float_1
flw f5, 0(t4)
fmv.s f1, f5
