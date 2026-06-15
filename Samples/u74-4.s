.section .rodata
L_str_0:
	.string "true"
L_str_1:
	.string "false"
.text
.globl main
main:
  addi sp, sp, -16
  sd ra, 8(sp)
  # Call ILPmain
  jal ra, ILPmain
  li a0, 0
  ld ra, 8(sp)
  addi sp, sp, 16
  ret

# -------- Function L1 --------
L1:
addi sp, sp, -16
sd ra, 0(sp)
sd s1, 8(sp)
mv s1, a0
mv s1, s1
mv a0, s1
call L4
mv s1, a0
mv s1, s1
mv s1, s1
mv a0, s1
call L2
mv s1, a0
mv s1, s1
mv s1, s1
mv a0, s1
call L4
mv s1, a0
mv a0, s1
ld ra, 0(sp)
ld s1, 8(sp)
addi sp, sp, 16
ret
# -------- End of function L1 --------

# -------- Function L2 --------
L2:
addi sp, sp, -32
sd ra, 0(sp)
sd s1, 8(sp)
sd s2, 16(sp)
sd s3, 24(sp)
mv s3, a0
li s1, 74
blt s3, s1, L8
j L11
L11:
j L9
L8:
li s1, 1
mv s1, s1
j L10
L9:
li s1, 0
mv s1, s1
L10:
li s2, 0
beq s1, s2, L6
j L5
L5:
li s1, 2
mul s1, s1, s3
mv s1, s1
j L7
L6:
mv s1, s3
L7:
mv s1, s1
mv a0, s1
ld ra, 0(sp)
ld s1, 8(sp)
ld s2, 16(sp)
ld s3, 24(sp)
addi sp, sp, 32
ret
# -------- End of function L2 --------

# -------- Function L3 --------
L3:
addi sp, sp, -16
sd ra, 0(sp)
sd s1, 8(sp)
mv s1, a0
mv s1, s1
mv a0, s1
call L2
mv s1, a0
mv s1, s1
mv s1, s1
mv a0, s1
call L2
mv s1, a0
mv a0, s1
ld ra, 0(sp)
ld s1, 8(sp)
addi sp, sp, 16
ret
# -------- End of function L3 --------

# -------- Function L4 --------
L4:
addi sp, sp, -32
sd ra, 0(sp)
sd s1, 8(sp)
sd s2, 16(sp)
sd s3, 24(sp)
mv s2, a0
mv s1, s2
mv a0, s1
call L2
mv s1, a0
mv s1, s1
mv s3, s1
mv s2, s2
mv s1, s2
mv a0, s2
mv a1, s1
call L3
mv s1, a0
mv s1, s1
mv s1, s1
mv a0, s3
mv a1, s1
call L3
mv s1, a0
mv a0, s1
ld ra, 0(sp)
ld s1, 8(sp)
ld s2, 16(sp)
ld s3, 24(sp)
addi sp, sp, 32
ret
# -------- End of function L4 --------

# -------- Function main --------
ILPmain:
addi sp, sp, -16
sd ra, 0(sp)
sd s1, 8(sp)
li s1, 74
mv s1, s1
mv a0, s1
call L1
mv s1, a0
ld ra, 0(sp)
ld s1, 8(sp)
addi sp, sp, 16
ret
# -------- End of function main --------
