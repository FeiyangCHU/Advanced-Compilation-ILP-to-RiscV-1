// Routine main
li t14, 5
mv t1, t14
L1:
li t15, 53
blt t1, t15, L4
j L13
L13:
j L5
L4:
li t16, 1
mv t3, t16
j L6
L5:
li t17, 0
mv t3, t17
L6:
mv t2, t3
li t18, 0
beq t2, t18, L3
j L2
L2:
mv t0, t1
mv a0, t0
call string_of_int
mv t19, a0
mv t9, t19
mv t10, t9
mv a0, t10
call print
mv t20, a0
li t21, 0
li t22, 2
mul t23, t22, t1
mv t1, t23
L7:
li t24, 53
blt t24, t1, L10
j L14
L14:
j L11
L10:
li t25, 1
mv t6, t25
j L12
L11:
li t26, 0
mv t6, t26
L12:
mv t5, t6
li t27, 0
beq t5, t27, L9
j L8
L8:
mv t11, t1
mv a0, t11
call string_of_int
mv t28, a0
mv t12, t28
mv t13, t12
mv a0, t13
call print
mv t29, a0
li t30, 0
li t31, 3
sub t32, t1, t31
mv t1, t32
mv t7, t1
j L7
L9:
li t33, 0
mv t4, t33
j L1
L3:
li t34, 0
