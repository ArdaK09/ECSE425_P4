library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_decoder is 
port(	instruction_input : in std_logic_vector(31 downto 0);
		loading_notStoring : out std_logic;
		ALU_Operation : out std_logic_vector(9 downto 0);
		memory_WE : out std_logic;
		registerFile_WE : out std_logic;
		inputA_MUX_Control : out std_logic := '0';
		inputB_MUX_Control : out std_logic := '0';
		branching_Enabled : out std_logic;
		branching_Operation : out std_logic_vector(2 downto 0);
		writeback_Source_Control : out std_logic_vector(1 downto 0);
		registerA : out std_logic_vector(4 downto 0);
		registerB :out std_logic_vector(4 downto 0);
		immediate : out std_logic_vector(31 downto 0);
		destinationRegister : out std_logic_vector(4 downto 0)
);
end instruction_decoder;

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
rd <= instruction_input(11 downto 7);
funct3 <= instruction_input(14 downto 12);
rs1 <= instruction_input(19 downto 15);
rs2 <= instruction_input(24 downto 20);
funct7 <= instruction_input(31 downto 25);

--Determine Instruction type and, depending on type, fill in control signals (outs)
process(opcode, funct3, funct7, rs1, rs2, rd, instruction_input)
	begin
		case opcode is


			--R-type instruction
			when "0110011" =>
				loading_notStoring <= '0'; --DONT CARE
				ALU_Operation <= funct3 & funct7; --Concatenate, allowing ALU to do the decoding...
				memory_WE <= '0'; --active high as per pipelined_cpu specifications
				registerFile_WE <= '1'; --active high as per register_file specifications
				--Need rs1 and rs2
				inputA_MUX_Control <= '0'; --rs1
				inputB_MUX_Control <= '0'; --rs2
				branching_Enabled <= '0';
				branching_Operation <= "000"; --DONT CARE
				writeback_Source_Control <= "00"; --ALU Output
				registerA <= rs1;
				registerB <= rs2;
				immediate <= (others => '0'); --DONT CARE
				destinationRegister <= rd;
				
				
			--I-type instruction
			when "0010011" =>
				loading_notStoring <= '0'; --DONT CARE
				ALU_Operation <= funct3 & "0000000"; --Allow ALU to do the decoding
				memory_WE <= '0';
				registerFile_WE <= '1';
				--Need rs1 and Immediate
				inputA_MUX_Control <= '0'; --rs1
				inputB_MUX_Control <= '1'; --Imm
				branching_Enabled <= '0';
				branching_Operation <= "000"; --DONT CARE
				writeback_Source_Control <= "00"; --ALU Output
				registerA <= rs1;
				registerB <= rs2;
				immediate <= std_logic_vector(resize(signed(instruction_input(31 downto 20)), 32));
				destinationRegister <= rd;

				
			--Load Instructions (I-type)
			when "0000011" =>
				loading_notStoring <= '1';
				ALU_Operation <= "0000000000"; --Output = rs1 + Immediate
				memory_WE <= '1';
				registerFile_WE <= '1';
				--Need rs1 and Immediate
				inputA_MUX_Control <= '0';
				inputB_MUX_Control <= '1';
				branching_Enabled <= '0';
				branching_Operation <= "000"; --DONT CARE
				--Data Memory output here!!
				writeback_Source_Control <= "01"; --Data Memory Output
				registerA <= rs1;
				registerB <= rs2;
				--Fixing immediate field
				immediate <= std_logic_vector(resize(signed(instruction_input(31 downto 20)),32));
				destinationRegister <= rd;
				
				
			--B-type instruction
			when "1100011" =>
				loading_notStoring <= '0'; --DONT CARE
				ALU_Operation <= "0000000000"; --Output = PC + Immediate
				memory_WE <= '0';
				registerFile_WE <= '0';
				--Need PC and Immediate
				inputA_MUX_Control <= '1';
				inputB_MUX_Control <= '1';
				branching_Enabled <= '1';
				branching_Operation <= funct3; --Mapping works!
				writeback_Source_Control <= "00"; --DONT CARE
				registerA <= rs1;
				registerB <= rs2;
				--Unscrambling immediate value
				immediate <= std_logic_vector(resize(signed(instruction_input(31) & instruction_input(7) & instruction_input(30 downto 25) & instruction_input(11 downto 8) & '0'),32));
				destinationRegister <= rd;

				
			--Store Instructions (S-type)
			when "0100011" =>
				loading_notStoring <= '0';
				ALU_Operation <= "0000000000"; --Output = rs1 + Immediate
				memory_WE <= '1';
				registerFile_WE <= '0';
				--Need rs1 and Immediate
				inputA_MUX_Control <= '0';
				inputB_MUX_Control <= '1';
				branching_Enabled <= '0';
				branching_Operation <= "000"; --DONT CARE
				writeback_Source_Control <= "00"; --DONT CARE
				registerA <= rs1;
				registerB <= rs2;
				--Unscrambling immediate value
				immediate <=std_logic_vector(resize(signed(instruction_input(31 downto 25) & instruction_input(11 downto 7)),32));
				destinationRegister <= rd;

				
			--JAL Instruction (J-type)
			when "1101111" =>
				loading_notStoring <= '0'; --DONT CARE
				ALU_Operation <= "0000000000"; --Output = PC + Immediate
				memory_WE <= '0';
				registerFile_WE <= '1';
				inputA_MUX_Control <= '1';
				inputB_MUX_Control <= '1';
				branching_Enabled <= '1';
				branching_Operation <= "000"; --DONT CARE
				writeback_Source_Control <= "10"; --Jump Output (nextInstructionAddress)
				registerA <= "00000";
				registerB <= "00000";
				--Unscrambling immediate value
				immediate <= std_logic_vector(resize(signed(instruction_input(31) & instruction_input(19 downto 12) & instruction_input(20) & instruction_input(30 downto 21) & '0'),32));
				destinationRegister <= rd;

				
			--JALR Instruction (I-type)	
			when "1100111" =>	
				loading_NotStoring <= '0'; --DONT CARE
				ALU_Operation <= "0000000000"; --Output = rs1 + Immediate
				memory_WE <= '0';
				registerFile_WE <= '1';
				inputA_MUX_Control <= '0'; --rs1
				inputB_MUX_Control <= '1'; --Immediate
				branching_Enabled <= '1';
				branching_Operation <= "000";
				writeback_Source_Control <= "10"; --PC + 4 Output
				--Unconditional Branching!
				registerA <= rs1;
				registerB <= rs1;
				--Unscrambling immediate value
				immediate <= std_logic_vector(resize(signed(instruction_input(31 downto 20)),32));
				destinationRegister <= rd;
				
				
			--LUI Instruction (U-type)
			when "0110111" =>
				loading_notStoring <= '0'; --DONT CARE
				ALU_Operation <= "0000000000"; --Output = 0 + Immediate
				memory_WE <= '0';
				registerFile_WE <= '1';
				inputA_MUX_Control <= '0'; --rs1 (=0)
				inputB_MUX_Control <= '1'; --Immediate
				branching_Enabled <= '0';
				branching_Operation <= "000"; --DONT CARE
				writeback_Source_Control <= "00"; --ALU Output
				registerA <= "00000"; --Necessity to push immediate through ALU with no changes
				registerB <= "00000"; --DONT CARE
				--Unscambling immediate value
				immediate <= instruction_input(31 downto 12) & x"000";
				destinationRegister <= rd;

				
			--AUIPC Instruction (U-type)	
			when "0010111" =>
				loading_notStoring <= '0'; --DONT CARE
				ALU_Operation <= "0000000000"; --Output = PC + Immediate
				memory_WE <= '0';
				registerFile_WE <= '1';
				inputA_MUX_Control <= '1'; --PC
				inputB_MUX_Control <= '1'; --Immediate
				branching_Enabled <= '0';
				branching_Operation <= "000"; --DONT CARE
				writeback_Source_Control <= "00"; --ALU Output
				registerA <= "00000"; --DONT CARE
				registerB <= "00000"; --DONT CARE
				--Unscambling immediate value
				immediate <= instruction_input(31 downto 12) & x"000";
				destinationRegister <= rd;	
			
			when others =>	--NOP
				loading_notStoring <= '0';
				ALU_Operation <= "0000000000";
				memory_WE <= '0';
				registerFile_WE <= '0';
				inputA_MUX_Control <= '0';
				inputB_MUX_Control <= '0';
				branching_Enabled <= '0';
				branching_Operation <= "000";
				writeback_Source_Control <= "00";
				registerA <= "00000";
				registerB <= "00000";
				immediate <= (others => '0');
				destinationRegister <= "00000";
			
		end case;
	end process;
end arch;
