// Routine L1
mv i0, a0
mv t0, i0
mv a0, t0
call L4
mv t18, a0
mv t3, t18
mv t4, t3
mv a0, t4
call L2
mv t19, a0
mv t5, t19
mv t6, t5
mv a0, t6
call L4
mv t20, a0
mv rv, t20
// Routine L2
mv i0, a0
li t21, 74
blt i0, t21, L8
j L11
L11:
j L9
L8:
li t22, 1
mv t2, t22
j L10
L9:
li t23, 0
mv t2, t23
L10:
li t24, 0
bne t2, t24, L5
j L12
L12:
j L6
L5:
li t25, 2
mul t26, t25, i0
mv t1, t26
j L7
L6:
mv t1, i0
L7:
mv rv, t1
// Routine L3
mv i0, a0
mv t7, i0
mv a0, t7
call L2
mv t27, a0
mv t8, t27
mv t9, t8
mv a0, t9
call L2
mv t28, a0
mv rv, t28
// Routine L4
mv i0, a0
mv t10, i0
mv a0, t10
call L2
mv t29, a0
mv t11, t29
mv t12, t11
mv t13, i0
mv t14, i0
mv a0, t13
mv a1, t14
call L3
mv t30, a0
mv t15, t30
mv t16, t15
mv a0, t12
mv a1, t16
call L3
mv t31, a0
mv rv, t31
// Routine main
li t32, 74
mv t17, t32
mv a0, t17
call L1
