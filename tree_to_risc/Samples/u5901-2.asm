// Routine L1
mv i0, a0
li t6, 2
mul t7, t6, i0
mv rv, t7
// Routine L2
mv i1, a0
mv rv, i1
// Routine main
li t8, 11
mv t1, t8
li t9, 1
add t10, t1, t9
mv t1, t10
mv t0, t1
mv t2, t1
mv a0, t0
mv a1, t2
call L2
mv t11, a0
mv t3, t11
mv t4, t3
mv a0, t4
call L1
mv t12, a0
