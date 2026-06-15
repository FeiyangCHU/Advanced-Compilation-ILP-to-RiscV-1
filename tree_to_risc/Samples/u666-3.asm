// Routine L1
mv i0, a0
li t10, 0
beq i0, t10, L5
j L8
L8:
j L6
L5:
li t11, 1
mv t2, t11
j L7
L6:
li t12, 0
mv t2, t12
L7:
li t13, 0
bne t2, t13, L2
j L9
L9:
j L3
L2:
li t14, 1
mv t1, t14
j L4
L3:
mv t9, i0
li t15, 1
sub t16, i0, t15
mv t0, t16
mv a0, t0
call L1
mv t17, a0
mv t3, t17
mul t18, t9, t3
mv t1, t18
L4:
mv rv, t1
// Routine main
li t19, 5
mv t4, t19
mv a0, t4
call L1
mv t20, a0
mv t5, t20
mv t6, t5
mv a0, t6
call string_of_int
mv t21, a0
mv t7, t21
mv t8, t7
mv a0, t8
call print
mv t22, a0
