// Routine main
li t0, 717
li t3, 1
mv t2, t3
li t4, 0
bne t2, t4, L1
j L6
L6:
j L2
L1:
li t5, 0
li t6, 0
bne t5, t6, L4
j L7
L7:
j L5
L4:
li t7, 0
mv t1, t7
j L3
L5:
li t8, 1
mv t1, t8
j L3
L2:
li t9, 0
mv t1, t9
