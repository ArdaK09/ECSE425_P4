library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_decoder is 
port(	instruction_input : in std_logic_vector(31 downto 0);
		Loading_NotStoring : out std_logic;
		ALU_Operation : out std_logic_vector(3 downto 0);
		Memeory_WE : out std_logic;
		RegisterFile_WE : out std_logic;
		InputA_MUX_Control : out std_logic;
		InputB_MUX_Control : out std_logic;
		Branching_Enabled : out std_logic;
		Branching_Operation : out std_logic_vector(2 downto 0);
		Writeback_Source_Control : out std_logic;
		RegisterA : out std_logic_vector(4 downto 0);
		RegisterB :out std_logic_vector(4 downto 0);
		Immediate : out std_logic_vector(31 downto 0);
		DesinationRegister : out std_logic(4 downto 0)
);
end instruction_decoder

architecture arch of instruction_decoder is

--Initial breakdown of the input
signal opcode : std_logic_vector(6 downto 0);
signal rd : std_logic_vector(4 downto 0);
signal funct3 : std_logic_vector(2 downto 0);
signal rs1 : std_logic_vector(4 downto 0);
signal rs2: std_logic_vector(4 downto 0);
signal funct7: std_logic_vector(6 downto 0);

begin

--Extract common fields
opcode <= instruction_input(6 downto 0);
rd <= instruction_input(4 downto 0);
fucnt3 <= instruction_input(2 downto 0);
rs1 <= instruction_input(4 downto 0);
rs2 <= instruction_input(4 downto 0);
funct7 <= instruction_input(6 downto 0);

--Determine Instruction type and, depending on type, fill in control signals (outs)
case opcode is
	--R-type instruction
	when "0110011" =>
		--do this
		Loading_NotStoring <= '-';
		ALU_Operation <= funct3;
		Memeory_WE <= '0';
		RegisterFile_WE <= '1';
		--Need rs1 and rs2
		InputA_MUX_Control <= '0';
		InputB_MUX_Control <= '0';
		Branching_Enabled <= '0';
		Branching_Operation <= '-';
		Writeback_Source_Control <= '0';
		RegisterA <= rs1;
		RegisterB <= rs2;
		Immediate <= (others => '-');
		DestinationRegister <= rd;
	--I-type instruction
	when "0010011" | "1100111" =>
		Loading_NotStoring <= '-';
		ALU_Operation <= funct3;
		Memeory_WE <= '0';
		RegisterFile_WE <= '1';
		--Need rs1 and Immediate
		InputA_MUX_Control <= '0';
		InputB_MUX_Control <= '1';
		Branching_Enabled <= '0';
		Branching_Operation <= '-';
		Writeback_Source_Control <= '0';
		RegisterA <= rs1;
		RegisterB <= rs2;
		Immediate <= instruction_input(31 downto 20);
		DestinationRegister <= rd;
		--do this
	--Single load instruction we are able to do
	when "0000011" =>
		Loading_NotStoring <= '1';
		ALU_Operation <= '000';
		Memeory_WE <= '1';
		RegisterFile_WE <= '1';
		--Need rs1 and Immediate
		InputA_MUX_Control <= '0';
		InputB_MUX_Control <= '1';
		Branching_Enabled <= '0';
		Branching_Operation <= '-';
		--Data Memory output here!!
		Writeback_Source_Control <= '1';
		RegisterA <= rs1;
		RegisterB <= rs2;
		Immediate <= instruction_input(31 downto 20);
		DestinationRegister <= rd;
	--B-type instruction
	when "1100011" =>
		Loading_NotStoring <= '-';
		ALU_Operation <= '000';
		Memeory_WE <= '0';
		RegisterFile_WE <= '0';
		--Need PC and Immediate
		InputA_MUX_Control <= '1';
		InputB_MUX_Control <= '1';
		Branching_Enabled <= '1';
		Branching_Operation <= funct3;
		Writeback_Source_Control <= '-';
		RegisterA <= rs1;
		RegisterB <= rs2;
		--Unscrambling immediate value
		Immediate <= instruction_input(31) & instruction_input(7) & instruction_input(30 downto 25) & instruction_input(11 downto 8);
		DestinationRegister <= rd;
		--do this
	--S-type instruction
	when "0100011" =>
		Loading_NotStoring <= '0';
		ALU_Operation <= '000';
		Memeory_WE <= '1';
		RegisterFile_WE <= '0';
		--Need rs1 and Immediate
		InputA_MUX_Control <= '0';
		InputB_MUX_Control <= '1';
		Branching_Enabled <= '0';
		Branching_Operation <= '-';
		Writeback_Source_Control <= '-';
		RegisterA <= rs1;
		RegisterB <= rs2;
		--Unscrambling immediate value
		Immediate <= (others => '-');
		DestinationRegister <= rd;
		--do this
	--J-type instruction
	when "1101111" =>
		Loading_NotStoring <= '-';
		ALU_Operation <= funct3;
		Memeory_WE <= '0';
		RegisterFile_WE <= '1';
		InputA_MUX_Control <= '0';
		InputB_MUX_Control <= '0';
		Branching_Enabled <= '0';
		Branching_Operation <= '-';
		Writeback_Source_Control <= '0';
		RegisterA <= rs1;
		RegisterB <= rs2;
		--Unscrambling immediate value
		Immediate <= (others => '-');
		DestinationRegister <= rd;
		--do this
	--U-type instruction
	when "0110111" | "0010111" =>
		Loading_NotStoring <= '-';
		ALU_Operation <= '001';
		Memeory_WE <= '0';
		RegisterFile_WE <= '1';
		InputA_MUX_Control <= '0';
		InputB_MUX_Control <= '0';
		Branching_Enabled <= '0';
		Branching_Operation <= '-';
		Writeback_Source_Control <= '0';
		RegisterA <= rs1;
		RegisterB <= rs2;
		--Unscambling immediate value
		Immediate <= (others => '-');
		DestinationRegister <= rd;
		--do this
	
	when others =>
	
end case;