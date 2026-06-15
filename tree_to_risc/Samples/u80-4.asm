// Routine main
la t5, L_str_0
mv t0, t5
mv a0, t0
call print
mv t6, a0
li t7, 0
la t8, L_str_1
mv t1, t8
la t9, L_str_2
mv t2, t9
mv a0, t1
mv a1, t2
call concat
mv t10, a0
mv t3, t10
mv t4, t3
mv a0, t4
call print
mv t11, a0
