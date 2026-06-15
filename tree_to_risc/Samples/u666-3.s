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
addi sp, sp, -32
sd ra, 0(sp)
sd s1, 8(sp)
sd s2, 16(sp)
sd s3, 24(sp)
mv s2, a0
li s1, 0
beq s2, s1, L5
j L8
L8:
j L6
L5:
li s1, 1
mv s1, s1
j L7
L6:
li s1, 0
mv s1, s1
L7:
li s3, 0
bne s1, s3, L2
j L9
L9:
j L3
L2:
li s1, 1
mv s1, s1
j L4
L3:
mv s2, s2
li s1, 1
sub s1, s2, s1
mv s1, s1
mv a0, s1
call L1
mv s1, a0
mv s1, s1
mul s1, s2, s1
mv s1, s1
L4:
mv a0, s1
ld ra, 0(sp)
ld s1, 8(sp)
ld s2, 16(sp)
ld s3, 24(sp)
addi sp, sp, 32
ret
# -------- End of function L1 --------

# -------- Function main --------
ILPmain:
addi sp, sp, -16
sd ra, 0(sp)
sd s1, 8(sp)
li s1, 5
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
ld ra, 0(sp)
ld s1, 8(sp)
addi sp, sp, 16
ret
# -------- End of function main --------
