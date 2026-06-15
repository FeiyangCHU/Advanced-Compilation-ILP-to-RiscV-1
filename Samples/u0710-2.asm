// Routine main
li t7, 0
li t8, 0
bne t7, t8, L4
j L10
L10:
j L5
L4:
li t9, 1
mv t2, t9
j L6
L5:
li t10, 710
li t11, 1
mv t5, t11
li t12, 0
bne t5, t12, L7
j L11
L11:
j L8
L7:
li t13, 1
mv t4, t13
j L9
L8:
li t14, 2
li t15, 1
mv t6, t15
mv t4, t6
L9:
mv t3, t4
mv t2, t3
L6:
li t16, 0
bne t2, t16, L1
j L12
L12:
j L2
L1:
la t17, L_str_0
mv t1, t17
j L3
L2:
la t18, L_str_1
mv t1, t18
L3:
mv t0, t1
mv a0, t0
call print
mv t19, a0
