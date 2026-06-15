// Routine main
li t0, 0
li t2, 0
bne t0, t2, L1
j L6
L6:
j L2
L1:
li t3, 0
li t4, 0
bne t3, t4, L4
j L7
L7:
j L5
L4:
li t5, 0
mv t1, t5
j L3
L5:
li t6, 1
mv t1, t6
j L3
L2:
li t7, 0
mv t1, t7
