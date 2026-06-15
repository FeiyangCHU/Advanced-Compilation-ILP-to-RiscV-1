// Routine L1
mv i0, a0
li t2, 2
div t3, i0, t2
mv t1, t3
mv rv, t1
// Routine main
li t4, 2
li t5, 5490
mul t6, t4, t5
mv t0, t6
mv a0, t0
call L1
