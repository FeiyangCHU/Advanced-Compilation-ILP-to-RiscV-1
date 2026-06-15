// Routine main
la t6, L_str_0
mv t0, t6
la t7, L_str_1
mv t4, t7
mv a0, t0
mv a1, t4
call strcmp
mv t8, a0
mv t2, t8
li t9, 0
bne t2, t9, L4
j L7
L7:
j L5
L4:
li t10, 1
mv t3, t10
j L6
L5:
li t11, 0
mv t3, t11
L6:
li t12, 0
bne t3, t12, L1
j L8
L8:
j L2
L1:
la t13, L_str_2
mv t1, t13
j L3
L2:
la t14, L_str_3
mv t1, t14
L3:
mv t5, t1
mv a0, t5
call print
mv t15, a0
