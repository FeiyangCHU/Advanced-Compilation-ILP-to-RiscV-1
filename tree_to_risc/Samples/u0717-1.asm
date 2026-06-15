// Routine main
li t0, 717
li t2, 1
li t3, 0
bne t2, t3, L1
j L6
L6:
j L2
L1:
li t4, 0
li t5, 0
bne t4, t5, L4
j L7
L7:
j L5
L4:
li t6, 0
mv t1, t6
j L3
L5:
li t7, 1
mv t1, t7
j L3
L2:
li t8, 0
mv t1, t8
