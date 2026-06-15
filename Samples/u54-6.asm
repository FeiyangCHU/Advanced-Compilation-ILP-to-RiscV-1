// Routine L1
mv i0, a0
li t7, 1
add t8, i0, t7
mv t2, t8
li t9, 2
mul t10, t9, t2
mv t1, t10
mv rv, t1
// Routine main
li t11, 3
mv t0, t11
mv a0, t0
call L1
mv t12, a0
mv t3, t12
mv t4, t3
mv a0, t4
call string_of_int
mv t13, a0
mv t5, t13
mv t6, t5
mv a0, t6
call print
mv t14, a0
