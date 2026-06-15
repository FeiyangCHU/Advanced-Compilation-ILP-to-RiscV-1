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
addi sp, sp, -32
sd ra, 0(sp)
sd s1, 8(sp)
sd s2, 16(sp)
mv s2, a0
mv s1, a1
add s1, s2, s1
mv s1, s1
mv a0, s1
ld ra, 0(sp)
ld s1, 8(sp)
ld s2, 16(sp)
addi sp, sp, 32
ret
# -------- End of function L1 --------

# -------- Function main --------
ILPmain:
addi sp, sp, -32
sd ra, 0(sp)
sd s1, 8(sp)
sd s2, 16(sp)
li s2, 1
li s1, 0
beq s2, s1, L3
j L2
L2:
li s1, 8
mv s1, s1
j L4
L3:
li s1, 1
mv s1, s1
L4:
mv s1, s1
mv s2, s1
li s1, 8
mv s1, s1
mul s1, s1, s1
mv s1, s1
mv s1, s1
mv a0, s2
mv a1, s1
call L1
mv s1, a0
ld ra, 0(sp)
ld s1, 8(sp)
ld s2, 16(sp)
addi sp, sp, 32
ret
# -------- End of function main --------
