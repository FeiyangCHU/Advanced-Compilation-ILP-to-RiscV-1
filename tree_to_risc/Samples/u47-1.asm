// Routine main
li t2, 0
li t3, 0
bne t2, t3, L1
j L4
L4:
j L2
L1:
la t4, L_str_0
mv t0, t4
mv a0, t0
call print
mv t5, a0
li t6, 0
mv t1, t6
j L3
L2:
li t7, 0
mv t1, t7
L3:
