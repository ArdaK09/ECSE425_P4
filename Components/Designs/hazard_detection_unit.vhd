library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hazard_detection_unit is
	port(
			--Ins
			clk: in std_logic;
			rs1: in std_logic_vector(4 downto 0);
			rs2: in std_logic_vector(4 downto 0);
			mux1Control : in std_logic;
			mux2Control : in std_logic;
			EX_rd : in std_logic_vector(4 downto 0);
			MEM_rd : in std_logic_vector(4 downto 0);
			exmem_branching_result : in std_logic := '0';
			branchingEnabled : in std_logic := '0';
			--Outs
			stall_ifid : out std_logic;
			stall_pc : out std_logic;
			flush_ifid : out std_logic;
			flush_idex : out std_logic;
			flush_exmem : out std_logic
	);
end hazard_detection_unit;

architecture arch of hazard_detection_unit is
type state_type is
	(
	IDLE,
	TwoCycleHazardCycle1,
	TwoCycleHazardCycle2,
	OneCycleHazardCycle1,
	ControlHazard
	);
signal state : state_type := IDLE;
signal nextState : state_type := IDLE;

begin
	--Updating states
	stateReg : process(clk)
	begin
		if rising_edge(clk) then
			state <= nextState;
		end if;
	end process;

	combinationalLogic : process(state, rs1, rs2, mux1Control, mux2Control, EX_rd, MEM_rd, exmem_branching_result, branchingEnabled)
	begin
		-- Default all outputs to avoid latches
		stall_ifid  <= '0';
		stall_pc    <= '0';
		flush_ifid  <= '0';
		flush_idex  <= '0';
		flush_exmem <= '0';
		nextState   <= IDLE;

		case state is
			when IDLE =>
				-- Control hazard highest priority
				-- Flush first three registers.
				--Note: Flushing exmem register happens structurally by the vhdl delta cycling!!
				--Since ifid, idex, and exmem are updated concurrently on the rising edge of the clock,
				--exmem structually gets zeroed through flushing both ifid and idex...
				if exmem_branching_result = '1' then
					nextState   <= ControlHazard;
					flush_ifid  <= '1';
					flush_idex  <= '1';
					flush_exmem <= '1';

				-- Check rs1 and rs2 independently, take worst case
				else
				-- Two cycle hazard (back to back data dependency)
				-- Checked by comparing the inputs to ALU and ID/EX register (prev instr) return address
					if (rs1 /= "00000" and (mux1Control = '0' or branchingEnabled = '1') and rs1 = EX_rd) or (rs2 /= "00000" and (mux2Control = '0' or branchingEnabled = '1') and rs2 = EX_rd) then
						nextState  <= TwoCycleHazardCycle1;
						stall_ifid <= '1';
						stall_pc   <= '1';
						flush_idex <= '1';

					-- One cycle hazard (one-apart data dependency)
					-- Checked similar to above
					elsif (rs1 /= "00000" and (mux1Control = '0' or branchingEnabled = '1') and rs1 = MEM_rd) or ( rs2 /= "00000" and (mux2Control = '0' or branchingEnabled = '1') and rs2 = MEM_rd) then
						nextState  <= OneCycleHazardCycle1;
						stall_ifid <= '1';
						stall_pc   <= '1';
						flush_idex <= '1';
					end if;
				end if;

			when TwoCycleHazardCycle1 =>
				-- Still stalling, one more cycle to go
				nextState  <= TwoCycleHazardCycle2;
				stall_ifid <= '1';
				stall_pc   <= '1';
				flush_idex <= '1';

			when TwoCycleHazardCycle2 =>
				-- Last stall cycle, return to IDLE
				--Stalls already at '0'
				nextState <= IDLE;

			when OneCycleHazardCycle1 =>
				-- Last stall cycle, return to IDLE
				-- Stalls already at '0'
				nextState <= IDLE;

			when ControlHazard =>
				-- Flushes already at '0'
				nextState <= IDLE;
				
		end case;
	end process;
end architecture;
