// Routine main
li t3, 1
li t4, 0
beq t3, t4, L2
j L1
L1:
la t5, L_str_0
mv t0, t5
mv a0, t0
call print
mv t6, a0
li t7, 0
mv t1, t7
j L3
L2:
li t8, 0
mv t1, t8
L3:
li t9, 48
