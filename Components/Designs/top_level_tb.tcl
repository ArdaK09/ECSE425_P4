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

vcom -2008 memory.vhd
vcom -2008 pipelined_cpu.vhd
vcom -2008 top_level.vhd
 
vsim -t 1ns work.top_level
 
# ──────────────────────────────────────────────
# Load program into instruction memory
# ──────────────────────────────────────────────
set prog_fd [open $program_file r]
set addr 0
while {[gets $prog_fd line] >= 0} {
    # Skip blank lines
    set line [string trim $line]
    if {$line eq ""} { continue }
 
    # Convert 32-char binary string to an integer, then write word-by-word.
    # The memory is word-addressed; each line in program.txt is one 32-bit word.
    set word [expr "0b$line"]
    # Write each byte (ModelSim mem notation uses byte addresses for altsyncram)
    mem load -w 32 -i $program_file /top_level/instruction_memory/mem_array
    break    ;# mem load handles the whole file in one shot – exit the manual loop
}
close $prog_fd
 
# Use ModelSim's built-in memory loader (binary radix) for the full file.
# This overwrites the manual attempt above and is the canonical approach.
mem load -infile $program_file -format binary /top_level/instruction_memory/mem_array
 
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
    # Read 32-bit word from data memory array
    set val [examine -radix unsigned /top_level/data_memory/mem_array($i)]
    # Format as 32-bit binary string
    set bin ""
    for {set b 31} {$b >= 0} {incr b -1} {
        set bin "$bin[expr {($val >> $b) & 1}]"
    }
    puts $mem_fd $bin
}
close $mem_fd
 
# ──────────────────────────────────────────────
# Dump register file → register_file.txt
# ──────────────────────────────────────────────
set reg_fd [open $register_out_file w]
for {set i 0} {$i < $num_registers} {incr i} {
    set val [examine -radix unsigned /top_level/processor/reg_file($i)]
    set bin ""
    for {set b 31} {$b >= 0} {incr b -1} {
        set bin "$bin[expr {($val >> $b) & 1}]"
    }
    puts $reg_fd $bin
}
close $reg_fd
 
puts "Simulation complete."
puts "  Data memory  → $memory_out_file  ($ram_size lines)"
puts "  Register file → $register_out_file ($num_registers lines)"
 
quit -sim