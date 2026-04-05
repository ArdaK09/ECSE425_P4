LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY branching_unit_tb IS
END branching_unit_tb;

ARCHITECTURE testbench OF branching_unit_tb IS
	COMPONENT branching_unit IS
		PORT(
			rs1_data     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			rs2_data     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			branch_op    : IN  STD_LOGIC_VECTOR(2  DOWNTO 0);
			branch       : IN  STD_LOGIC;
			branch_taken : OUT STD_LOGIC
		);
	END COMPONENT;

	SIGNAL rs1_data, rs2_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL branch_op : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL branch, branch_taken : STD_LOGIC;

BEGIN
	uut: branching_unit PORT MAP(rs1_data, rs2_data, branch_op, branch, branch_taken);

	PROCESS
	BEGIN
		branch <= '0';
		WAIT FOR 1 ns;
		ASSERT branch_taken = '0' REPORT "Branch disabled test failed" SEVERITY ERROR;

		-- BEQ: Equal
		branch <= '1';
		branch_op <= "000";
		rs1_data <= X"12345678";
		rs2_data <= X"12345678";
		WAIT FOR 1 ns;
		ASSERT branch_taken = '1' REPORT "BEQ equal test failed" SEVERITY ERROR;

		-- BEQ: Not equal
		rs2_data <= X"87654321";
		WAIT FOR 1 ns;
		ASSERT branch_taken = '0' REPORT "BEQ not equal test failed" SEVERITY ERROR;

		-- BNE: Not equal
		branch_op <= "001";
		WAIT FOR 1 ns;
		ASSERT branch_taken = '1' REPORT "BNE not equal test failed" SEVERITY ERROR;

		-- BNE: Equal
		rs2_data <= X"12345678";
		WAIT FOR 1 ns;
		ASSERT branch_taken = '0' REPORT "BNE equal test failed" SEVERITY ERROR;

		-- BLT: 5 < 10 (signed)
		branch_op <= "100";
		rs1_data <= X"00000005";
		rs2_data <= X"0000000A";
		WAIT FOR 1 ns;
		ASSERT branch_taken = '1' REPORT "BLT less than test failed" SEVERITY ERROR;

		-- BLT: 10 >= 5 (signed)
		rs1_data <= X"0000000A";
		rs2_data <= X"00000005";
		WAIT FOR 1 ns;
		ASSERT branch_taken = '0' REPORT "BLT greater than test failed" SEVERITY ERROR;

		-- BGE: 10 >= 5 (signed)
		branch_op <= "101";
		WAIT FOR 1 ns;
		ASSERT branch_taken = '1' REPORT "BGE greater than test failed" SEVERITY ERROR;

		-- BGE: 5 < 10 (signed)
		rs1_data <= X"00000005";
		rs2_data <= X"0000000A";
		WAIT FOR 1 ns;
		ASSERT branch_taken = '0' REPORT "BGE less than test failed" SEVERITY ERROR;

		REPORT "All tests completed";
		WAIT;
	END PROCESS;

END testbench;

