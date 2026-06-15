.section .rodata
L_str_0:
	.string "FLOAT"
L_str_1:
	.string "true"
L_str_2:
	.string "false"
.section .rodata
L_float_0:
	.float 5.0
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
fsw fs0, 16(sp)
la s1, L_float_0
flw fs0, 0(s1)
la s1, L_str_0
mv s1, s1
ld ra, 0(sp)
ld s1, 8(sp)
flw fs0, 16(sp)
addi sp, sp, 32
ret
# -------- End of function main --------
