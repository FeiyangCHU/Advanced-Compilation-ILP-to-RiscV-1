// Routine L1
mv i0, a0
mv i1, a1
add t4, i0, i1
mv rv, t4
// Routine main
li t5, 1
li t6, 0
bne t5, t6, L2
j L5
L5:
j L3
L2:
li t7, 8
mv t1, t7
j L4
L3:
li t8, 1
mv t1, t8
L4:
mv t0, t1
li t9, 8
mv t2, t9
mul t10, t2, t2
mv t3, t10
mv a0, t0
mv a1, t3
call L1
