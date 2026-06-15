// Routine main
li t0, 1
li t3, 2
beq t0, t3, L1
j L4
L4:
j L2
L1:
li t4, 1
mv t1, t4
j L3
L2:
li t5, 0
mv t1, t5
L3:
la t6, L_str_0
