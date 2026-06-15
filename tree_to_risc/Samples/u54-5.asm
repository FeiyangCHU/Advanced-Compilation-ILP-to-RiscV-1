// Routine L1
mv i0, a0
add t10, i0, i0
mv rv, t10
// Routine L2
mv i0, a0
mv t0, i0
mv t1, i0
mv a0, t0
mv a1, t1
call concat
mv t11, a0
mv rv, t11
// Routine main
la t12, L_str_0
mv t7, t12
mv a0, t7
call L2
mv t13, a0
mv t8, t13
mv t9, t8
mv a0, t9
call print
mv t14, a0
li t15, 0
li t16, 2
mv t2, t16
mv a0, t2
call L1
mv t17, a0
mv t3, t17
mv t4, t3
mv a0, t4
call string_of_int
mv t18, a0
mv t5, t18
mv t6, t5
mv a0, t6
call print
mv t19, a0
