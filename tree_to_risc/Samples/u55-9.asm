// Routine main
li t3, 1
li t4, 1
beq t3, t4, L4
j L7
L7:
j L5
L4:
li t5, 1
mv t2, t5
j L6
L5:
li t6, 0
mv t2, t6
L6:
li t7, 0
bne t2, t7, L1
j L8
L8:
j L2
L1:
la t8, L_str_0
mv t1, t8
j L3
L2:
la t9, L_str_1
mv t1, t9
L3:
mv t0, t1
mv a0, t0
call print
mv t10, a0
