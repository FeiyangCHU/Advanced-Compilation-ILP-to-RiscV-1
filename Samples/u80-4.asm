// Routine main
la t6, L_str_0
mv t0, t6
mv a0, t0
call print
mv t7, a0
li t8, 0
la t9, L_str_1
mv t1, t9
mv t2, t1
la t10, L_str_2
mv t3, t10
mv a0, t2
mv a1, t3
call concat
mv t11, a0
mv t4, t11
mv t5, t4
mv a0, t5
call print
mv t12, a0
