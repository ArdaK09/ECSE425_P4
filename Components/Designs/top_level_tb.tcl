#Pipelined processor testbench tcl script

set clock_period 1ns
set num_cycles 10000
set ram_size 8192
set num_registers 32

set program_file "program.txt"
set memory_out_file "memory.txt"
set register_out_file "register_file.txt"

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
# Load program into instruction memory
# ──────────────────────────────────────────────
mem load -infile $program_file -format binary /top_level/instruction_memory/ram_block
 
# ──────────────────────────────────────────────
# Clock & reset generation
# ──────────────────────────────────────────────
# Drive clock on the UUT port
force -freeze /top_level/clk  0 0ns, 1 0.5ns -repeat 1ns
 
# Assert reset for 3 cycles, then deassert
force -freeze /top_level/reset 1 0ns
run 3ns
force -freeze /top_level/reset 0 0ns
 
# ──────────────────────────────────────────────
# Run simulation
# ──────────────────────────────────────────────
run [expr {$num_cycles}]ns
 
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
puts "  Data memory  → $memory_out_file  ($ram_size lines)"
puts "  Register file → $register_out_file ($num_registers lines)"
 
quit -sim