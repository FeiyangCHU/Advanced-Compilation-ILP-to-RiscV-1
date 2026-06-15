// Routine main
li t0, 1
li t1, 0
beq t0, t1, L2
j L1
L1:
la t2, L_float_0
flw f3, 0(t2)
fmv.s f1, f3
j L3
L2:
li t4, 0
fcvt.s.w f1, t4
