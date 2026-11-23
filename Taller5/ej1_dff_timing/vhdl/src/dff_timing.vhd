LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
-------------------------------------
ENTITY dff_timing IS
	GENERIC(	DELAY_PULSES							: INTEGER		:= 4);		
	PORT (clk	:	IN		STD_LOGIC;
			rst	:	IN		STD_LOGIC;
			en 	:	OUT	STD_LOGIC;
			d 		: 	OUT	STD_LOGIC;
			q 		:	OUT	STD_LOGIC);
END ENTITY dff_timing;
-------------------------------------
ARCHITECTURE behaviour OF dff_timing IS
	SIGNAL	clk_signal	:	STD_LOGIC;
	SIGNAL	rst_signal	:	STD_LOGIC;
	SIGNAL	en_signal 	:	STD_LOGIC;
	SIGNAL	d_signal 	: 	STD_LOGIC;
	SIGNAL	q_signal 	:	STD_LOGIC;
BEGIN
	DUT: ENTITY work.my_dff
	PORT MAP (		clk				=>	clk_signal,
						rst				=>	rst_signal,
						en 				=>	en_signal,
						d 					=>	d_signal,
						q 					=>	q_signal);
					
	BIST: ENTITY work.test_signal_generator
	GENERIC MAP(	DELAY_PULSES	=>	DELAY_PULSES)
	PORT MAP(		clk 				=>	clk_signal,
						rst				=>	rst_signal,
						data_bit			=>	d_signal,
						en_bit			=>	en_signal);
	
	en 			<=	en_signal;
	d 				<=	d_signal;
	q				<=	q_signal;
	clk_signal	<= clk;
	rst_signal	<= rst;
	

	
END ARCHITECTURE behaviour;