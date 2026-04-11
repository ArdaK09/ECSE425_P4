library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is
	port(
		clk : in std_logic;
		reset : in std_logic;
		stall : in std_logic;
		jump_or_branch_condition : in std_logic;
		jump_or_branch_addr : in std_logic_vector(31 downto 0);
		pc_out : out std_logic_vector(31 downto 0);
		pc_plus4_out : out std_logic_vector(31 downto 0)
	);
end program_counter;

architecture rtl of program_counter is
	signal counter_register : std_logic_vector(31 downto 0) := (others => '0');
	signal counter_next : std_logic_vector(31 downto 0);
	signal counter_plus4 : std_logic_vector(31 downto 0);
begin
	--Combinational logic
	--Set counter + (size of word addr)
	counter_plus4 <= std_logic_vector(unsigned(counter_register) + 4); -- used to be plus 4 but the memory is now word addressable
	
	--MUX the branch/jump with the (counter + 4). If branch condition high, next set to the branch/jump address, else, set to (counter + 4)

	branch: process (jump_or_branch_condition, jump_or_branch_addr)
	begin
		if jump_or_branch_condition = '1' then
			counter_next <= jump_or_branch_addr;
		else
			counter_next <= counter_plus4;
		end if;
	end process;
	
	--Register update logic
	update_register: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				--reset counter
				counter_register <= (others => '0');
			elsif stall = '1' then
				--stall counter
				counter_register <= counter_register;
			else
				--updated counter
				counter_register <= counter_next;
			end if;
			pc_out <= counter_register;
			pc_plus4_out <= counter_plus4;
		end if;	
	end process;
	
	
end rtl;