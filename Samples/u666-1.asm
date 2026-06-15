// Routine L1
mv i0, a0
li t6, 0
beq i0, t6, L5
j L8
L8:
j L6
L5:
li t7, 1
mv t4, t7
j L7
L6:
li t8, 0
mv t4, t8
L7:
mv t3, t4
li t9, 0
beq t3, t9, L3
j L2
L2:
li t10, 1
mv t2, t10
j L4
L3:
li t11, 1
sub t12, i0, t11
mv t0, t12
mv a0, t0
call L1
mv t13, a0
mv t2, t13
L4:
mv t1, t2
mv rv, t1
// Routine main
li t14, 5
mv t5, t14
mv a0, t5
call L1
