library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;

entity pipelined_cpu is
	--IDK if this is necessary. Might be good to have???
	generic(
		ram_size : INTEGER := 8192;
		mem_delay : time := 1 ns;
		clock_period : time := 1 ns
	);
	port(
		clk : in std_logic;
		reset: in std_logic;
		
		--Instruction Avalon Interface
		i_writedata: out std_logic_vector(31 downto 0);
		i_address: out integer range 0 to ram_size-1;
		i_memwrite: out std_logic;
		i_memread: out std_logic;
		i_readdata: in std_logic_vector(31 downto 0);
		i_waitrequest: in std_logic;
		
		--Data Avalon Interface
		d_writedata: out std_logic_vector(31 downto 0);
		d_address: out integer range 0 to ram_size-1;
		d_memwrite: out std_logic;
		d_memread: out std_logic;
		d_readdata: in std_logic_vector(31 downto 0);
		d_waitrequest: in std_logic	
	);
end pipelined_cpu;

architecture rtl of pipelined_cpu is
	--Component definitions
	component program_counter is 
		port(
			clk : in std_logic;
			reset : in std_logic;
			stall : in std_logic;
			jump_or_branch_condition : in std_logic;
			jump_or_branch_addr : in std_logic_vector(31 downto 0);
			pc_out : out std_logic_vector(31 downto 0);
			pc_plus4_out : out std_logic_vector(31 downto 0)
		);
	end component program_counter;
	
	component instruction_decoder is 
		port(
			instruction_input : in std_logic_vector(31 downto 0);
			Loading_NotStoring : out std_logic;
			ALU_Operation : out std_logic_vector(9 downto 0);
			Memory_WE : out std_logic;
			RegisterFile_WE : out std_logic;
			InputA_MUX_Control : out std_logic;
			InputB_MUX_Control : out std_logic;
			Branching_Enabled : out std_logic;
			Branching_Operation : out std_logic_vector(2 downto 0);
			Writeback_Source_Control : out std_logic_vector(1 downto 0);
			RegisterA : out std_logic_vector(4 downto 0);
			RegisterB :out std_logic_vector(4 downto 0);
			Immediate : out std_logic_vector(31 downto 0);
			DestinationRegister : out std_logic_vector(4 downto 0)
		);
	end component instruction_decoder;
	
	component register_file is 
		port(
			clk : in std_logic;
			reset : in std_logic;
			reg_write : in std_logic;
			rd_addr : in std_logic_vector(4 downto 0);
			write_data : in std_logic_vector(31 downto 0);
			rs1_addr : in std_logic_vector(4 downto 0);
			rs1_data : out std_logic_vector(31 downto 0);
			rs2_addr : in std_logic_vector(4 downto 0);
			rs2_data : out std_logic_vector(31 downto 0)
		);
	end component register_file;
	
	component branching_unit is
		port(
			rs1_data     : in std_logic_vector(31 downto 0);
			rs2_data     : in std_logic_vector(31 downto 0);
			branch_op    : in std_logic_vector(2  downto 0);
			branch       : in std_logic;
			branch_taken : out std_logic
		);
	end component branching_unit;
	
	component ALU is 
		port(
			alu_op : in std_logic_vector(9 downto 0);
			rs1 : in std_logic_vector(31 downto 0);
			rs2 : in std_logic_vector(31 downto 0);
			rd : out std_logic_vector(31 downto 0)
		);
	end component ALU;
	
	-- Internal Combinational Signals (between stages)
 
	--PC Output wires
	signal pc_current_address    : std_logic_vector(31 downto 0);
	signal pc_next_address       : std_logic_vector(31 downto 0);
	signal currInstruction : std_logic_vector(31 downto 0); -- Output of InstrMem, wired to IF/ID reg
 
	--PC Stalling wires
	signal pc_stall              : std_logic;
 
	-- Branching wires
	signal branch_taken          : std_logic;
 
	--instruction_decoder output wires
	signal dec_loading_notStoring      : std_logic;
	signal dec_ALU_Operation           : std_logic_vector(9 downto 0);
	signal dec_memory_WE               : std_logic;
	signal dec_registerFile_WE         : std_logic;
	signal dec_inputA_MUX_Control      : std_logic;
	signal dec_inputB_MUX_Control      : std_logic;
	signal dec_branchingEnabled        : std_logic;
	signal dec_branching_Operation     : std_logic_vector(2 downto 0);
	signal dec_writeback_Source_Control: std_logic_vector(1 downto 0);
	signal dec_registerA               : std_logic_vector(4 downto 0);
	signal dec_registerB               : std_logic_vector(4 downto 0);
	signal dec_immediate               : std_logic_vector(31 downto 0);
	signal dec_destinationRegister     : std_logic_vector(4 downto 0);
 
	--register_file output wires
	signal rf_rs1_data : std_logic_vector(31 downto 0);
	signal rf_rs2_data : std_logic_vector(31 downto 0);
 
	--execution stage mux outputs
	signal alu_input_a : std_logic_vector(31 downto 0);
	signal alu_input_b : std_logic_vector(31 downto 0);
	
	--ALU output
	signal alu_output  : std_logic_vector(31 downto 0);
	
	--Data Memory Output
	signal currData : std_logic_vector(31 downto 0);
 
	--Writeback MUX output (Either PC + 4, Data Memory, or ALU Output)
	signal wb_write_data : std_logic_vector(31 downto 0);
	
	
	
	--ALL REGISTERED SIGNALS
	
	
	--IF/ID Registered signals
	signal ifid_nextInstructionAddress : std_logic_vector(31 downto 0);
	signal ifid_currentInstructionAddress : std_logic_vector(31 downto 0);
	signal ifid_currentInstruction : std_logic_vector(31 downto 0);

	
	--ID/EX Registered signals
	--For jump instructions
	signal idex_nextInstructionAddress : std_logic_vector(31 downto 0);
	
	signal idex_currentInstructionAddress : std_logic_vector(31 downto 0);
	signal idex_registerAValue : std_logic_vector(31 downto 0);
	signal idex_registerBValue : std_logic_vector(31 downto 0);
	signal idex_immediateValue : std_logic_vector(31 downto 0);
	signal idex_destinationRegister : std_logic_vector(4 downto 0);
	--Outputs of the instruction decoder
	signal idex_loading_notStoring : std_logic;
	signal idex_ALU_Operation : std_logic_vector(9 downto 0);
	signal idex_memory_WE : std_logic;
	signal idex_registerFile_WE: std_logic;
	signal idex_inputA_MUX_Control : std_logic;
	signal idex_inputB_MUX_Control : std_logic;
	signal idex_branchingEnabled : std_logic;
	signal idex_branching_Operation : std_logic_vector(2 downto 0);
	signal idex_writeback_Source_Control : std_logic_vector(1 downto 0);

	
	--EX/MEM Registered Signals
	signal exmem_branching_result : std_logic;
	signal exmem_ALU_Output : std_logic_vector(31 downto 0);
	signal exmem_registerB_Output : std_logic_vector(31 downto 0);
	signal exmem_destinationRegister: std_logic_vector(4 downto 0);
	signal exmem_registerFile_WE : std_logic;
	--For jump instructions
	signal exmem_nextInstructionAddress : std_logic_vector(31 downto 0);
	
	signal exmem_loading_notStoring : std_logic;
	signal exmem_memory_WE : std_logic;
	signal exmem_writeback_Source_Control : std_logic_vector(1 downto 0);

	
	--MEM/WB Registered Signals
	signal memwb_nextInstructionAddress : std_logic_vector(31 downto 0);
	signal memwb_memory_Output : std_logic_vector(31 downto 0);
	signal memwb_ALU_Output : std_logic_vector(31 downto 0);
	signal memwb_destinationRegister : std_logic_vector(4 downto 0);
	signal memwb_writeback_Source_Control : std_logic_vector(1 downto 0);
	signal memwb_registerFile_WE : std_logic;
	
