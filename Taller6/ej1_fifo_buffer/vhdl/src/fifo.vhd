LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
--------------------------------------------
ENTITY fifo IS
	GENERIC ( ADDR_WIDTH	: 	INTEGER:=2;
				DATA_WIDTH 	: 	INTEGER:=8);
	PORT(		clk			:	IN		STD_LOGIC;
				reset			:	IN		STD_LOGIC;
				rd				:	IN		STD_LOGIC;
				wr				:	IN		STD_LOGIC;
				w_data		: 	IN		STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
				empty			:	OUT	STD_LOGIC;
				full 			:	OUT	STD_LOGIC;
				r_data		: 	OUT 	STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0));
END ENTITY;
--------------------------------------------
ARCHITECTURE structural OF fifo IS
	SIGNAL full_s		: STD_LOGIC;
	signal wr_en		: STD_LOGIC;
	signal w_addr_s	: STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
	signal r_addr_s	: STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
BEGIN
	--write enable only when FIFO is not full
	wr_en <= wr and (not full_s);
	full <= full_s;
	-- instatiate fifo control unit
	ctrl_unit : entity work.fifo_ctrl
		GENERIC MAP(	ADDR_WIDTH	=>	ADDR_WIDTH)
		PORT MAP(		clk			=>	clk, 
							reset			=>	reset,
							rd				=>	rd, 
							wr				=>	wr,
							empty			=>	empty,
							full			=>	full_s,
							w_addr		=>	w_addr_s,
							r_addr		=>	r_addr_s);
	-- instatiate register file
	reg_file_unit:	ENTITY work.register_file
		GENERIC MAP(	ADDR_WIDTH	=>	ADDR_WIDTH, 
							DATA_WIDTH 	=>	DATA_WIDTH)
		PORT MAP		(	clk			=>	clk,
							w_addr		=>	w_addr_s,
							r_addr		=>	r_addr_s,
							w_data		=>	w_data,
							r_data		=>	r_data,
							wr_en			=>	wr_en);
END ARCHITECTURE;
----------------------------------------------

	
		

	