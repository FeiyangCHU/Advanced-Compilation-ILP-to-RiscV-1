// Routine main
li t4, 1
li t5, 0
bge t4, t5, L4
j L7
L7:
j L5
L4:
li t6, 1
mv t2, t6
j L6
L5:
li t7, 0
mv t2, t7
L6:
li t8, 0
bne t2, t8, L1
j L8
L8:
j L2
L1:
la t9, L_str_1
mv t1, t9
j L3
L2:
la t10, L_str_2
mv t1, t10
L3:
mv t0, t1
la t11, L_str_0
mv t3, t11
mv a0, t0
mv a1, t3
call concat
