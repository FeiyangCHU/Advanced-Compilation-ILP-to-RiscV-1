// Routine L1
mv i0, a0
li t19, 1
add t20, i0, t19
mv t1, t20
mv rv, t1
// Routine L2
mv i0, a0
mv t0, i0
li t21, 1
mv t3, t21
mv a0, t3
call string_of_int
mv t22, a0
mv t4, t22
mv t5, t4
mv a0, t0
mv a1, t5
call concat
mv t23, a0
mv t2, t23
mv rv, t2
// Routine main
la t24, L_str_0
mv t6, t24
li t25, 2
mv t7, t25
mv a0, t7
call L1
mv t26, a0
mv t8, t26
mv t9, t8
mv a0, t9
call string_of_int
mv t27, a0
mv t10, t27
mv t11, t10
mv a0, t6
mv a1, t11
call concat
mv t28, a0
mv t12, t28
mv t13, t12
la t29, L_str_1
mv t14, t29
mv a0, t14
call L2
mv t30, a0
mv t15, t30
mv t16, t15
mv a0, t13
mv a1, t16
call concat
mv t31, a0
mv t17, t31
mv t18, t17
mv a0, t18
call print
mv t32, a0
