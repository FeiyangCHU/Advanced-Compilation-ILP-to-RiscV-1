.section .rodata
L_str_0:
	.string "cou"
L_str_1:
	.string "true"
L_str_2:
	.string "false"
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

# -------- Function L1 --------
L1:
addi sp, sp, -16
sd ra, 0(sp)
sd s1, 8(sp)
mv s1, a0
add s1, s1, s1
mv s1, s1
mv a0, s1
ld ra, 0(sp)
ld s1, 8(sp)
addi sp, sp, 16
ret
# -------- End of function L1 --------

# -------- Function L2 --------
L2:
addi sp, sp, -32
sd ra, 0(sp)
sd s1, 8(sp)
sd s2, 16(sp)
mv s1, a0
mv s1, s1
mv s2, s1
mv a0, s1
mv a1, s2
call concat
mv s1, a0
mv s1, s1
mv a0, s1
ld ra, 0(sp)
ld s1, 8(sp)
ld s2, 16(sp)
addi sp, sp, 32
ret
# -------- End of function L2 --------

# -------- Function main --------
ILPmain:
addi sp, sp, -16
sd ra, 0(sp)
sd s1, 8(sp)
la s1, L_str_0
mv s1, s1
mv a0, s1
call L2
mv s1, a0
mv s1, s1
mv s1, s1
mv a0, s1
call print
mv s1, a0
li s1, 0
li s1, 2
mv s1, s1
mv a0, s1
call L1
mv s1, a0
mv s1, s1
mv s1, s1
mv a0, s1
call string_of_int
mv s1, a0
mv s1, s1
mv s1, s1
mv a0, s1
call print
mv s1, a0
li s1, 0
mv s1, s1
ld ra, 0(sp)
ld s1, 8(sp)
addi sp, sp, 16
ret
# -------- End of function main --------
