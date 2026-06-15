.section .rodata
L_str_0:
	.string "true"
L_str_1:
	.string "false"
.section .rodata
L_float_0:
	.float 4.0
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
li s1, 4
mv s1, s1
mv a0, s1
call float_of_int
fmv.s fs0, fa0
fmv.s fs1, fs0
la s1, L_float_0
flw fs0, 0(s1)
feq.s s1, fs1, fs0
bnez s1, L4
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
la s1, L_str_0
mv s1, s1
j L3
L2:
la s1, L_str_1
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
flw fs0, 24(sp)
flw fs1, 32(sp)
addi sp, sp, 48
ret
# -------- End of function main --------
