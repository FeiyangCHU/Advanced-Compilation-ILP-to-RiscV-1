// Routine L1
mv i0, a0
li t12, 2
mul t13, t12, i0
mv t1, t13
mv rv, t1
// Routine L2
mv i0, a0
mv t0, i0
mv a0, t0
call L1
mv t14, a0
mv t2, t14
mv t3, t2
mv a0, t3
call L1
mv t15, a0
mv rv, t15
// Routine L3
mv i0, a0
mv t4, i0
mv a0, t4
call L1
mv t16, a0
mv t5, t16
mv t6, t5
mv t7, i0
mv t8, i0
mv a0, t7
mv a1, t8
call L2
mv t17, a0
mv t9, t17
mv t10, t9
mv a0, t6
mv a1, t10
call L2
mv t18, a0
mv rv, t18
// Routine main
li t19, 73
mv t11, t19
mv a0, t11
call L3
