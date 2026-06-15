// Routine main
li t3, 20
li t4, 1
add t5, t3, t4
mv t0, t5
mv a0, t0
call string_of_int
mv t6, a0
mv t1, t6
mv t2, t1
mv a0, t2
call print
mv t7, a0
