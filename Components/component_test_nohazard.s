    li x6, 0xF0F0F0F0  # x6 = 0xF0F0F0F0
    li x7, 0x0F0F0F0F  # x7 = 0x0F0F0F0F	
    or x8, x6, x7
    and x9, x6, x7
    li x1, 10   # x1 = 10
    li x2, 3    # x2 = 3
    add x3, x1, x2  # x3 = x1 + x2 = 10 + 3 = 13
    sub x4, x1, x2  # x4 = x1 - x2 = 10 - 3 = 7
    
    mul x5, x1, x2 # x5 = x1 * x2 = 10 * 3 = 30
    
    li x10, 20          # x10 = 20
    
    addi x11, x10, 5    # x11 = x10 + 5 = 20 + 5 = 25

    li x12, 0xAAAAAAAA  # x12 = 0xAAAAAAAA (10101010...)
    
    xori x13, x12, 0x55555555   # x13 = 0xAAAAAAAA ^ 0x55555555 = 0xFFFFFFFF
     
    ori x14, x12, 0x0F0F    # x14 = 0xAAAAAAAA | 0x00000F0F = 0xAAAA0F0F
    
    andi x15, x12, 0x0F0F0F0F   # ANDI: x15 = 0xAAAAAAAA & 0x0F0F0F0F = 0x0A0A0A0A
    
    li x16, 0x00000001  # x16 = 1
    li x17, 3           # x17 = shift amount
    
    sll x18, x16, x17   # SLL: x18 = 1 << 3 = 8
    
    li x20, 0x80000001
    srl x19, x20, x17   # SRL: x19 = 0x80000001 >> 3 = 0x10000000 (logical)
    
    sra x21, x20, x17   # SRA: x21 = 0x80000001 >> 3 = 0xF0000000 (arithmetic)
    
    li x22, 5           # x22 = 5
    li x23, 10          # x23 = 10
    
    slti x24, x22, 10   # SLTI: x24 = (5 < 10) ? 1 : 0 = 1
    
    slti x25, x23, 10   # SLTI: x25 = (10 < 10) ? 1 : 0 = 0
    
    lui x26, 0x1        # use x26 = 0x1000 as a base address
    
    li x27, 0x12345678  # value 1 to store
    sw x27, 0(x26)      # SW: Store at 0x1000
    
    li x28, 0xDEADBEEF  # value 2 to store
    sw x28, 4(x26)      # SW: Store at 0x1004
    
    li x29, 0xCAFEBABE  # value 3 to store
    sw x29, 8(x26)      # SW: Store at 0x1008
    
    lw x30, 0(x26)      # LW: Load from 0x1000 into x30 (should be 0x12345678)
    lw x31, 4(x26)      # LW: Load from 0x1004 into x31 (should be 0xDEADBEEF)
    lw x1, 8(x26)       # LW: Load from 0x1008 into x1 (should be 0xCAFEBABE)
    
    li x28, 42          # x28 = 42
    li x29, 42          # x29 = 42
    li x30, 100         # x30 = 100
    
    
    beq x28, x29, beq_taken # should branch (Tests only logic, assumes PC updates correctly and fetch happens correctly)
    li x31, 0           	# This should be skipped
    j beq_not_taken
    
beq_taken:
    li x31, 1           # Branch was taken
    
beq_not_taken:
    li x1, 5
    li x2, 10
    blt x1, x2, blt_taken # should branch
    li x3, 0              # This should be skipped
    j blt_not_taken
    
blt_taken:
    li x3, 1            # Branch was taken
    
blt_not_taken:
    li x4, 5
    li x5, 10
    bge x4, x5, bge_taken  # should not branch
    li x6, 1               # This should execute
    j bge_not_taken
    
bge_taken:
    li x6, 0            # This should not execute
    
bge_not_taken:
    jal x7, jal_target
    li x8, 0            # This should be skipped
    j jal_return
    
jal_target:
    li x8, 2            # x8 = 2, indicating JAL was taken
    
jal_return:
    lui x9, %hi(jalr_target)
    addi x9, x9, %lo(jalr_target)
    jal x10, jalr_skip
    
jalr_target:
    li x11, 3           # x11 = 3, indicating JALR was taken
    
jalr_skip:
    lui x12, 0xDEADB    # x12 = 0xDEADB000
    
    auipc x13, 0        # x13 = current PC
   
end:  # ===END===
	j end
