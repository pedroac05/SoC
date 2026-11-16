library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================================================================
-- Testbench para Barrel Shifter Multietapa de 0 a 7 bits (8 bits de datos)
-- Verifica todos los casos de desplazamiento (shift = 0 hasta 7) sobre
-- múltiples vectores de prueba.
-- ============================================================================

entity barrel_shifter_8bit_tb is
end entity barrel_shifter_8bit_tb;

architecture Behavioral of barrel_shifter_8bit_tb is
    component barrel_shifter_8bit is
        port (
            inp   : in  std_logic_vector(7 downto 0);
            shift : in  std_logic_vector(2 downto 0);
            outp  : out std_logic_vector(7 downto 0)
        );
    end component;

    signal inp_tb   : std_logic_vector(7 downto 0) := "11010101";
    signal shift_tb : std_logic_vector(2 downto 0) := "000";
    signal outp_tb  : std_logic_vector(7 downto 0);

    constant T_STEP : time := 20 ns;
begin
    DUT: barrel_shifter_8bit
        port map (
            inp   => inp_tb,
            shift => shift_tb,
            outp  => outp_tb
        );

    stim_proc: process
        variable expected_out : std_logic_vector(7 downto 0);
    begin
        report "==========================================================";
        report ">>> INICIO DE SIMULACION: barrel_shifter_8bit_tb (VHDL) <<<";
        report "==========================================================";

        -- Prueba 1: Vector "00000001" (bit '1' recorriendo las 8 posiciones de 0 a 7)
        inp_tb <= "00000001";
        for s in 0 to 7 loop
            shift_tb <= std_logic_vector(to_unsigned(s, 3));
            wait for T_STEP;

            expected_out := std_logic_vector(shift_left(unsigned(inp_tb), s));
            assert outp_tb = expected_out
                report "ERROR en inp=00000001, shift=" & integer'image(s)
                severity error;
        end loop;

        -- Prueba 2: Vector denso "10110101" (0xB5) para todos los desplazamientos 0..7
        inp_tb <= "10110101";
        for s in 0 to 7 loop
            shift_tb <= std_logic_vector(to_unsigned(s, 3));
            wait for T_STEP;

            expected_out := std_logic_vector(shift_left(unsigned(inp_tb), s));
            assert outp_tb = expected_out
                report "ERROR en inp=10110101, shift=" & integer'image(s)
                severity error;
        end loop;

        -- Prueba 3: Vector "11111111" (0xFF) mostrando la entrada progresiva de ceros en LSB
        inp_tb <= "11111111";
        for s in 0 to 7 loop
            shift_tb <= std_logic_vector(to_unsigned(s, 3));
            wait for T_STEP;

            expected_out := std_logic_vector(shift_left(unsigned(inp_tb), s));
            assert outp_tb = expected_out
                report "ERROR en inp=11111111, shift=" & integer'image(s)
                severity error;
        end loop;

        report "==========================================================";
        report ">>> SIMULACION EXITOSA: Todos los desplazamientos 0..7 OK <<<";
        report "==========================================================";
        wait;
    end process;
end architecture Behavioral;

