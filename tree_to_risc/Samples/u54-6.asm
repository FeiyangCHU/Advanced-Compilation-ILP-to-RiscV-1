// Routine L1
mv i0, a0
li t6, 1
add t7, i0, t6
mv t1, t7
li t8, 2
mul t9, t8, t1
mv rv, t9
// Routine main
li t10, 3
mv t0, t10
mv a0, t0
call L1
mv t11, a0
mv t2, t11
mv t3, t2
mv a0, t3
call string_of_int
mv t12, a0
mv t4, t12
mv t5, t4
mv a0, t5
call print
mv t13, a0
