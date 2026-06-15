// Routine L1
mv i0, a0
li t6, 2
mul t7, t6, i0
mv t1, t7
mv rv, t1
// Routine main
li t8, 27
mv t0, t8
mv a0, t0
call L1
mv t9, a0
mv t2, t9
mv t3, t2
mv a0, t3
call string_of_int
mv t10, a0
mv t4, t10
mv t5, t4
mv a0, t5
call print
mv t11, a0
