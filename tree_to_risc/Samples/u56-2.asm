// Routine L1
mv i0, a0
li t12, 0
beq i0, t12, L6
j L27
L27:
j L7
L6:
li t13, 1
mv t2, t13
j L8
L7:
li t14, 0
mv t2, t14
L8:
li t15, 0
bne t2, t15, L3
j L28
L28:
j L4
L3:
li t16, 1
mv t1, t16
j L5
L4:
li t17, 1
beq i0, t17, L12
j L29
L29:
j L13
L12:
li t18, 1
mv t4, t18
j L14
L13:
li t19, 0
mv t4, t19
L14:
li t20, 0
bne t4, t20, L9
j L30
L30:
j L10
L9:
li t21, 0
mv t3, t21
j L11
L10:
li t22, 1
sub t23, i0, t22
mv t0, t23
mv a0, t0
call L2
mv t24, a0
li t25, 1
mv t3, t25
L11:
mv t1, t3
L5:
mv rv, t1
// Routine L2
mv i0, a0
li t26, 0
beq i0, t26, L18
j L31
L31:
j L19
L18:
li t27, 1
mv t6, t27
j L20
L19:
li t28, 0
mv t6, t28
L20:
li t29, 0
bne t6, t29, L15
j L32
L32:
j L16
L15:
li t30, 0
mv t5, t30
j L17
L16:
li t31, 1
beq i0, t31, L24
j L33
L33:
j L25
L24:
li t32, 1
mv t8, t32
j L26
L25:
li t33, 0
mv t8, t33
L26:
li t34, 0
bne t8, t34, L21
j L34
L34:
j L22
L21:
li t35, 1
mv t7, t35
j L23
L22:
li t36, 1
sub t37, i0, t36
mv t9, t37
mv a0, t9
call L1
mv t38, a0
mv t7, t38
L23:
mv t5, t7
L17:
mv rv, t5
// Routine main
li t39, 56
mv t10, t39
mv a0, t10
call L2
mv t40, a0
mv t11, t40
li t41, 1
