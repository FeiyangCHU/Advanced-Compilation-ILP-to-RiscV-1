// Routine main
li t0, 1
li t2, 2
beq t0, t2, L1
j L4
L4:
j L2
L1:
li t3, 1
mv t1, t3
j L3
L2:
li t4, 0
mv t1, t4
L3:
