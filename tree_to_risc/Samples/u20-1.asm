// Routine main
li t0, 45
li t2, 44
bge t2, t0, L1
j L4
L4:
j L2
L1:
li t3, 1
mv t1, t3
j L3
L2:
li t4, 0
mv t1, t4
