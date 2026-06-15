// Routine main
li t5, 5
mv t1, t5
L1:
li t6, 42
blt t1, t6, L4
j L7
L7:
j L5
L4:
li t7, 1
mv t2, t7
j L6
L5:
li t8, 0
mv t2, t8
L6:
li t9, 0
bne t2, t9, L2
j L8
L8:
j L3
L2:
li t10, 1
add t11, t1, t10
mv t1, t11
j L1
L3:
li t12, 0
mv t0, t1
mv a0, t0
call string_of_int
mv t13, a0
mv t3, t13
mv t4, t3
mv a0, t4
call print
mv t14, a0
