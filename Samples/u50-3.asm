// Routine main
li t5, 1
li t6, 0
blt t5, t6, L4
j L7
L7:
j L5
L4:
li t7, 1
mv t3, t7
j L6
L5:
li t8, 0
mv t3, t8
L6:
mv t2, t3
li t9, 0
beq t2, t9, L2
j L1
L1:
la t10, L_str_0
mv t1, t10
j L3
L2:
la t11, L_str_1
mv t1, t11
L3:
mv t0, t1
la t12, L_str_2
mv t4, t12
mv a0, t0
mv a1, t4
call concat
