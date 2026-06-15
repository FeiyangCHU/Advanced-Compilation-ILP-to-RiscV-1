.section .rodata
L_float_0:
	.float 0.1415926535
L_float_1:
	.float 3.1415926535
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
fsw fs1, 24(sp)
la s1, L_float_1
flw fs1, 0(s1)
la s1, L_float_0
flw fs0, 0(s1)
fsub.s fs0, fs1, fs0
ld ra, 0(sp)
ld s1, 8(sp)
flw fs0, 16(sp)
flw fs1, 24(sp)
addi sp, sp, 32
ret
# -------- End of function main --------
