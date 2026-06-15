// Routine L1
mv i0, a0
li t2, 2
mul t3, t2, i0
mv t1, t3
mv rv, t1
// Routine main
li t4, 52
li t5, 3
add t6, t4, t5
mv t0, t6
mv a0, t0
call L1
