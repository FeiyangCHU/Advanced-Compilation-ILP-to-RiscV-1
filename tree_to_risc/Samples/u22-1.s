.section .rodata
L_float_0:
	.float 1.
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
fsw fs0, 24(sp)
li s1, 22
li s2, 1
li s1, 0
bne s2, s1, L1
j L4
L4:
j L2
L1:
li s1, 1
mv s1, s1
mv a0, s1
call float_of_int
fmv.s fs0, fa0
fmv.s fs0, fs0
j L3
L2:
la s1, L_float_0
flw fs0, 0(s1)
fmv.s fs0, fs0
L3:
ld ra, 0(sp)
ld s1, 8(sp)
ld s2, 16(sp)
flw fs0, 24(sp)
addi sp, sp, 32
ret
# -------- End of function main --------
