// Routine main
li t7, 5
mv t1, t7
L1:
li t8, 42
blt t1, t8, L4
j L7
L7:
j L5
L4:
li t9, 1
mv t2, t9
j L6
L5:
li t10, 0
mv t2, t10
L6:
li t11, 0
beq t2, t11, L3
j L2
L2:
li t12, 1
add t13, t1, t12
mv t1, t13
mv t3, t1
j L1
L3:
li t14, 0
mv t4, t1
mv t0, t4
mv a0, t0
call string_of_int
mv t15, a0
mv t5, t15
mv t6, t5
mv a0, t6
call print
mv t16, a0
