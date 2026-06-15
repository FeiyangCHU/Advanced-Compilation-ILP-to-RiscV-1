// Routine main
li t0, 50
mv t1, t0
L1:
li t5, 52
blt t1, t5, L4
j L7
L7:
j L5
L4:
li t6, 1
mv t2, t6
j L6
L5:
li t7, 0
mv t2, t7
L6:
li t8, 0
beq t2, t8, L3
j L2
L2:
li t9, 1
add t10, t1, t9
mv t1, t10
mv t3, t1
j L1
L3:
li t11, 0
