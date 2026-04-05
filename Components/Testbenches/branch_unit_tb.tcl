# TCL script to compile and simulate the branching_unit testbench
# Usage: vsim -do run_sim.tcl

# Create a new library
vlib work
vmap work work

# Compile the design files
echo "Compiling branching_unit.vhd..."
vcom -93 branching_unit.vhd

# Compile the testbench
echo "Compiling branching_unit_tb.vhd..."
vcom -93 branching_unit_tb.vhd

# Start simulation
echo "Starting simulation..."
vsim -voptargs=+acc work.branching_unit_tb

# Add waveforms to view
add wave -noupdate /branching_unit_tb/rs1_data
add wave -noupdate /branching_unit_tb/rs2_data
add wave -noupdate /branching_unit_tb/branch_op
add wave -noupdate /branching_unit_tb/branch
add wave -noupdate /branching_unit_tb/branch_taken

# Run simulation
echo "Running simulation..."
run -all

# Print summary
echo "Simulation complete. Check transcript for ASSERT results."

