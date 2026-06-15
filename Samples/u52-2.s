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

# -------- Function main --------
ILPmain:
addi sp, sp, -32
sd ra, 0(sp)
sd s1, 8(sp)
sd s2, 16(sp)
sd s3, 24(sp)
li s1, 50
mv s2, s1
L1:
li s1, 52
blt s2, s1, L4
j L7
L7:
j L5
L4:
li s1, 1
mv s1, s1
j L6
L5:
li s1, 0
mv s1, s1
L6:
li s3, 0
beq s1, s3, L3
j L2
L2:
li s1, 1
add s1, s2, s1
mv s2, s1
mv s1, s2
j L1
L3:
li s1, 0
mv s1, s2
ld ra, 0(sp)
ld s1, 8(sp)
ld s2, 16(sp)
ld s3, 24(sp)
addi sp, sp, 32
ret
# -------- End of function main --------
