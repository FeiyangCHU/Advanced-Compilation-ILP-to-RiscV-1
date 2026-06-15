// Routine main
la t2, L_str_0
li t3, 1
li t4, 1
li t5, 0
bne t4, t5, L1
j L4
L4:
j L2
L1:
la t6, L_str_0
mv t1, t6
j L3
L2:
la t7, L_str_1
mv t1, t7
L3:
mv t0, t1
mv a0, t0
call print
mv t8, a0
