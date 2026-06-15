// Routine L1
mv i0, a0
li t7, 2
mul t8, t7, i0
mv rv, t8
// Routine L2
mv i1, a0
mv rv, i1
// Routine main
li t9, 12
mv t1, t9
mv t0, t1
mv a0, t0
call L1
mv t10, a0
mv t1, t10
mv t2, t1
mv t3, t1
mv a0, t2
mv a1, t3
call L2
mv t11, a0
mv t4, t11
mv t5, t4
mv a0, t5
call L1
mv t12, a0