begin
	--Component Instantiation (Getting the correct wiring of everything!)
	ProgramCounterInstance : program_counter
		port map (
			clk => clk,
			reset => reset,
			stall => pc_stall,
			jump_or_branch_condition => exmem_branching_result,
			jump_or_branch_addr => exmem_ALU_Output,
			pc_out => pc_current_address,
			pc_plus4_out => pc_next_address
		);
		
	InstructionDecoderInstance : instruction_decoder
		port map (
			instruction_input => ifid_currentInstruction,
			loading_notStoring => dec_loading_notStoring,
			ALU_Operation => dec_ALU_Operation,
			memory_WE => dec_memory_WE,
			registerFile_WE => dec_registerFile_WE,
			inputA_MUX_Control => dec_inputA_MUX_Control,
			inputB_MUX_Control => dec_inputB_MUX_Control,
			branching_Enabled => dec_branchingEnabled,
			branching_Operation => dec_branching_Operation,
			writeback_Source_Control => dec_writeback_Source_Control,
			registerA => dec_registerA,
			registerB => dec_registerB,
			immediate => dec_immediate,
			destinationRegister => dec_destinationRegister
		);
		
	RegisterFileInstance : register_file
		port map (
			clk => clk,
			reset => reset,
			reg_write => memwb_registerFile_WE,
			write_data => wb_write_data,
			rd_addr => memwb_destinationRegister,
			rs1_addr => dec_registerA,
			rs1_data => rf_rs1_data,
			rs2_addr => dec_registerB,
			rs2_data => rf_rs2_data
		);
		
	BranchingUnitInstance : branching_unit
		port map (
			rs1_data => idex_registerAValue,
			rs2_data => idex_registerBValue,
			branch_op => idex_branching_Operation,
			branch => idex_branchingEnabled,
			branch_taken => branch_taken
		);
		
	ALUInstance : ALU
		port map (
			alu_op => idex_ALU_Operation,
			rs1 => alu_input_a,
			rs2 => alu_input_b,
			rd => alu_output
		);
	
	--
	
	--Instruction Fetch Combinational Logic
		
	--Send avalon request to get the next instruction from the instruction memory
	issueNextInstruction : process(pc_current_address, i_waitrequest)
	begin
		if pc_current_address'event then
			i_address    <= to_integer(unsigned(pc_current_address));
			i_memread    <= '1';
			i_memwrite   <= '0';
			i_writedata  <= (others => '0');
		end if;

		if falling_edge(i_waitrequest) then
			currInstruction <= i_readdata;
			i_memread       <= '0';
		end if;
	end process;
			
	--IF/ID register updates (clocked process)
	IFID_REG :  process(clk, reset)
	begin
		if reset = '1' then
			--reset logic for this pipeline stage
			ifid_currentInstruction <= (others => '0');
			ifid_currentInstructionAddress <= (others => '0');
			ifid_nextInstructionAddress <= (others => '0');
		elsif rising_edge(clk) then
			ifid_currentInstruction <= currInstruction;
			ifid_currentInstructionAddress <= pc_current_address;
			ifid_nextInstructionAddress <= pc_next_address;
		end if;
	end process;
	
	
	--Instruction Decode Combinational Logic
	
	--Everything occurs in the instruction_decoder and register_file, so no logic necessary
	
	
	--ID/EX register updates (clocked process)
	IDEX_REG : process(clk, reset)
	begin
		if reset = '1' then
			--reset logic for this pipeline stage
			idex_nextInstructionAddress <= (others => '0');
			idex_currentInstructionAddress <= (others => '0');
			idex_registerAValue <= (others => '0');
			idex_registerBValue <= (others => '0');
			idex_immediateValue <= (others => '0');
			idex_destinationRegister <= (others => '0');
			idex_loading_notStoring <= '0';
			idex_ALU_Operation <= (others => '0');
			idex_memory_WE <= '0';
			idex_registerFile_WE <= '0';
			idex_inputA_MUX_Control <= '0';
			idex_inputB_MUX_Control <= '0';
			idex_branchingEnabled <= '0';
			idex_branching_Operation <= (others => '0');
			idex_writeback_Source_Control <= (others => '0');
		elsif rising_edge(clk) then
			--Pipelined from prev stage
			idex_nextInstructionAddress <= ifid_nextInstructionAddress;
			idex_currentInstructionAddress <= ifid_currentInstructionAddress;
			
			--RF Outputs
			idex_registerAValue <= rf_rs1_data;
			idex_registerBValue <= rf_rs2_data;
			
			--Decoder Outputs
			idex_immediateValue <= dec_immediate;
			idex_destinationRegister <= dec_destinationRegister;
			idex_loading_notStoring <= dec_loading_notStoring;
			idex_ALU_Operation <= dec_ALU_Operation;
			idex_memory_WE <= dec_memory_WE;
			idex_registerFile_WE <= dec_registerFile_WE;
			idex_inputA_MUX_Control <= dec_inputA_MUX_Control;
			idex_inputB_MUX_Control <= dec_inputB_MUX_Control;
			idex_branchingEnabled <= dec_branchingEnabled;
			idex_branching_Operation <= dec_branching_Operation;
			idex_writeback_Source_Control <= dec_writeback_Source_Control;
		end if;
	end process;
	
	
	--Instruction Execution Combinational Logic
	
	alu_input_a <= idex_currentInstructionAddress when idex_inputA_MUX_Control = '1' else idex_registerAValue;
	alu_input_b <= idex_immediateValue when idex_inputB_MUX_Control = '1' else idex_registerBValue;

	
	--EX/MEM register updates (clocked process)
	EXMEM_REG : process(clk, reset)
	begin
		if reset = '1' then
			--reset logic for this pipeline stage
			exmem_ALU_Output <= (others => '0');
			exmem_registerB_Output <= (others => '0');
			exmem_destinationRegister <= (others => '0');
			exmem_nextInstructionAddress <= (others => '0');
			exmem_loading_notStoring <= '0';
			exmem_memory_WE <= '0';
			exmem_registerFile_WE <= '0';
			exmem_writeback_Source_Control <= (others => '0');
			exmem_branching_result <= '0';
		elsif rising_edge(clk) then
			--ALU Output
			exmem_ALU_Output <= alu_output;
			
			--Pipelined from prev stage
			exmem_registerB_Output <= idex_registerBValue;
			exmem_nextInstructionAddress <= idex_nextInstructionAddress;
			exmem_destinationRegister <= idex_destinationRegister;
			exmem_loading_notStoring <= idex_loading_notStoring;
			exmem_memory_WE <= idex_memory_WE;
			exmem_registerFile_WE <= idex_registerFile_WE;
			exmem_writeback_Source_Control <= idex_writeback_Source_Control;
			
			--Branching Unit Output 
			exmem_branching_result <= branch_taken;
		end if;
	end process;
	
	--
	
	--Memory Stage Combinational Logic
	
	--Use avalon interface to set the data memory...
	--process is simpler than multiple combinational assignments
	exec_mem_process: process(exmem_memory_WE, exmem_loading_notStoring, exmem_ALU_Output, exmem_registerB_Output, d_waitrequest)
	begin
		if falling_edge(d_waitrequest) then
			-- Transaction complete, deassert and capture data
			currData   <= d_readdata;
			d_memread  <= '0';
			d_memwrite <= '0';
			d_address  <= 0;
			d_writedata <= (others => '0');
		elsif exmem_memory_WE = '1' then
			if exmem_loading_notStoring = '1' then
				d_address  <= to_integer(unsigned(exmem_ALU_Output));
				d_memwrite <= '0';
            d_memread  <= '1';
			else
				d_address   <= to_integer(unsigned(exmem_ALU_Output));
            d_memwrite  <= '1';
            d_memread   <= '0';
            d_writedata <= exmem_registerB_Output;
			end if;
		else
			d_address   <= 0;
			d_memwrite  <= '0';
			d_memread   <= '0';
        d_writedata <= (others => '0');
		end if;
	end process;
	
	
	--MEM/WB register updates (clocked process)
	MEMWB_REG : process(clk, reset)
	begin
		if reset = '1' then
			--reset logic for this pipeline stage
			memwb_memory_Output <= (others => '0');
			memwb_ALU_Output <= (others => '0');
			memwb_nextInstructionAddress <= (others => '0');
			memwb_destinationRegister <= (others => '0');
			memwb_writeback_Source_Control <= (others => '0');
			memwb_registerFile_WE <= '0';
		elsif rising_edge(clk) then
			--Pipelined from previous stage
			memwb_ALU_Output <= exmem_ALU_Output;
			memwb_nextInstructionAddress <= exmem_nextInstructionAddress;
			memwb_destinationRegister <= exmem_destinationRegister;
			memwb_writeback_Source_Control <= exmem_writeback_Source_Control;
			memwb_registerFile_WE <= exmem_registerFile_WE;
			
			--Data Memory Output
			memwb_memory_Output <= currData;
		end if;
	end process;
	
	--
	
	--Writeback Combinational Logic
	
	--MUX the memwb_nextInstructionAddress, memwb_ALU_Output, and memwb_memory_Output
	wb_process: process(memwb_writeback_Source_Control, memwb_nextInstructionAddress, memwb_ALU_Output, memwb_memory_Output)
	begin
		if memwb_writeback_Source_Control ="10" then
			wb_write_data <= memwb_nextInstructionAddress;
		elsif memwb_writeback_Source_Control = "01" then
			wb_write_data <= memwb_memory_Output;
		else
			wb_write_data <= memwb_ALU_Output;
		end if;
	end process;
	--
end rtl;
	