// Routine L1
mv i0, a0
li t5, 2
mul t6, t5, i0
mv rv, t6
// Routine main
li t7, 27
mv t0, t7
mv a0, t0
call L1
mv t8, a0
mv t1, t8
mv t2, t1
mv a0, t2
call string_of_int
mv t9, a0
mv t3, t9
mv t4, t3
mv a0, t4
call print
mv t10, a0
