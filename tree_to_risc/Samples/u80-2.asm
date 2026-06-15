// Routine L1
mv i0, a0
li t17, 1
add t18, i0, t17
mv rv, t18
// Routine L2
mv i0, a0
mv t0, i0
li t19, 1
mv t1, t19
mv a0, t1
call string_of_int
mv t20, a0
mv t2, t20
mv t3, t2
mv a0, t0
mv a1, t3
call concat
mv t21, a0
mv rv, t21
// Routine main
la t22, L_str_0
mv t4, t22
li t23, 2
mv t5, t23
mv a0, t5
call L1
mv t24, a0
mv t6, t24
mv t7, t6
mv a0, t7
call string_of_int
mv t25, a0
mv t8, t25
mv t9, t8
mv a0, t4
mv a1, t9
call concat
mv t26, a0
mv t10, t26
mv t11, t10
la t27, L_str_1
mv t12, t27
mv a0, t12
call L2
mv t28, a0
mv t13, t28
mv t14, t13
mv a0, t11
mv a1, t14
call concat
mv t29, a0
mv t15, t29
mv t16, t15
mv a0, t16
call print
mv t30, a0
