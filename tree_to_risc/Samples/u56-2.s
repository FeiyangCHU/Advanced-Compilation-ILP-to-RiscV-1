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
addi sp, sp, -32
sd ra, 0(sp)
sd s1, 8(sp)
sd s2, 16(sp)
sd s3, 24(sp)
mv s2, a0
li s1, 0
beq s2, s1, L6
j L27
L27:
j L7
L6:
li s1, 1
mv s3, s1
j L8
L7:
li s1, 0
mv s3, s1
L8:
li s1, 0
bne s3, s1, L3
j L28
L28:
j L4
L3:
li s1, 1
mv s1, s1
j L5
L4:
li s1, 1
beq s2, s1, L12
j L29
L29:
j L13
L12:
li s1, 1
mv s1, s1
j L14
L13:
li s1, 0
mv s1, s1
L14:
li s3, 0
bne s1, s3, L9
j L30
L30:
j L10
L9:
li s1, 0
mv s1, s1
j L11
L10:
li s1, 1
sub s1, s2, s1
mv s1, s1
mv a0, s1
call L2
mv s1, a0
li s1, 1
mv s1, s1
L11:
mv s1, s1
L5:
mv a0, s1
ld ra, 0(sp)
ld s1, 8(sp)
ld s2, 16(sp)
ld s3, 24(sp)
addi sp, sp, 32
ret
# -------- End of function L1 --------

# -------- Function L2 --------
L2:
addi sp, sp, -32
sd ra, 0(sp)
sd s1, 8(sp)
sd s2, 16(sp)
sd s3, 24(sp)
mv s2, a0
li s1, 0
beq s2, s1, L18
j L31
L31:
j L19
L18:
li s1, 1
mv s1, s1
j L20
L19:
li s1, 0
mv s1, s1
L20:
li s3, 0
bne s1, s3, L15
j L32
L32:
j L16
L15:
li s1, 0
mv s1, s1
j L17
L16:
li s1, 1
beq s2, s1, L24
j L33
L33:
j L25
L24:
li s1, 1
mv s3, s1
j L26
L25:
li s1, 0
mv s3, s1
L26:
li s1, 0
bne s3, s1, L21
j L34
L34:
j L22
L21:
li s1, 1
mv s1, s1
j L23
L22:
li s1, 1
sub s1, s2, s1
mv s1, s1
mv a0, s1
call L1
mv s1, a0
mv s1, s1
L23:
mv s1, s1
L17:
mv a0, s1
ld ra, 0(sp)
ld s1, 8(sp)
ld s2, 16(sp)
ld s3, 24(sp)
addi sp, sp, 32
ret
# -------- End of function L2 --------

# -------- Function main --------
ILPmain:
addi sp, sp, -32
sd ra, 0(sp)
sd s1, 8(sp)
sd s2, 16(sp)
li s1, 56
mv s1, s1
mv a0, s1
call L2
mv s1, a0
mv s2, s1
li s1, 1
xor s1, s2, s1
ld ra, 0(sp)
ld s1, 8(sp)
ld s2, 16(sp)
addi sp, sp, 32
ret
# -------- End of function main --------
