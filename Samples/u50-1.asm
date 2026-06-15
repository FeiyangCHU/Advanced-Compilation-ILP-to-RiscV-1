// Routine main
la t4, L_str_0
mv t0, t4
li t5, 2
mv t1, t5
mv a0, t1
call string_of_int
mv t6, a0
mv t2, t6
mv t3, t2
mv a0, t0
mv a1, t3
call concat
