// Routine L1
mv i0, a0
mv i1, a1
add t7, i0, i1
mv t1, t7
mv rv, t1
// Routine main
li t8, 1
li t9, 0
beq t8, t9, L3
j L2
L2:
li t10, 8
mv t3, t10
j L4
L3:
li t11, 1
mv t3, t11
L4:
mv t2, t3
mv t0, t2
li t12, 8
mv t5, t12
mul t13, t5, t5
mv t4, t13
mv t6, t4
mv a0, t0
mv a1, t6
call L1
