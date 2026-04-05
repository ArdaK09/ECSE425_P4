library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is 
	port (
		alu_op : in std_logic_vector(3 downto 0);
		rs1 : in std_logic_vector(31 downto 0);
		rs2 : in std_logic_vector(31 downto 0);
		rd : out std_logic_vector(31 downto 0)
);
end ALU;

architecture behavioral of alu is

begin

    process(alu_op, rs1, rs2)
    begin
        case alu_op is

            when "0001" =>  -- ADD
                rd <= std_logic_vector(unsigned(rs1) + unsigned(rs2));

            when "0010" =>  -- SUB
                rd <= std_logic_vector(unsigned(rs1) - unsigned(rs2));
					 
				when "0011" =>  -- MUL
                rd <= std_logic_vector(resize(signed(rs1) * signed(rs2), 32));

            when "0100" =>  -- AND
                rd <= rs1 and rs2;

            when "0101" =>  -- OR
                rd <= rs1 or rs2;

            when "0110" =>  -- XOR
                rd <= rs1 xor rs2;

            when "0111" =>  -- SLL
                rd <= std_logic_vector(shift_left(unsigned(rs1), to_integer(unsigned(rs2(4 downto 0)))));

            when "1000" =>  -- SRL
                rd <= std_logic_vector(shift_right(unsigned(rs1), to_integer(unsigned(rs2(4 downto 0)))));

            when "1001" =>  -- SRA
                rd <= std_logic_vector(shift_right(signed(rs1), to_integer(unsigned(rs2(4 downto 0)))));

            when "1010" =>  -- SLT
                if signed(rs1) < signed(rs2) then
                    rd <= x"00000001";
                else
                    rd <= x"00000000";
                end if;


            when others =>
                rd <= x"00000000";

        end case;
    end process;


end behavioral;