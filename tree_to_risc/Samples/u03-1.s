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
addi sp, sp, -16
sd ra, 0(sp)
sd s1, 8(sp)
li s1, 1
ld ra, 0(sp)
ld s1, 8(sp)
addi sp, sp, 16
ret
# -------- End of function main --------
