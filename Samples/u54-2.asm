// Routine L1
mv i0, a0
li t2, 2
mul t3, t2, i0
mv t1, t3
mv rv, t1
// Routine main
li t4, 27
mv t0, t4
mv a0, t0
call L1
