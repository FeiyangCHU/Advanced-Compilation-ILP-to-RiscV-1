// Routine L1
mv i0, a0
add t13, i0, i0
mv t1, t13
mv rv, t1
// Routine L2
mv i0, a0
mv t0, i0
mv t4, i0
mv a0, t0
mv a1, t4
call concat
mv t14, a0
mv t2, t14
mv rv, t2
// Routine main
la t15, L_str_0
mv t5, t15
mv a0, t5
call L2
mv t16, a0
mv t6, t16
mv t7, t6
mv a0, t7
call print
mv t17, a0
li t18, 0
li t19, 2
mv t8, t19
mv a0, t8
call L1
mv t20, a0
mv t9, t20
mv t10, t9
mv a0, t10
call string_of_int
mv t21, a0
mv t11, t21
mv t12, t11
mv a0, t12
call print
mv t22, a0
li t23, 0
