.section .rodata
L_str_0:
	.string "*"
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
addi sp, sp, -48
sd ra, 0(sp)
sd s1, 8(sp)
sd s2, 16(sp)
fsw fs0, 24(sp)
fsw fs1, 32(sp)
li s1, 2
mv s1, s1
mv a0, s1
call float_of_int
fmv.s fs0, fa0
fmv.s fs1, fs0
la s1, L_float_0
flw fs0, 0(s1)
fdiv.s fs0, fs0, fs1
fmv.s fs0, fs0
fmv.s fa0, fs0
call string_of_float
mv s1, a0
mv s1, s1
mv s1, s1
la s2, L_str_0
mv s2, s2
mv a0, s1
mv a1, s2
call concat
mv s1, a0
ld ra, 0(sp)
ld s1, 8(sp)
ld s2, 16(sp)
flw fs0, 24(sp)
flw fs1, 32(sp)
addi sp, sp, 48
ret
# -------- End of function main --------
