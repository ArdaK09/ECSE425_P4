library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is 
	port (
		alu_op : in std_logic_vector(9 downto 0);
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
            --Follows format of (funct3 & funct7 for most inputs)
            when "0000000000" =>  -- ADD (0x0 & 0x00)
                rd <= std_logic_vector(unsigned(rs1) + unsigned(rs2));

            when "0000100000" =>  -- SUB (0x0 & 0x20)
                rd <= std_logic_vector(unsigned(rs1) - unsigned(rs2));
					 
				when "0000000001" =>  -- MUL (0x0 & 0x01)
                rd <= std_logic_vector(resize(signed(rs1) * signed(rs2), 32));

            when "1110000000" =>  -- AND (0x7 & 0x00)
                rd <= rs1 and rs2;

            when "1100000000" =>  -- OR (0x6 & 0x00)
                rd <= rs1 or rs2;

            when "1000000000" =>  -- XOR (0x4 & 0x00)
                rd <= rs1 xor rs2;

            when "0010000000" =>  -- SLL (0x1 & 0x00)
                rd <= std_logic_vector(shift_left(unsigned(rs1), to_integer(unsigned(rs2(4 downto 0)))));

            when "1010000000" =>  -- SRL (0x5 & 0x00)
                rd <= std_logic_vector(shift_right(unsigned(rs1), to_integer(unsigned(rs2(4 downto 0)))));

            when "1010100000" =>  -- SRA (0x5 & 0x20)
                rd <= std_logic_vector(shift_right(signed(rs1), to_integer(unsigned(rs2(4 downto 0)))));

            when "0100000000" =>  -- SLT (0x2 & 0x00)
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