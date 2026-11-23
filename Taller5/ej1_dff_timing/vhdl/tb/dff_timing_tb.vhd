LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
-------------------------------------
ENTITY dff_timing_tb IS
END ENTITY dff_timing_tb;
-------------------------------------
ARCHITECTURE testbench OF dff_timing_tb IS
	CONSTANT	DELAY_PULSES		:	INTEGER	:= 4;
	SIGNAL	clk_tb				:	STD_LOGIC := '0';
	SIGNAL	rst_tb				:	STD_LOGIC := '1';
		
	SIGNAL	en_tb 				:	STD_LOGIC;
	SIGNAL	d_tb 					:	STD_LOGIC;
	SIGNAL	q_tb 					:	STD_LOGIC;
	
	
BEGIN
	--CLOCK GENERATION:------------------------
	clk_tb <= not clk_tb after 10ns; -- 50MHz clock generation
	--RESET GENERATION:------------------------
	rst_tb <= '0' after 150ns;
	
	dut: ENTITY work.dff_timing
	GENERIC MAP(	DELAY_PULSES	=> DELAY_PULSES)
	PORT MAP(		clk				=>	clk_tb,
						rst				=>	rst_tb,
						en 				=>	en_tb,
						d 					=>	d_tb,
						q 					=>	q_tb);
	
END ARCHITECTURE testbench;