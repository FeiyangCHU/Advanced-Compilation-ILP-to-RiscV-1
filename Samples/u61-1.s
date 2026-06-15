.section .rodata
L_str_0:
	.string "coucou"
L_str_1:
	.string "STRING"
L_str_2:
	.string "true"
L_str_3:
	.string "false"
.section .rodata
L_float_0:
	.float 1.5
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
sd s3, 24(sp)
fsw fs0, 32(sp)
li s1, 1
mv s3, s1
li s1, 1
mv s1, s1
li s2, 0
beq s1, s2, L2
j L1
L1:
mv s1, s3
mv a0, s1
call string_of_int
mv s1, a0
mv s1, s1
mv s1, s1
la s2, L_str_0
mv s2, s2
mv a0, s1
mv a1, s2
call concat
mv s1, a0
la s1, L_str_1
mv s1, s1
mv s1, s1
j L3
L2:
la s1, L_float_0
flw fs0, 0(s1)
fcvt.w.s s1, fs0
L3:
mv s1, s1
mv a0, s1
call print
mv s1, a0
li s1, 0
ld ra, 0(sp)
ld s1, 8(sp)
ld s2, 16(sp)
ld s3, 24(sp)
flw fs0, 32(sp)
addi sp, sp, 48
ret
# -------- End of function main --------
