// Routine L1
mv i0, a0
li t6, 0
beq i0, t6, L5
j L8
L8:
j L6
L5:
li t7, 1
mv t2, t7
j L7
L6:
li t8, 0
mv t2, t8
L7:
li t9, 0
bne t2, t9, L2
j L9
L9:
j L3
L2:
li t10, 1
mv t1, t10
j L4
L3:
mv t5, i0
li t11, 1
sub t12, i0, t11
mv t0, t12
mv a0, t0
call L1
mv t13, a0
mv t3, t13
mul t14, t5, t3
mv t1, t14
L4:
mv rv, t1
// Routine main
li t15, 5
mv t4, t15
mv a0, t4
call L1
