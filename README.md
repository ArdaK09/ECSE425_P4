# ECSE425 P4 — Pipelined RISC-V CPU

## How to Run

### Basic Testbench
```tcl
do testbench.tcl
# or
source testbench.tcl
```

The testbench can run up to ~8000 instructions of machine code from a file named `program.txt` (must be present in the working directory). Once the simulation completes, the following output files are written:

- `register_file.txt`
- `instruction_memory.txt`
- `memory.txt`

### View Internal Signals
```tcl
do top_level_tb.tcl
# or
source top_level_tb.tcl
```

Writes the same three output files as above, and exposes most internal signals on the waveform viewer.

---

## Key Design Decisions

### Avalon Interface
To ensure instruction fetch and load/store operations complete within one clock cycle (1 ns), a clock divider was used to limit CPU operating speed. Memory must operate at least twice the input rate to produce one output per cycle. Because a 3-cycle branch penalty was required and the fetch stage could not be pipelined, the program counter points to the next instruction to execute.

### Memory
Memory is word-addressable and supports only word-length (32-bit) data, as specified in the requirements. Memory components are sized to accommodate **8192 × 32-bit entries**.

### Program Counter
The program counter is abstracted into its own component rather than implemented as an FSM in the top-level.

### Branching Unit
Unlike ECSE 324-style CPUs, RISC-V branching compares only two registers, so branch resolution is handled in a dedicated `branching_unit` component.

### Register File
Register reads are asynchronous, but `rs1_data` and `rs2_data` outputs are latched into the `id_ex` pipeline registers on the clock edge.

### Immediate Generator
There is no separate immediate generator component. Immediate generation is handled inside the instruction decoder, where the lowest 7 bits (opcode) control a case statement that deciphers and sign-extends immediates.

### Pipeline Registers
Inspired by the caching assignment, pipeline register behaviour requires only a `process` block. There are no separate components for `if_id`, `id_ex`, `ex_mem`, or `mem_wb` — unlike the textbook block diagram.

---

## Component Descriptions

### `ALU`
Computes two input operands based on the combination of `func3` and `func7`.

### `branching_unit`
Evaluates the difference between two input data lines using `func3` to resolve branch conditions.

### `clock_divider`
Takes an input clock and outputs a signal at half the frequency.

### `hazard_detection_unit`
Detects pipeline hazards by checking for overlapping source and destination registers between in-flight instructions.

- **Branch hazards:** causes a flush and a 3-cycle stall
- **RAW hazards:** stalls for 2 cycles if the hazard is in the execute stage; 1 cycle if in the memory stage

### `instruction_decoder`
Takes a 32-bit instruction and produces all abstracted control signals used by the processor. Also performs sign extension.

| Output Signal | Description |
|---|---|
| `loading_notStoring` | Signals a memory load operation |
| `ALU_Operation` | Concatenation of `func3` and `func7` |
| `memory_WE` | Write enable for data memory |
| `registerFile_WE` | Write enable for register file |
| `inputA_MUX_Control` | Selects `rs1` or PC (PC used for J, B, and U-type instructions) |
| `inputB_MUX_Control` | Selects `rs2` or immediate |
| `branching_Enabled` | Asserted when a branch instruction is present |
| `branching_Operation` | `func3` value for branch instructions |
| `writeback_Source_Control` | Controls register file writeback source |
| `registerA` | `rs1` address |
| `registerB` | `rs2` address |
| `immediate` | Sign-extended immediate value |
| `destinationRegister` | Destination register address |

### `memory`
Word-addressable memory interface.

### `pipelined_cpu`
Top-level combination of all subcomponents, excluding memory.

### `program_counter`
Simple counter that updates when a branch is taken.

### `register_file`
A set of 32 general-purpose 32-bit registers.

### `top_level`
Connects the processor to memory, generates the clock, and applies the clock divider.
