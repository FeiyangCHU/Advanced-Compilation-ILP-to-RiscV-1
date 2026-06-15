.section .rodata
L_str_0:
	.string "aa"
L_str_1:
	.string "bb"
L_str_2:
	.string "true"
L_str_3:
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
la s1, L_str_0
mv s1, s1
la s2, L_str_1
mv s2, s2
mv a0, s1
mv a1, s2
call strcmp
mv s1, a0
mv s1, s1
li s2, 0
bne s1, s2, L4
j L7
L7:
j L5
L4:
li s1, 1
mv s2, s1
j L6
L5:
li s1, 0
mv s2, s1
L6:
li s1, 0
bne s2, s1, L1
j L8
L8:
j L2
L1:
la s1, L_str_2
mv s1, s1
j L3
L2:
la s1, L_str_3
mv s1, s1
L3:
mv s1, s1
mv a0, s1
call print
mv s1, a0
li s1, 0
ld ra, 0(sp)
ld s1, 8(sp)
ld s2, 16(sp)
addi sp, sp, 32
ret
# -------- End of function main --------
