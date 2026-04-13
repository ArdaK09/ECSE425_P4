    addi x1,  x0, 5        # x1 = 5
    addi x2,  x0, 10       # x2 = 10
    add  x3,  x1, x2       # x3 = 15
    sub  x4,  x2, x1       # x4 = 5
    and x5,  x1, x2       # x5 = 0
    or   x6,  x1, x2       # x6 = 15
    xor  x7,  x1, x2       # x7 = 15
    sll  x8,  x1, x1       # x8 = 5 << 5 = 160
    srl  x9,  x2, x1       # x9 = 10 >> 5 = 0
    addi x10, x0, -16       # x10 = -16
    sra  x11, x10, x1      # x11 = -16 >> 5 = -1
    xori x12, x1, 3        # x12 = 5 ^ 3 = 6
    ori  x13, x1, 2        # x13 = 5 | 2 = 7
    andi x14, x2, 7        # x14 = 10 & 7 = 2
    slti x15, x1, 8        # x15 = 1 (5 < 8)
    addi x16, x0, 100      # base addr = 100
    sw  x3,  0(x16)       # MEM[100] = 15, check memory.txt!
    lw   x17, 0(x16)       # x17 = 15
    beq  x17, x3, beq_ok   # taken
    addi x18, x0, 111      # skipped
beq_ok:
    bne  x1, x2, bne_ok    # taken
    addi x18, x0, 222      # skipped
bne_ok:
    blt  x1, x2, blt_ok    # taken
    addi x18, x0, 333      # skipped
blt_ok:
    bge x2, x1, bge_ok    # taken
    addi x18, x0, 444      # skipped
bge_ok:
    lui  x19, 697      
    auipc x20, 0           # x20 = current PC = 108
    jal  x21, jump_target  # x21 = return addr
    addi x22, x0, 999      # skipped, then returned to by JALR
jump_target:
    jalr x23, x21, 0       # JALed to. Then goes back to addi.
after_return:
    addi x24, x0, 42       # Should never be reached. 