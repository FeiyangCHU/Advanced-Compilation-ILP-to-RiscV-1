// Routine main
li t4, 0
li t5, 0
bne t4, t5, L4
j L10
L10:
j L5
L4:
li t6, 1
mv t2, t6
j L6
L5:
li t7, 710
li t8, 1
li t9, 0
bne t8, t9, L7
j L11
L11:
j L8
L7:
li t10, 1
mv t3, t10
j L9
L8:
li t11, 2
li t12, 1
mv t3, t12
L9:
mv t2, t3
L6:
li t13, 0
bne t2, t13, L1
j L12
L12:
j L2
L1:
la t14, L_str_0
mv t1, t14
j L3
L2:
la t15, L_str_1
mv t1, t15
L3:
mv t0, t1
mv a0, t0
call print
mv t16, a0
