// Routine main
li t0, 1
li t4, 1
beq t0, t4, L7
j L10
L10:
j L8
L7:
li t5, 1
mv t3, t5
j L9
L8:
li t6, 0
mv t3, t6
L9:
li t7, 0
bne t3, t7, L4
j L11
L11:
j L5
L4:
li t8, 1
mv t2, t8
j L6
L5:
li t9, 0
mv t2, t9
L6:
li t10, 0
bne t2, t10, L1
j L12
L12:
j L2
L1:
li t11, 3
mv t1, t11
j L3
L2:
li t12, 4
mv t1, t12
