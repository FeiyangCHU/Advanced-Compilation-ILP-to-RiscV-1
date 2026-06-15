// Routine L1
mv i0, a0
mv t0, i0
mv a0, t0
call L4
mv t19, a0
mv t4, t19
mv t5, t4
mv a0, t5
call L2
mv t20, a0
mv t6, t20
mv t7, t6
mv a0, t7
call L4
mv t21, a0
mv rv, t21
// Routine L2
mv i0, a0
li t22, 74
blt i0, t22, L8
j L11
L11:
j L9
L8:
li t23, 1
mv t3, t23
j L10
L9:
li t24, 0
mv t3, t24
L10:
li t25, 0
beq t3, t25, L6
j L5
L5:
li t26, 2
mul t27, t26, i0
mv t2, t27
j L7
L6:
mv t2, i0
L7:
mv t1, t2
mv rv, t1
// Routine L3
mv i0, a0
mv t8, i0
mv a0, t8
call L2
mv t28, a0
mv t9, t28
mv t10, t9
mv a0, t10
call L2
mv t29, a0
mv rv, t29
// Routine L4
mv i0, a0
mv t11, i0
mv a0, t11
call L2
mv t30, a0
mv t12, t30
mv t13, t12
mv t14, i0
mv t15, i0
mv a0, t14
mv a1, t15
call L3
mv t31, a0
mv t16, t31
mv t17, t16
mv a0, t13
mv a1, t17
call L3
mv t32, a0
mv rv, t32
// Routine main
li t33, 74
mv t18, t33
mv a0, t18
call L1
