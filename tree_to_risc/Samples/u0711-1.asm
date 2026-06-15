// Routine main
li t0, 711
li t3, 1
li t4, 0
bne t3, t4, L1
j L7
L7:
j L2
L1:
li t5, 1
mv t1, t5
j L3
L2:
li t6, 0
li t7, 0
bne t6, t7, L4
j L8
L8:
j L5
L4:
li t8, 1
mv t2, t8
j L6
L5:
li t9, 2
li t10, 1
mv t2, t10
L6:
mv t1, t2
