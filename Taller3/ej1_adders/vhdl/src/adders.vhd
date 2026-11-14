-----------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
-----------------------------------------------------------
ENTITY adders IS
	GENERIC	(	LARGE			:	INTEGER := 16;
					SMALL			:	INTEGER := 8);
	PORT 	(		a				:	in 	std_logic_vector(SMALL-1 DOWNTO 0);
					b				: 	in 	std_logic_vector(SMALL-1 DOWNTO 0);
					c				:	in 	std_logic_vector(LARGE-1 DOWNTO 0);
					d				: 	in 	std_logic_vector(LARGE-1 DOWNTO 0);
					cout8			: 	out 	std_logic;
					sum8			: 	out 	std_logic_vector(SMALL-1 DOWNTO 0);
					cout16		: 	out 	std_logic;
					sum16			: 	out 	std_logic_vector(LARGE-1 DOWNTO 0));
END ENTITY adders;
-----------------------------------------------------------
ARCHITECTURE rtl OF adders IS
BEGIN
	adder_8bits: entity work.add_w_carry
		GENERIC MAP	(	EXTENDED_RANGE	=> SMALL)
		PORT MAP	(		a					=>	a,
							b					=>	b,
							cout				=>	cout8,
							sum				=>	sum8);
	
	adder_16bits: entity work.add_w_carry
		GENERIC MAP	(	EXTENDED_RANGE	=> LARGE)
		PORT MAP	(		a					=>	c,
							b					=>	d,
							cout				=>	cout16,
							sum				=>	sum16);
	
END ARCHITECTURE rtl;
-----------------------------------------------------------