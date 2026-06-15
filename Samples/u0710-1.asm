// Routine main
li t0, 0
li t6, 0
bne t0, t6, L1
j L7
L7:
j L2
L1:
li t7, 1
mv t1, t7
j L3
L2:
li t8, 710
li t9, 1
mv t4, t9
li t10, 0
bne t4, t10, L4
j L8
L8:
j L5
L4:
li t11, 1
mv t3, t11
j L6
L5:
li t12, 2
li t13, 1
mv t5, t13
mv t3, t5
L6:
mv t2, t3
mv t1, t2
