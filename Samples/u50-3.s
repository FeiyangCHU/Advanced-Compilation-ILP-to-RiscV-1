.section .rodata
L_str_0:
	.string "true"
L_str_1:
	.string "false"
L_str_2:
	.string "*"
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
li s2, 1
li s1, 0
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
mv s1, s1
li s2, 0
beq s1, s2, L2
j L1
L1:
la s1, L_str_0
mv s1, s1
j L3
L2:
la s1, L_str_1
mv s1, s1
L3:
mv s2, s1
la s1, L_str_2
mv s1, s1
mv a0, s2
mv a1, s1
call concat
mv s1, a0
ld ra, 0(sp)
ld s1, 8(sp)
ld s2, 16(sp)
addi sp, sp, 32
ret
# -------- End of function main --------
