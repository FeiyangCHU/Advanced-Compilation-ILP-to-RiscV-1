// Routine L1
mv i0, a0
li t12, 0
beq i0, t12, L5
j L8
L8:
j L6
L5:
li t13, 1
mv t4, t13
j L7
L6:
li t14, 0
mv t4, t14
L7:
mv t3, t4
li t15, 0
beq t3, t15, L3
j L2
L2:
li t16, 1
mv t2, t16
j L4
L3:
mv t11, i0
li t17, 1
sub t18, i0, t17
mv t0, t18
mv a0, t0
call L1
mv t19, a0
mv t5, t19
mul t20, t11, t5
mv t2, t20
L4:
mv t1, t2
mv rv, t1
// Routine main
li t21, 5
mv t6, t21
mv a0, t6
call L1
mv t22, a0
mv t7, t22
mv t8, t7
mv a0, t8
call string_of_int
mv t23, a0
mv t9, t23
mv t10, t9
mv a0, t10
call print
mv t24, a0
