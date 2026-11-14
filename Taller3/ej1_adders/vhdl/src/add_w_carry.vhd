-----------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
-----------------------------------------------------------
ENTITY add_w_carry IS
	GENERIC	(	EXTENDED_RANGE	:	INTEGER := 4);
	PORT 		(	a				:	in 	std_logic_vector(EXTENDED_RANGE-1 DOWNTO 0);
					b				: 	in 	std_logic_vector(EXTENDED_RANGE-1 DOWNTO 0);
					cout			: 	out 	std_logic;
					sum			: 	out 	std_logic_vector(EXTENDED_RANGE-1 DOWNTO 0));
END ENTITY add_w_carry;
-----------------------------------------------------------
ARCHITECTURE generic_arch OF add_w_carry IS
	SIGNAL 	a_extended, b_extended, sum_extended	: UNSIGNED(EXTENDED_RANGE DOWNTO 0);
BEGIN
	a_extended 		<= 	unsigned('0' & a);
	b_extended 		<= 	unsigned('0' & b);
	sum_extended 	<= 	a_extended + b_extended;
	sum 				<= 	std_logic_vector(sum_extended(EXTENDED_RANGE-1 downto 0));
	cout 				<= 	sum_extended(EXTENDED_RANGE);
END ARCHITECTURE generic_arch;
-----------------------------------------------------------
