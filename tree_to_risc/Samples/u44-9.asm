// Routine main
li t10, 1
li t12, 0
blt t12, t10, L4
j L19
L19:
j L5
L4:
li t13, 1
mv t2, t13
j L6
L5:
li t14, 0
mv t2, t14
L6:
li t15, 0
bne t2, t15, L1
j L20
L20:
j L2
L1:
la t16, L_str_0
mv t1, t16
j L3
L2:
la t17, L_str_1
mv t1, t17
L3:
mv t8, t1
mv a0, t8
call print
mv t18, a0
li t19, 0
li t20, 1
mv t9, t20
mv a0, t9
call float_of_int
fmv.s f21, fa0
fmv.s f10, f21
la t22, L_float_0
flw f23, 0(t22)
flt.s t24, f23, f10
bnez t24, L10
j L21
L21:
j L11
L10:
li t25, 1
mv t4, t25
j L12
L11:
li t26, 0
mv t4, t26
L12:
li t27, 0
bne t4, t27, L7
j L22
L22:
j L8
L7:
la t28, L_str_0
mv t3, t28
j L9
L8:
la t29, L_str_1
mv t3, t29
L9:
mv t11, t3
mv a0, t11
call print
mv t30, a0
li t31, 0
li t32, 0
mv t0, t32
mv a0, t0
call float_of_int
fmv.s f33, fa0
fmv.s f1, f33
la t34, L_float_1
flw f35, 0(t34)
flt.s t36, f1, f35
bnez t36, L16
j L23
L23:
j L17
L16:
li t37, 1
mv t6, t37
j L18
L17:
li t38, 0
mv t6, t38
L18:
li t39, 0
bne t6, t39, L13
j L24
L24:
j L14
L13:
la t40, L_str_0
mv t5, t40
j L15
L14:
la t41, L_str_1
mv t5, t41
L15:
mv t7, t5
mv a0, t7
call print
mv t42, a0
