library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================================================================
-- Testbench para Barrel Shifter de 1 bit (8 bits de datos)
-- Prueba múltiples patrones de entrada con shift = '0' y shift = '1'
-- ============================================================================

entity barrel_shifter_1bit_tb is
end entity barrel_shifter_1bit_tb;

architecture Behavioral of barrel_shifter_1bit_tb is
    component barrel_shifter_1bit is
        port (
            inp   : in  std_logic_vector(7 downto 0);
            shift : in  std_logic;
            outp  : out std_logic_vector(7 downto 0)
        );
    end component;

    signal inp_tb   : std_logic_vector(7 downto 0) := (others => '0');
    signal shift_tb : std_logic := '0';
    signal outp_tb  : std_logic_vector(7 downto 0);

    constant T_STEP : time := 20 ns;

    type vec_array is array (0 to 5) of std_logic_vector(7 downto 0);
    constant TEST_PATTERNS : vec_array := (
        0 => "00000001", -- 0x01: bit en LSB
        1 => "10000000", -- 0x80: bit en MSB (se descarta al desplazar)
        2 => "10101010", -- 0xAA: patrón alternado 1010...
        3 => "01010101", -- 0x55: patrón alternado 0101...
        4 => "11001011", -- 0xCB: patrón asimétrico de prueba
        5 => "11111111"  -- 0xFF: todos en 1
    );
begin
    DUT: barrel_shifter_1bit
        port map (
            inp   => inp_tb,
            shift => shift_tb,
            outp  => outp_tb
        );

    stim_proc: process
        variable expected_out : std_logic_vector(7 downto 0);
    begin
        report "==========================================================";
        report ">>> INICIO DE SIMULACION: barrel_shifter_1bit_tb (VHDL) <<<";
        report "==========================================================";

        for i in TEST_PATTERNS'range loop
            inp_tb <= TEST_PATTERNS(i);

            -- Caso A: Sin desplazamiento (shift = '0')
            shift_tb <= '0';
            wait for T_STEP;
            expected_out := TEST_PATTERNS(i);
            assert outp_tb = expected_out
                report "ERROR con shift=0 en patron " & integer'image(i)
                severity error;

            -- Caso B: Desplazamiento de 1 bit a la izquierda (shift = '1')
            shift_tb <= '1';
            wait for T_STEP;
            expected_out := TEST_PATTERNS(i)(6 downto 0) & '0';
            assert outp_tb = expected_out
                report "ERROR con shift=1 en patron " & integer'image(i)
                severity error;
        end loop;

        report "==========================================================";
        report ">>> SIMULACION EXITOSA: barrel_shifter_1bit verificado. <<<";
        report "==========================================================";
        wait;
    end process;
end architecture Behavioral;

