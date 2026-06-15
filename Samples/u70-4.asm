// Routine main
li t0, 1
li t5, 1
beq t0, t5, L7
j L10
L10:
j L8
L7:
li t6, 1
mv t4, t6
j L9
L8:
li t7, 0
mv t4, t7
L9:
li t8, 0
beq t4, t8, L5
j L4
L4:
li t9, 1
mv t3, t9
j L6
L5:
li t10, 0
mv t3, t10
L6:
mv t2, t3
li t11, 0
beq t2, t11, L2
j L1
L1:
li t12, 3
mv t1, t12
j L3
L2:
li t13, 4
mv t1, t13
