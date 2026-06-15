// Routine main
li t4, 12
mv t0, t4
mv a0, t0
call string_of_int
mv t5, a0
mv t1, t5
mv t2, t1
la t6, L_str_0
mv t3, t6
mv a0, t2
mv a1, t3
call concat
