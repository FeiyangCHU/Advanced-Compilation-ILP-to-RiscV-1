.section .rodata
L_float_0:
	.float 6.3
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
addi sp, sp, -48
sd ra, 0(sp)
sd s1, 8(sp)
sd s2, 16(sp)
fsw fs0, 24(sp)
fsw fs1, 32(sp)
li s1, 22
mv s2, s1
la s1, L_float_0
flw fs0, 0(s1)
fmv.s fs0, fs0
fmv.s fs0, fs0
mv s1, s2
mv a0, s1
call float_of_int
fmv.s fs1, fa0
fmv.s fs1, fs1
fadd.s fs0, fs0, fs1
ld ra, 0(sp)
ld s1, 8(sp)
ld s2, 16(sp)
flw fs0, 24(sp)
flw fs1, 32(sp)
addi sp, sp, 48
ret
# -------- End of function main --------
