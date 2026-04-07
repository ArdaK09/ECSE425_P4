# RISC-V RV32I Test Program
# Tests: add, sub, mul, or, and, addi, xori, ori, andi, 
#        sll, srl, sra, slti, lw, sw, beq, bne, blt, bge, jal, jalr, lui, auipc

	
	# ==========================================
	# Load, AND/OR
	
	li x6, 0xF0F0F0F0  # x6 = 0xF0F0F0F0
    li x7, 0x0F0F0F0F  # x7 = 0x0F0F0F0F
    
    # OR: x8 = 0xF0F0F0F0 | 0x0F0F0F0F = 0xFFFFFFFF
    or x8, x6, x7
    
    # AND: x9 = 0xF0F0F0F0 & 0x0F0F0F0F = 0x00000000
    and x9, x6, x7
    
    # ==========================================
    # Arithmetic
    
    li x1, 10           # x1 = 10
    li x2, 3            # x2 = 3
    
    # ADD: x3 = x1 + x2 = 10 + 3 = 13
    add x3, x1, x2
    
    # SUB: x4 = x1 - x2 = 10 - 3 = 7
    sub x4, x1, x2
    
    # MUL: x5 = x1 * x2 = 10 * 3 = 30
    mul x5, x1, x2
    
    li x10, 20          # x10 = 20
    
    # ADDI: x11 = x10 + 5 = 20 + 5 = 25
    addi x11, x10, 5
    
    # ==========================================
    # Bitwise Logic
    
    li x12, 0xAAAAAAAA  # x12 = 0xAAAAAAAA (10101010...)
    
    # XORI: x13 = 0xAAAAAAAA ^ 0x55555555 = 0xFFFFFFFF
    xori x13, x12, 0x55555555
    
    # ORI: x14 = 0xAAAAAAAA | 0x00000F0F = 0xAAAA0F0F
    ori x14, x12, 0x0F0F
    
    # ANDI: x15 = 0xAAAAAAAA & 0x0F0F0F0F = 0x0A0A0A0A
    andi x15, x12, 0x0F0F0F0F
    
    # ==========================================
    # Shift Operations
    
    li x16, 0x00000001  # x16 = 1
    li x17, 3           # x17 = shift amount
    
    # SLL: x18 = 1 << 3 = 8
    sll x18, x16, x17
    
    # SRL: x19 = 0x80000001 >> 3 = 0x10000000 (logical)
    li x20, 0x80000001
    srl x19, x20, x17
    
    # SRA: x21 = 0x80000001 >> 3 = 0xF0000000 (arithmetic)
    sra x21, x20, x17
    
    # ==========================================
    # slti
    
    li x22, 5           # x22 = 5
    li x23, 10          # x23 = 10
    
    # SLTI: x24 = (5 < 10) ? 1 : 0 = 1
    slti x24, x22, 10
    
    # SLTI: x25 = (10 < 10) ? 1 : 0 = 0
    slti x25, x23, 10
    
    # ==========================================
    # Memory Operations (li, sw, lw)
    
    # Use x26 as base address for memory (assume 0x1000)
    lui x26, 0x1        # x26 = 0x1000
    
    # Store three different values to memory
    li x27, 0x12345678  # value 1 to store
    sw x27, 0(x26)      # SW: Store at 0x1000
    
    li x28, 0xDEADBEEF  # value 2 to store
    sw x28, 4(x26)      # SW: Store at 0x1004
    
    li x29, 0xCAFEBABE  # value 3 to store
    sw x29, 8(x26)      # SW: Store at 0x1008
    
    # Load values back from memory
    lw x30, 0(x26)      # LW: Load from 0x1000 into x30 (should be 0x12345678)
    lw x31, 4(x26)      # LW: Load from 0x1004 into x31 (should be 0xDEADBEEF)
    lw x1, 8(x26)       # LW: Load from 0x1008 into x1 (should be 0xCAFEBABE)
    
    # ==========================================
    # Branching (Tests only logic, assumes PC updates correctly and fetch happens correctly)
    # beq, bne, blt, bge
    
    li x28, 42          # x28 = 42
    li x29, 42          # x29 = 42
    li x30, 100         # x30 = 100
    
    # should branch
    beq x28, x29, beq_taken
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
    # ==========================================
    # Jumps
    
    # JAL: Jump and Link
    jal x7, jal_target
    li x8, 0            # This should be skipped
    j jal_return
    
jal_target:
    li x8, 2            # x8 = 2, indicating JAL was taken
    
jal_return:
    # JALR: Jump and Link Register
    lui x9, %hi(jalr_target)
    addi x9, x9, %lo(jalr_target)
    jal x10, jalr_skip
    
jalr_target:
    li x11, 3           # x11 = 3, indicating JALR was taken
    
jalr_skip:
    # ==========================================
    # Upper immediate (lui, auipc)
    
    # LUI: Load Upper Immediate
    lui x12, 0xDEADB    # x12 = 0xDEADB000
    
    # AUIPC: Add Upper Immediate to PC
    auipc x13, 0        # x13 = current PC
   
    # ===END===
end: 
	j end
