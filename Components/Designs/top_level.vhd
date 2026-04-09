library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;
 
entity top_level is
    port(
        clk : in std_logic;
        reset : in std_logic
    );
end top_level;
 
architecture arch of top_level is
 
    constant ram_size : integer := 8192;
 
    -- Instruction memory signals
    signal i_writedata : std_logic_vector(31 downto 0);
    signal i_address : integer range 0 to ram_size-1;
    signal i_memwrite : std_logic;
    signal i_memread : std_logic;
    signal i_readdata : std_logic_vector(31 downto 0);
    signal i_waitrequest : std_logic;
 
    -- Data memory signals
    signal d_writedata : std_logic_vector(31 downto 0);
    signal d_address : integer range 0 to ram_size-1;
    signal d_memwrite : std_logic;
    signal d_memread : std_logic;
    signal d_readdata : std_logic_vector(31 downto 0);
    signal d_waitrequest : std_logic;

	--Clock Divider Signal 
	signal clk_divider : std_logic := '0';
 
    component memory is
        port(
            clock : in std_logic;
            writedata : in  std_logic_vector(31 downto 0);
            address : in  integer range 0 to ram_size-1;
            memwrite : in  std_logic;
            memread : in  std_logic;
            readdata : out std_logic_vector(31 downto 0);
            waitrequest : out std_logic
        );
    end component;
 
    component pipelined_cpu is
        port(
            clk : in  std_logic;
            reset : in  std_logic;
 
            -- Instruction Avalon Interface
            i_writedata : out std_logic_vector(31 downto 0);
            i_address : out integer range 0 to ram_size-1;
            i_memwrite : out std_logic;
            i_memread : out std_logic;
            i_readdata : in std_logic_vector(31 downto 0);
            i_waitrequest : in std_logic;
 
            -- Data Avalon Interface
            d_writedata : out std_logic_vector(31 downto 0);
            d_address : out integer range 0 to ram_size-1;
            d_memwrite : out std_logic;
            d_memread : out std_logic;
            d_readdata : in std_logic_vector(31 downto 0);
            d_waitrequest : in std_logic
        );
    end component;

    component clock_divider is
    	port (
				clk_in : in std_logic;
        		reset : in std_logic;
        		clk_out : out std_logic
    		);
	end component;
 
begin
 
    instruction_memory : memory
        port map(
            clock => clk,
            writedata => i_writedata,
            address => i_address,
            memwrite => i_memwrite,
            memread => i_memread,
            readdata => i_readdata,
            waitrequest => i_waitrequest
        );
 
    data_memory : memory
        port map(
            clock => clk,
            writedata => d_writedata,
            address => d_address,
            memwrite => d_memwrite,
            memread => d_memread,
            readdata => d_readdata,
            waitrequest => d_waitrequest
        );
		
 	cpu_clock_divider : clock_divider
		port map(
				clk_in => clk,
				reset => reset,
				clk_out => clk_divider
				);
		
    processor : pipelined_cpu
        port map(
            clk => clk_divider,
            reset => reset,
 
            i_writedata => i_writedata,
            i_address => i_address,
            i_memwrite => i_memwrite,
            i_memread => i_memread,
            i_readdata => i_readdata,
            i_waitrequest => i_waitrequest,
 
            d_writedata => d_writedata,
            d_address => d_address,
            d_memwrite => d_memwrite,
            d_memread => d_memread,
            d_readdata => d_readdata,
            d_waitrequest => d_waitrequest
        );
 
end architecture arch;
