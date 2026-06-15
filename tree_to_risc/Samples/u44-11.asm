// Routine main
la t24, L_str_0
mv t12, t24
la t25, L_str_1
mv t13, t25
mv a0, t12
mv a1, t13
call strcmp
mv t26, a0
mv t14, t26
li t27, 0
blt t14, t27, L4
j L25
L25:
j L5
L4:
li t28, 1
mv t2, t28
j L6
L5:
li t29, 0
mv t2, t29
L6:
li t30, 0
bne t2, t30, L1
j L26
L26:
j L2
L1:
la t31, L_str_2
mv t1, t31
j L3
L2:
la t32, L_str_3
mv t1, t32
L3:
mv t15, t1
mv a0, t15
call print
mv t33, a0
li t34, 0
la t35, L_str_0
mv t16, t35
la t36, L_str_1
mv t17, t36
mv a0, t16
mv a1, t17
call strcmp
mv t37, a0
mv t18, t37
li t38, 0
bge t38, t18, L10
j L27
L27:
j L11
L10:
li t39, 1
mv t4, t39
j L12
L11:
li t40, 0
mv t4, t40
L12:
li t41, 0
bne t4, t41, L7
j L28
L28:
j L8
L7:
la t42, L_str_2
mv t3, t42
j L9
L8:
la t43, L_str_3
mv t3, t43
L9:
mv t19, t3
mv a0, t19
call print
mv t44, a0
li t45, 0
la t46, L_str_0
mv t20, t46
la t47, L_str_1
mv t21, t47
mv a0, t20
mv a1, t21
call strcmp
mv t48, a0
mv t22, t48
li t49, 0
blt t49, t22, L16
j L29
L29:
j L17
L16:
li t50, 1
mv t6, t50
j L18
L17:
li t51, 0
mv t6, t51
L18:
li t52, 0
bne t6, t52, L13
j L30
L30:
j L14
L13:
la t53, L_str_2
mv t5, t53
j L15
L14:
la t54, L_str_3
mv t5, t54
L15:
mv t23, t5
mv a0, t23
call print
mv t55, a0
li t56, 0
la t57, L_str_0
mv t0, t57
la t58, L_str_1
mv t9, t58
mv a0, t0
mv a1, t9
call strcmp
mv t59, a0
mv t10, t59
li t60, 0
bge t10, t60, L22
j L31
L31:
j L23
L22:
li t61, 1
mv t8, t61
j L24
L23:
li t62, 0
mv t8, t62
L24:
li t63, 0
bne t8, t63, L19
j L32
L32:
j L20
L19:
la t64, L_str_2
mv t7, t64
j L21
L20:
la t65, L_str_3
mv t7, t65
L21:
mv t11, t7
mv a0, t11
call print
mv t66, a0
