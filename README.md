# ECSE425_P4
Some Key Decisions made by the team
- Avalon Interface: 
In order to ensure the instruction fetch and load/store operations are completed within one clock cycle (1ns),
we set the memory delay to 0.3 ns in both the data and instruction memories. In the same vein, the _waitrequest_ signal
is now on for not an entire clock cycle, but for 0.4ns. During this time, the _readdata_ is recognized and assigned to its respective 
signal, so that the memory component is ready for the next rising clock edge.
- More to come...
