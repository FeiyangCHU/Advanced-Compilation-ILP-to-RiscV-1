// Routine main
la t25, L_str_0
mv t0, t25
la t26, L_str_1
mv t14, t26
mv a0, t0
mv a1, t14
call strcmp
mv t27, a0
mv t2, t27
li t28, 0
blt t2, t28, L4
j L25
L25:
j L5
L4:
li t29, 1
mv t3, t29
j L6
L5:
li t30, 0
mv t3, t30
L6:
li t31, 0
bne t3, t31, L1
j L26
L26:
j L2
L1:
la t32, L_str_2
mv t1, t32
j L3
L2:
la t33, L_str_3
mv t1, t33
L3:
mv t15, t1
mv a0, t15
call print
mv t34, a0
li t35, 0
la t36, L_str_0
mv t16, t36
la t37, L_str_1
mv t17, t37
mv a0, t16
mv a1, t17
call strcmp
mv t38, a0
mv t5, t38
li t39, 0
bge t39, t5, L10
j L27
L27:
j L11
L10:
li t40, 1
mv t6, t40
j L12
L11:
li t41, 0
mv t6, t41
L12:
li t42, 0
bne t6, t42, L7
j L28
L28:
j L8
L7:
la t43, L_str_2
mv t4, t43
j L9
L8:
la t44, L_str_3
mv t4, t44
L9:
mv t18, t4
mv a0, t18
call print
mv t45, a0
li t46, 0
la t47, L_str_0
mv t19, t47
la t48, L_str_1
mv t20, t48
mv a0, t19
mv a1, t20
call strcmp
mv t49, a0
mv t8, t49
li t50, 0
blt t50, t8, L16
j L29
L29:
j L17
L16:
li t51, 1
mv t9, t51
j L18
L17:
li t52, 0
mv t9, t52
L18:
li t53, 0
bne t9, t53, L13
j L30
L30:
j L14
L13:
la t54, L_str_2
mv t7, t54
j L15
L14:
la t55, L_str_3
mv t7, t55
L15:
mv t21, t7
mv a0, t21
call print
mv t56, a0
li t57, 0
la t58, L_str_0
mv t22, t58
la t59, L_str_1
mv t23, t59
mv a0, t22
mv a1, t23
call strcmp
mv t60, a0
mv t12, t60
li t61, 0
bge t12, t61, L22
j L31
L31:
j L23
L22:
li t62, 1
mv t13, t62
j L24
L23:
li t63, 0
mv t13, t63
L24:
li t64, 0
bne t13, t64, L19
j L32
L32:
j L20
L19:
la t65, L_str_2
mv t11, t65
j L21
L20:
la t66, L_str_3
mv t11, t66
L21:
mv t24, t11
mv a0, t24
call print
mv t67, a0
li t68, 0
