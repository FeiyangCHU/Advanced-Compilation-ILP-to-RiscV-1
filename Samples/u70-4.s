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
li s1, 1
li s2, 1
beq s1, s2, L7
j L10
L10:
j L8
L7:
li s1, 1
mv s1, s1
j L9
L8:
li s1, 0
mv s1, s1
L9:
li s2, 0
beq s1, s2, L5
j L4
L4:
li s1, 1
mv s1, s1
j L6
L5:
li s1, 0
mv s1, s1
L6:
mv s2, s1
li s1, 0
beq s2, s1, L2
j L1
L1:
li s1, 3
mv s1, s1
j L3
L2:
li s1, 4
mv s1, s1
L3:
ld ra, 0(sp)
ld s1, 8(sp)
ld s2, 16(sp)
addi sp, sp, 32
ret
# -------- End of function main --------
