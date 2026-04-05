LIBRARY ieee;

USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY register_file IS
  PORT(
    -- Clock and reset
    clk        : IN  STD_LOGIC;                     -- rising-edge system clock
    reset      : IN  STD_LOGIC;                     -- synchronous active-high reset

    -- Write port
    reg_write  : IN  STD_LOGIC;                     -- write enable (active-high)
    rd_addr    : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);  -- destination register address
    write_data : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); -- data written when reg_write is high

    -- Read port 1
    rs1_addr   : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);  -- source register 1 address
    rs1_data   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- source register 1 data (combinational)

    -- Read port 2
    rs2_addr   : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);  -- source register 2 address
    rs2_data   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));  -- source register 2 data (combinational)

END ENTITY register_file;

ARCHITECTURE rtl OF register_file IS

	--Array of 32 32 bit registers, we will skip zero
	TYPE reg_array IS ARRAY(0 TO 31) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL all_regs : reg_array;

	BEGIN

	-- ---------------------------------------------------------------------------
	-- Synchronous write
	-- reset first
	-- ---------------------------------------------------------------------------
	write_proc : PROCESS(clk)
		BEGIN
			IF rising_edge(clk) THEN
				IF reset = '1' THEN
				-- Clear all 32 registers synchronously
					FOR i IN 0 TO 31 LOOP
						all_regs(i) <= (OTHERS => '0');
					END LOOP;
				ELSIF reg_write = '1' THEN
				-- Write only when enabled and target is not the zero register	
					all_regs(to_integer(unsigned(rd_addr))) <= write_data;
			END IF;
		END IF;
	END PROCESS write_proc;
	

-- Asynchronous reads
-- Address 0 always returns zero
-- Pretty straight forward, access the array index by converting the input std_logic into unsigned then integer, set the output to the value
	
	rs1_data <= (OTHERS => '0') WHEN rs1_addr = "00000"
	ELSE all_regs(to_integer(unsigned(rs1_addr)));
	
	rs2_data <= (OTHERS => '0') WHEN rs2_addr = "00000"
	ELSE all_regs(to_integer(unsigned(rs2_addr)));
	
END ARCHITECTURE rtl;
