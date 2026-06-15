.section .rodata
L_str_0:
	.string "invisible"
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
bne s2, s1, L1
j L4
L4:
j L2
L1:
la s1, L_str_0
mv s1, s1
mv a0, s1
call print
mv s1, a0
li s1, 0
mv s1, s1
j L3
L2:
li s1, 0
mv s1, s1
L3:
li s1, 48
ld ra, 0(sp)
ld s1, 8(sp)
ld s2, 16(sp)
addi sp, sp, 32
ret
# -------- End of function main --------
