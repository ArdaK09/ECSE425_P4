LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


 -- Purpose:  Evaluates branch conditions in the EX stage. Compares
 --           the two source registers and asserts branch_taken based on branch_op.
 
--  INTERNAL LOGIC:
--    Purely combinatorial PROCESS(rs1_data, rs2_data, branch_op, branch)

--    IF branch = '0': branch_taken <= '0'
--    ELSE:
--      CASE branch_op IS
--        "000" (BEQ):  branch_taken <= '1' WHEN rs1_data = rs2_data
--        "001" (BNE):  branch_taken <= '1' WHEN rs1_data /= rs2_data
--        "100" (BLT):  branch_taken <= '1' WHEN SIGNED(rs1_data) < SIGNED(rs2_data)
--        "101" (BGE):  branch_taken <= '1' WHEN SIGNED(rs1_data) >= SIGNED(rs2_data)
--        OTHERS:       branch_taken <= '0'


ENTITY branching_unit IS 
	PORT(
	rs1_data     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);  -- rs1 (from ID/EX register)
	rs2_data     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);  -- rs2 (from ID/EX register)
	branch_op    : IN  STD_LOGIC_VECTOR(2  DOWNTO 0);  -- branch type (from ID/EX register)
    branch       : IN  STD_LOGIC;                      -- '1' = current instr is branch (branch_enable)
    branch_taken : OUT STD_LOGIC                       -- '1' = condition met, take branch
	);
	
END	branching_unit;
	
ARCHITECTURE logic OF branching_unit IS
BEGIN
	
	PROCESS (rs1_data, rs2_data, branch_op, branch)
	BEGIN
		IF (branch = '0') THEN
			branch_taken <= '0';	
		ELSE 
			CASE branch_op IS	
				WHEN "000" => -- BEQ
					IF (rs1_data = rs2_data) THEN 
						branch_taken <= '1';
					ELSE
						branch_taken <= '0';
					END IF;
					
				WHEN "001" => -- BNE
					IF (rs1_data /= rs2_data) THEN 
						branch_taken <= '1';
					ELSE
						branch_taken <= '0';
					END IF;
					
				WHEN "100" => -- BLT
					IF (SIGNED(rs1_data) < SIGNED(rs2_data)) THEN 
						branch_taken <= '1';
					ELSE
						branch_taken <= '0';
					END IF;
					
				WHEN "101" => -- BGE
					IF (SIGNED(rs1_data) >= SIGNED(rs2_data)) THEN 
						branch_taken <= '1';
					ELSE
						branch_taken <= '0';
					END IF;
					
				WHEN OTHERS =>
					branch_taken <= '0';
					
			END CASE;
		END IF;
	END PROCESS;
END logic;	
	
	
	
	