.section .rodata
L_str_0:
	.string "true"
L_str_1:
	.string "false"
.section .rodata
L_float_0:
	.float 0.
L_float_1:
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
addi sp, sp, -48
sd ra, 0(sp)
sd s1, 8(sp)
sd s2, 16(sp)
fsw fs0, 24(sp)
fsw fs1, 32(sp)
li s2, 1
li s1, 0
blt s1, s2, L4
j L19
L19:
j L5
L4:
li s1, 1
mv s1, s1
j L6
L5:
li s1, 0
mv s1, s1
L6:
li s2, 0
bne s1, s2, L1
j L20
L20:
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
li s1, 1
mv s1, s1
mv a0, s1
call float_of_int
fmv.s fs0, fa0
fmv.s fs1, fs0
la s1, L_float_0
flw fs0, 0(s1)
flt.s s1, fs0, fs1
bnez s1, L10
j L21
L21:
j L11
L10:
li s1, 1
mv s1, s1
j L12
L11:
li s1, 0
mv s1, s1
L12:
li s2, 0
bne s1, s2, L7
j L22
L22:
j L8
L7:
la s1, L_str_0
mv s1, s1
j L9
L8:
la s1, L_str_1
mv s1, s1
L9:
mv s1, s1
mv a0, s1
call print
mv s1, a0
li s1, 0
li s1, 0
mv s1, s1
mv a0, s1
call float_of_int
fmv.s fs0, fa0
fmv.s fs1, fs0
la s1, L_float_1
flw fs0, 0(s1)
flt.s s1, fs1, fs0
bnez s1, L16
j L23
L23:
j L17
L16:
li s1, 1
mv s2, s1
j L18
L17:
li s1, 0
mv s2, s1
L18:
li s1, 0
bne s2, s1, L13
j L24
L24:
j L14
L13:
la s1, L_str_0
mv s1, s1
j L15
L14:
la s1, L_str_1
mv s1, s1
L15:
mv s1, s1
mv a0, s1
call print
mv s1, a0
li s1, 0
mv s1, s1
ld ra, 0(sp)
ld s1, 8(sp)
ld s2, 16(sp)
flw fs0, 24(sp)
flw fs1, 32(sp)
addi sp, sp, 48
ret
# -------- End of function main --------
