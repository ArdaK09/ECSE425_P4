addi  a0, x0, 5 
jal  a1, fact
stop: 
beq, x0, x0, stop 
fact:
add   t0, x0, a0
addi  a0, x0, 1 
fact_l:
slti  t1, t0, 2
bne   t1, x0, done 
mul   a0, a0, t0        
addi  t0, t0, -1 
jal   x0, fact_l 
done:
jalr  x0, ra, 0 
