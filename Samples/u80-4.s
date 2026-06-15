.section .rodata
L_str_0:
	.string "GEORGE "
L_str_1:
	.string "BOOL"
L_str_2:
	.string "E"
L_str_3:
	.string "true"
L_str_4:
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
mv a0, s1
call print
mv s1, a0
li s1, 0
la s1, L_str_1
mv s1, s1
mv s2, s1
la s1, L_str_2
mv s1, s1
mv a0, s2
mv a1, s1
call concat
mv s1, a0
mv s1, s1
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
