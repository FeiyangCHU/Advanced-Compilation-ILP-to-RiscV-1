// Routine L1
mv i0, a0
li t15, 0
beq i0, t15, L6
j L30
L30:
j L7
L6:
li t16, 1
mv t3, t16
j L8
L7:
li t17, 0
mv t3, t17
L8:
li t18, 0
beq t3, t18, L4
j L3
L3:
li t19, 1
mv t2, t19
j L5
L4:
li t20, 1
beq i0, t20, L12
j L31
L31:
j L13
L12:
li t21, 1
mv t5, t21
j L14
L13:
li t22, 0
mv t5, t22
L14:
li t23, 0
beq t5, t23, L10
j L9
L9:
li t24, 0
mv t4, t24
j L11
L10:
li t25, 1
sub t26, i0, t25
mv t0, t26
mv a0, t0
call L2
mv t27, a0
mv t4, t27
L11:
mv t2, t4
L5:
mv t1, t2
mv rv, t1
// Routine L2
mv i0, a0
li t28, 0
beq i0, t28, L18
j L32
L32:
j L19
L18:
li t29, 1
mv t8, t29
j L20
L19:
li t30, 0
mv t8, t30
L20:
li t31, 0
beq t8, t31, L16
j L15
L15:
li t32, 0
mv t7, t32
j L17
L16:
li t33, 1
beq i0, t33, L24
j L33
L33:
j L25
L24:
li t34, 1
mv t10, t34
j L26
L25:
li t35, 0
mv t10, t35
L26:
li t36, 0
beq t10, t36, L22
j L21
L21:
li t37, 1
mv t9, t37
j L23
L22:
li t38, 1
sub t39, i0, t38
mv t12, t39
mv a0, t12
call L1
mv t40, a0
mv t9, t40
L23:
mv t7, t9
L17:
mv t6, t7
mv rv, t6
// Routine main
li t41, 56
mv t13, t41
mv a0, t13
call L2
mv t42, a0
mv t14, t42
li t43, 0
beq t14, t43, L27
j L34
L34:
j L28
L27:
li t44, 1
mv t11, t44
j L29
L28:
li t45, 0
mv t11, t45
