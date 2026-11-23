LIBRARY IEEE;
	USE IEEE.STD_LOGIC_1164.ALL;
	USE IEEE.numeric_std.all;
--------------------------------------------------------
ENTITY test_signal_generator IS
	GENERIC(	DELAY_PULSES							: INTEGER		:= 4);		
	PORT (	clk 										:	IN  STD_LOGIC;
				rst										:	IN  STD_LOGIC;
				data_bit									:	OUT STD_LOGIC;
				en_bit									:	OUT STD_LOGIC
				);
END ENTITY test_signal_generator;
----------------------------------------------------------
ARCHITECTURE rtl OF test_signal_generator IS
	TYPE state IS (zero, clearFlagZero, one, clearFlagOne);
	SIGNAL	pr_state, nx_state : state;
	
	SIGNAL	toggle_flag		:	STD_LOGIC;
	SIGNAL	clrFlag			:	STD_LOGIC;
	SIGNAL	enCounter		:	STD_LOGIC;
	SIGNAL	counter			: 	INTEGER RANGE 0 TO DELAY_PULSES;
	
	
		
BEGIN

	
	lower_fsm: PROCESS (clk, rst)
	BEGIN
		IF (rst = '1') THEN
			pr_state <= zero;
		ELSIF (rising_edge(clk)) THEN
			pr_state <= nx_state;
		END IF;
	END PROCESS lower_fsm;
	
	--========================================================
	--Upper part FSM
	--========================================================
	upper_fsm: PROCESS(pr_state, clk, toggle_flag)
	BEGIN
		CASE pr_state IS
			------------------------------------------------------
			WHEN zero => 
				data_bit		<=	'0';
				en_bit		<=	'1';
				clrFlag		<=	'0';
				enCounter	<=	'1';
				IF (toggle_flag = '1') THEN
					nx_state	<=	clearFlagZero;
				ELSE
					nx_state	<=	zero;
				END IF;	
			------------------------------------------------------
			WHEN clearFlagZero => 
				data_bit		<=	'0';
				en_bit		<=	'1';
				clrFlag		<=	'1';
				enCounter	<=	'0';	
				nx_state		<=	one;
			------------------------------------------------------
			WHEN one => 
				data_bit		<=	'1';
				en_bit		<=	'1';
				clrFlag		<=	'0';
				enCounter	<=	'1';
				IF (toggle_flag = '1') THEN
					nx_state	<=	clearFlagOne;
				ELSE
					nx_state	<=	one;
				END IF;
			------------------------------------------------------
			WHEN clearFlagOne => 
				data_bit		<=	'0';
				en_bit		<=	'1';
				clrFlag		<=	'1';
				enCounter	<=	'0';
				nx_state		<=	zero;	
			------------------------------------------------------
		END CASE;
	end process;
	
	--========================================================
	--	Delay Counter Process
	--========================================================	
	delay_counter: PROCESS (clk, rst,clrFlag)
	BEGIN
		IF (rst = '1') THEN
			counter			<= 0;
			toggle_flag		<=	'0';
		ELSIF (rising_edge(clk)) THEN
			IF (clrFlag= '1') THEN
				counter			<= 0;
				toggle_flag		<=	'0';
			ELSIF (enCounter = '1') THEN
				counter		<= counter +1;
				IF (counter < DELAY_PULSES-1) THEN
					toggle_flag	<=	'0';
				ELSE
					counter		<= 0;
					toggle_flag	<=	'1';
				END IF;
			END IF;
		END IF;
	END PROCESS delay_counter;
	
	
END ARCHITECTURE rtl;