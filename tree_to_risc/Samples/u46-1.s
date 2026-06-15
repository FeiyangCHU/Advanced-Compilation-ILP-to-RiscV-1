.section .rodata
L_str_0:
	.string "Un, "
L_str_1:
	.string "deux et "
L_str_2:
	.string "trois."
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
addi sp, sp, -16
sd ra, 0(sp)
sd s1, 8(sp)
la s1, L_str_0
mv s1, s1
mv a0, s1
call print
mv s1, a0
li s1, 0
la s1, L_str_1
mv s1, s1
mv a0, s1
call print
mv s1, a0
li s1, 0
la s1, L_str_2
mv s1, s1
mv a0, s1
call print
mv s1, a0
li s1, 0
ld ra, 0(sp)
ld s1, 8(sp)
addi sp, sp, 16
ret
# -------- End of function main --------
