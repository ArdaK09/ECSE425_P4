#Pipelined processor testbench tcl script

set clock_period 1ns
set num_cycles 10000
set ram_size 8192
set num_registers 32

set program_file "program.txt"
set memory_out_file "memory.txt"
set register_out_file "register_file.txt"
set imem_out_file "instruction_memory.txt"

vlib work
vmap work work

vcom -2008 ALU.vhd
vcom -2008 instruction_decoder.vhd
vcom -2008 register_file.vhd
vcom -2008 branching_unit.vhd
vcom -2008 clock_divider.vhd
vcom -2008 hazard_detection_unit.vhd
vcom -2008 program_counter.vhd
vcom -2008 memory.vhd
vcom -2008 pipelined_cpu.vhd
vcom -2008 top_level.vhd

 
vsim -t 1ps work.top_level

# ──────────────────────────────────────────────
# Add internal signals to waveform
# ──────────────────────────────────────────────
# Top-level ports
add wave -divider "Top-Level Ports"
add wave /top_level/clk
add wave /top_level/reset

# Clock divider
add wave -divider "Clock Divider"
add wave /top_level/clk_divider

# Instruction memory interface
add wave -divider "Instruction Memory Interface"
add wave -radix hexadecimal /top_level/i_writedata
add wave -radix unsigned    /top_level/i_address
add wave /top_level/i_memwrite
add wave /top_level/i_memread
add wave -radix hexadecimal /top_level/i_readdata
add wave /top_level/i_waitrequest

# Instruction memory internals
add wave -divider "Instruction Memory Internals"
add wave -radix unsigned /top_level/instruction_memory/read_address_reg
add wave /top_level/instruction_memory/write_waitreq_reg
add wave /top_level/instruction_memory/read_waitreq_reg

# Processor internals
add wave -divider "Processor Internals"
add wave -radix hexadecimal /top_level/processor/pc_current_address
add wave -radix hexadecimal /top_level/processor/pc_next_address
add wave -radix hexadecimal /top_level/processor/currInstruction
add wave /top_level/processor/pc_stall
add wave /top_level/processor/ProgramCounterInstance/stall
add wave /top_level/processor/BranchingUnitInstance/branch
add wave /top_level/processor/BranchingUnitInstance/branch_taken
add wave /top_level/processor/BranchingUnitInstance/branch_op

# Data memory internals
add wave -divider "Data Memory Internals"
add wave -radix unsigned /top_level/data_memory/read_address_reg
add wave /top_level/data_memory/write_waitreq_reg
add wave /top_level/data_memory/read_waitreq_reg

# Data memory interface
add wave -divider "Data Memory Interface"
add wave -radix hexadecimal /top_level/d_writedata
add wave -radix unsigned    /top_level/d_address
add wave /top_level/d_memwrite
add wave /top_level/d_memread
add wave -radix hexadecimal /top_level/d_readdata
add wave /top_level/d_waitrequest

# ──────────────────────────────────────────────
# Clock & reset generation
# ──────────────────────────────────────────────
# Drive clock on the UUT port
force -freeze /top_level/clk  0 0ns, 1 0.5ns -repeat 1ns

# Assert reset, advance past the 1ps RAM init window, then load program
force -freeze /top_level/reset 1 0ns
run 1ps

# ──────────────────────────────────────────────
# Load program into instruction memory
# ──────────────────────────────────────────────
mem load -infile $program_file -format binary /top_level/instruction_memory/ram_block

# Continue reset for remaining ~3 cycles, then deassert
run 2999ps
force -freeze /top_level/reset 0 0ns
# ──────────────────────────────────────────────
# Run simulation
# ──────────────────────────────────────────────
run [expr {$num_cycles}]ns
 
# ──────────────────────────────────────────────
# Dump instruction memory → instruction_memory.txt
# ──────────────────────────────────────────────
set imem_fd [open $imem_out_file w]
for {set i 0} {$i < $ram_size} {incr i} {
    set val [examine -radix binary /top_level/instruction_memory/ram_block($i)]
    puts $imem_fd [string map {" " ""} $val]
}
close $imem_fd

# ──────────────────────────────────────────────
# Dump data memory → memory.txt
# ──────────────────────────────────────────────
set mem_fd [open $memory_out_file w]
for {set i 0} {$i < $ram_size} {incr i} {
    set val [examine -radix binary /top_level/data_memory/ram_block($i)]
    puts $mem_fd [string map {" " ""} $val]
}
close $mem_fd
 
# ──────────────────────────────────────────────
# Dump register file → register_file.txt
# ──────────────────────────────────────────────
set reg_fd [open $register_out_file w]
for {set i 0} {$i < $num_registers} {incr i} {
    set val [examine -radix binary /top_level/processor/RegisterFileInstance/all_regs($i)]
    puts $reg_fd [string map {" " ""} $val]
}
close $reg_fd
 
puts "Simulation complete."
puts "  Instruction memory -> $imem_out_file ($ram_size lines)"
puts "  Data memory        -> $memory_out_file  ($ram_size lines)"
puts "  Register file      -> $register_out_file ($num_registers lines)"
 
