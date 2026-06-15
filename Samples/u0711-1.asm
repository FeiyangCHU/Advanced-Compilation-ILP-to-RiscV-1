// Routine main
li t0, 711
li t6, 1
mv t2, t6
li t7, 0
bne t2, t7, L1
j L7
L7:
j L2
L1:
li t8, 1
mv t1, t8
j L3
L2:
li t9, 0
li t10, 0
bne t9, t10, L4
j L8
L8:
j L5
L4:
li t11, 1
mv t4, t11
j L6
L5:
li t12, 2
li t13, 1
mv t5, t13
mv t4, t5
L6:
mv t3, t4
mv t1, t3
