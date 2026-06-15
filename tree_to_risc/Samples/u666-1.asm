// Routine L1
mv i0, a0
li t4, 0
beq i0, t4, L5
j L8
L8:
j L6
L5:
li t5, 1
mv t2, t5
j L7
L6:
li t6, 0
mv t2, t6
L7:
li t7, 0
bne t2, t7, L2
j L9
L9:
j L3
L2:
li t8, 1
mv t1, t8
j L4
L3:
li t9, 1
sub t10, i0, t9
mv t0, t10
mv a0, t0
call L1
mv t11, a0
mv t1, t11
L4:
mv rv, t1
// Routine main
li t12, 5
mv t3, t12
mv a0, t3
call L1
