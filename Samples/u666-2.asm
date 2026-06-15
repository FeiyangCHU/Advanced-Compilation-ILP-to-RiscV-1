// Routine L1
mv i0, a0
li t8, 0
beq i0, t8, L5
j L8
L8:
j L6
L5:
li t9, 1
mv t4, t9
j L7
L6:
li t10, 0
mv t4, t10
L7:
mv t3, t4
li t11, 0
beq t3, t11, L3
j L2
L2:
li t12, 1
mv t2, t12
j L4
L3:
mv t7, i0
li t13, 1
sub t14, i0, t13
mv t0, t14
mv a0, t0
call L1
mv t15, a0
mv t5, t15
mul t16, t7, t5
mv t2, t16
L4:
mv t1, t2
mv rv, t1
// Routine main
li t17, 5
mv t6, t17
mv a0, t6
call L1
