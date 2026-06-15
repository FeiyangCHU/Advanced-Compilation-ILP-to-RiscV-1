.section .rodata
L_str_0:
	.string "true"
L_str_1:
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
addi sp, sp, -32
sd ra, 0(sp)
sd s1, 8(sp)
sd s2, 16(sp)
fsw fs0, 24(sp)
li s1, 1
li s2, 0
beq s1, s2, L2
j L1
L1:
la s1, L_float_0
flw fs0, 0(s1)
fmv.s fs0, fs0
j L3
L2:
li s1, 0
fcvt.s.w fs0, s1
L3:
ld ra, 0(sp)
ld s1, 8(sp)
ld s2, 16(sp)
flw fs0, 24(sp)
addi sp, sp, 32
ret
# -------- End of function main --------
