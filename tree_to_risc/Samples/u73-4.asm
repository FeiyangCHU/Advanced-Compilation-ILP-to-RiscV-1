// Routine L1
mv i0, a0
li t11, 2
mul t12, t11, i0
mv rv, t12
// Routine L2
mv i0, a0
mv t0, i0
mv a0, t0
call L1
mv t13, a0
mv t1, t13
mv t2, t1
mv a0, t2
call L1
mv t14, a0
mv rv, t14
// Routine L3
mv i0, a0
mv t3, i0
mv a0, t3
call L1
mv t15, a0
mv t4, t15
mv t5, t4
mv t6, i0
mv t7, i0
mv a0, t6
mv a1, t7
call L2
mv t16, a0
mv t8, t16
mv t9, t8
mv a0, t5
mv a1, t9
call L2
mv t17, a0
mv rv, t17
// Routine main
li t18, 73
mv t10, t18
mv a0, t10
call L3
