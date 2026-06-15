// Routine L1
mv i0, a0
li t9, 2
mul t10, t9, i0
mv t1, t10
mv rv, t1
// Routine L2
mv i1, a0
mv rv, i1
// Routine main
li t11, 12
mv t2, t11
mv t0, t2
mv a0, t0
call L1
mv t12, a0
mv t2, t12
mv t3, t2
mv t4, t3
mv t5, t2
mv a0, t4
mv a1, t5
call L2
mv t13, a0
mv t6, t13
mv t7, t6
mv a0, t7
call L1
mv t14, a0
