// Routine main
li t9, 1
li t12, 0
blt t12, t9, L4
j L19
L19:
j L5
L4:
li t14, 1
mv t2, t14
j L6
L5:
li t15, 0
mv t2, t15
L6:
li t16, 0
bne t2, t16, L1
j L20
L20:
j L2
L1:
la t17, L_str_0
mv t1, t17
j L3
L2:
la t18, L_str_1
mv t1, t18
L3:
mv t0, t1
mv a0, t0
call print
mv t19, a0
li t20, 0
li t21, 1
mv t8, t21
mv a0, t8
call float_of_int
fmv.s f22, fa0
fmv.s f9, f22
la t23, L_float_0
flw f24, 0(t23)
flt.s t25, f24, f9
bnez t25, L10
j L21
L21:
j L11
L10:
li t26, 1
mv t4, t26
j L12
L11:
li t27, 0
mv t4, t27
L12:
li t28, 0
bne t4, t28, L7
j L22
L22:
j L8
L7:
la t29, L_str_0
mv t3, t29
j L9
L8:
la t30, L_str_1
mv t3, t30
L9:
mv t10, t3
mv a0, t10
call print
mv t31, a0
li t32, 0
li t33, 0
mv t11, t33
mv a0, t11
call float_of_int
fmv.s f34, fa0
fmv.s f12, f34
la t35, L_float_1
flw f36, 0(t35)
flt.s t37, f12, f36
bnez t37, L16
j L23
L23:
j L17
L16:
li t38, 1
mv t7, t38
j L18
L17:
li t39, 0
mv t7, t39
L18:
li t40, 0
bne t7, t40, L13
j L24
L24:
j L14
L13:
la t41, L_str_0
mv t6, t41
j L15
L14:
la t42, L_str_1
mv t6, t42
L15:
mv t13, t6
mv a0, t13
call print
mv t43, a0
li t44, 0
