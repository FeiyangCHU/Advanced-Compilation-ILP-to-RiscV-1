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
sd s4, 32(sp)
li s1, 11
mv s3, s1
li s1, 22
mv s4, s1
add s1, s3, s4
mv s2, s1
mul s1, s3, s4
mv s1, s1
mul s1, s2, s1
ld ra, 0(sp)
ld s1, 8(sp)
ld s2, 16(sp)
ld s3, 24(sp)
ld s4, 32(sp)
addi sp, sp, 48
ret
# -------- End of function main --------
