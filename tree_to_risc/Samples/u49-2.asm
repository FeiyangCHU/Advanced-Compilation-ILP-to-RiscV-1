// Routine main
li t5, 1
li t6, 0
bge t5, t6, L1
j L4
L4:
j L2
L1:
li t7, 1
mv t1, t7
j L3
L2:
li t8, 0
mv t1, t8
L3:
mv t0, t1
mv a0, t0
call string_of_int
mv t9, a0
mv t2, t9
mv t3, t2
la t10, L_str_0
mv t4, t10
mv a0, t3
mv a1, t4
call concat
