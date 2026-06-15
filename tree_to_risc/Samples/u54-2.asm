// Routine L1
mv i0, a0
li t1, 2
mul t2, t1, i0
mv rv, t2
// Routine main
li t3, 27
mv t0, t3
mv a0, t0
call L1
