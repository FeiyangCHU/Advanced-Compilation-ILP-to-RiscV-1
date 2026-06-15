// Routine main
li t0, 50
mv t1, t0
L1:
li t3, 52
blt t1, t3, L4
j L7
L7:
j L5
L4:
li t4, 1
mv t2, t4
j L6
L5:
li t5, 0
mv t2, t5
L6:
li t6, 0
bne t2, t6, L2
j L8
L8:
j L3
L2:
li t7, 1
add t8, t1, t7
mv t1, t8
j L1
L3:
