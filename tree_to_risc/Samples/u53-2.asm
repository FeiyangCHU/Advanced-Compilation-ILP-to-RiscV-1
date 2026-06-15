// Routine main
li t9, 5
mv t1, t9
L1:
li t10, 53
blt t1, t10, L4
j L13
L13:
j L5
L4:
li t11, 1
mv t2, t11
j L6
L5:
li t12, 0
mv t2, t12
L6:
li t13, 0
bne t2, t13, L2
j L14
L14:
j L3
L2:
mv t6, t1
mv a0, t6
call string_of_int
mv t14, a0
mv t7, t14
mv t8, t7
mv a0, t8
call print
mv t15, a0
li t16, 0
li t17, 2
mul t18, t17, t1
mv t1, t18
L7:
li t19, 53
blt t19, t1, L10
j L15
L15:
j L11
L10:
li t20, 1
mv t3, t20
j L12
L11:
li t21, 0
mv t3, t21
L12:
li t22, 0
bne t3, t22, L8
j L16
L16:
j L9
L8:
mv t0, t1
mv a0, t0
call string_of_int
mv t23, a0
mv t4, t23
mv t5, t4
mv a0, t5
call print
mv t24, a0
li t25, 0
li t26, 3
sub t27, t1, t26
mv t1, t27
j L7
L9:
li t28, 0
j L1
L3:
