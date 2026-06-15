// Routine main
la t3, L_str_0
li t4, 1
li t5, 1
mv t2, t5
li t6, 0
bne t2, t6, L1
j L4
L4:
j L2
L1:
la t7, L_str_0
mv t1, t7
j L3
L2:
la t8, L_str_1
mv t1, t8
L3:
mv t0, t1
mv a0, t0
call print
mv t9, a0
