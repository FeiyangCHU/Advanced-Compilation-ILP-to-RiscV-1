// Routine L1
mv i0, a0
li t8, 2
mul t9, t8, i0
mv t1, t9
mv rv, t1
// Routine L2
mv i1, a0
mv rv, i1
// Routine main
li t10, 11
mv t2, t10
li t11, 1
add t12, t2, t11
mv t2, t12
mv t3, t2
mv t0, t3
mv t4, t2
mv a0, t0
mv a1, t4
call L2
mv t13, a0
mv t5, t13
mv t6, t5
mv a0, t6
call L1
mv t14, a0
