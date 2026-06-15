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
li s1, 717
li s2, 1
li s1, 0
bne s2, s1, L1
j L6
L6:
j L2
L1:
li s1, 0
li s2, 0
bne s1, s2, L4
j L7
L7:
j L5
L4:
li s1, 0
mv s1, s1
j L3
L5:
li s1, 1
mv s1, s1
j L3
L2:
li s1, 0
mv s1, s1
L3:
ld ra, 0(sp)
ld s1, 8(sp)
ld s2, 16(sp)
addi sp, sp, 32
ret
# -------- End of function main --------
