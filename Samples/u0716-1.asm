// Routine main
li t0, 0
li t4, 0
bne t0, t4, L1
j L6
L6:
j L2
L1:
li t5, 3
li t6, 1
mv t2, t6
li t7, 0
bne t2, t7, L4
j L7
L7:
j L5
L4:
li t8, 0
mv t1, t8
j L3
L5:
li t9, 1
mv t1, t9
j L3
L2:
li t10, 3
li t11, 1
mv t3, t11
mv t1, t3
