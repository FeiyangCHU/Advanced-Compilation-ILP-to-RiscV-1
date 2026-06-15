// Routine L1
mv i0, a0
li t1, 2
div t2, i0, t1
mv rv, t2
// Routine main
li t3, 2
li t4, 5490
mul t5, t3, t4
mv t0, t5
mv a0, t0
call L1
