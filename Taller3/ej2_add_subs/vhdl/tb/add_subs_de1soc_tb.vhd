library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================================================================
-- Testbench: add_subs_de1soc_tb (VHDL)
-- Verifica los 7 casos ilustrativos de la Figura 3 del enunciado antes de
-- descargar el diseño en la tarjeta DE1-SoC.
-- ============================================================================

entity add_subs_de1soc_tb is
end entity add_subs_de1soc_tb;

architecture Behavioral of add_subs_de1soc_tb is
    component add_subs_de1soc is
        port (
            SW   : in  std_logic_vector(9 downto 0);
            LEDR : out std_logic_vector(9 downto 0);
            HEX0 : out std_logic_vector(6 downto 0);
            HEX1 : out std_logic_vector(6 downto 0);
            HEX2 : out std_logic_vector(6 downto 0);
            HEX3 : out std_logic_vector(6 downto 0);
            HEX4 : out std_logic_vector(6 downto 0);
            HEX5 : out std_logic_vector(6 downto 0)
        );
    end component;

    signal sw_tb   : std_logic_vector(9 downto 0) := (others => '0');
    signal ledr_tb : std_logic_vector(9 downto 0);
    signal hex0_tb : std_logic_vector(6 downto 0);
    signal hex1_tb : std_logic_vector(6 downto 0);
    signal hex2_tb : std_logic_vector(6 downto 0);
    signal hex3_tb : std_logic_vector(6 downto 0);
    signal hex4_tb : std_logic_vector(6 downto 0);
    signal hex5_tb : std_logic_vector(6 downto 0);

    constant T_STEP : time := 20 ns;
begin
    DUT: add_subs_de1soc
        port map (
            SW   => sw_tb,
            LEDR => ledr_tb,
            HEX0 => hex0_tb,
            HEX1 => hex1_tb,
            HEX2 => hex2_tb,
            HEX3 => hex3_tb,
            HEX4 => hex4_tb,
            HEX5 => hex5_tb
        );

    stim_proc: process
        type fig3_vec_t is record
            a_val : integer;
            b_val : integer;
            op    : std_logic;
            exp2  : std_logic_vector(6 downto 0);
            exp1  : std_logic_vector(6 downto 0);
            exp0  : std_logic_vector(6 downto 0);
        end record;

        type fig3_array_t is array (natural range <>) of fig3_vec_t;
        constant FIG3_CASES : fig3_array_t := (
            (5,  3,  '1', "1111111", "1111111", "0000000"), --  5 +  3 =   8
            (5,  3,  '0', "1111111", "1111111", "0100100"), --  5 -  3 =   2
            (3,  5,  '0', "0111111", "1111111", "0100100"), --  3 -  5 =  -2
            (15, 15, '1', "1111111", "0110000", "1000000"), -- 15 + 15 =  30
            (13, 2,  '1', "1111111", "1111001", "0010010"), -- 13 +  2 =  15
            (7,  15, '0', "0111111", "1111111", "0000000"), --  7 - 15 =  -8
            (1,  15, '0', "0111111", "1111001", "0011001")  --  1 - 15 = -14
        );

        variable errors : integer := 0;
    begin
        for idx in FIG3_CASES'range loop
            sw_tb(9)          <= FIG3_CASES(idx).op;
            sw_tb(8)          <= '0';
            sw_tb(7 downto 4) <= std_logic_vector(to_unsigned(FIG3_CASES(idx).a_val, 4));
            sw_tb(3 downto 0) <= std_logic_vector(to_unsigned(FIG3_CASES(idx).b_val, 4));
            wait for T_STEP;

            if (hex2_tb /= FIG3_CASES(idx).exp2) or
               (hex1_tb /= FIG3_CASES(idx).exp1) or
               (hex0_tb /= FIG3_CASES(idx).exp0) then
                report "ERROR en caso Figura 3 #" & integer'image(idx) severity error;
                errors := errors + 1;
            end if;
        end loop;

        if errors = 0 then
            report ">> VERIFICACION EXITOSA: Los 7 casos de la Figura 3 en 7-Segmentos pasaron OK!" severity note;
        else
            report ">> VERIFICACION CON FALLAS: Total errores = " & integer'image(errors) severity error;
        end if;

        wait;
    end process;
end architecture Behavioral;
