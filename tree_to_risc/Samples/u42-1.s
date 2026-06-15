.section .rodata
L_float_0:
	.float 2.5
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
li s1, 1
mv s1, s1
mv a0, s1
call float_of_int
fmv.s fs0, fa0
fmv.s fs0, fs0
la s1, L_float_0
flw fs1, 0(s1)
fsub.s fs0, fs1, fs0
fmv.s fs0, fs0
fmv.s fa0, fs0
call string_of_float
mv s1, a0
mv s1, s1
mv s1, s1
mv a0, s1
call print
mv s1, a0
li s1, 0
ld ra, 0(sp)
ld s1, 8(sp)
flw fs0, 16(sp)
flw fs1, 24(sp)
addi sp, sp, 32
ret
# -------- End of function main --------
