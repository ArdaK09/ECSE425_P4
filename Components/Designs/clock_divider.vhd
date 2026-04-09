library ieee;
use ieee.std_logic_1164.all;

entity clock_divider is
	port (
  			clk_in  : in  std_logic; 
        reset   : in  std_logic; 
        clk_out : out std_logic
    	 );
end clock_divider;

architecture rtl of clock_divider is
	signal clk_reg : std_logic := '0';
begin
	
	divide : process(clk_in)
	begin
			if rising_edge(clk_in) then
					if reset = '1' then
							clk_reg <= '0';
					else
							clk_reg <= not clk_reg;  -- Halves the speed of the output clock...
					end if;
			end if;
	end process;
	clk_out <= clk_reg;
						
end rtl;
