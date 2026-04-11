# ECSE425_P4
Some Key Decisions made by the team
- Avalon Interface: 
In order to ensure the instruction fetch and load/store (Instruction and Memory) operations are completed within one clock cycle (1ns),
we had to use a clock divider that limited the CPU operation speed. This is because the memory must operate at least twice the input rate to generate **one output per cycle**.

- Memory Component:
In the context of the requirements outlined in the instructions document, we have noted that memory only supports word-length data. Thus, we decided to set the memory components to accommodate 8192 32b entries.
