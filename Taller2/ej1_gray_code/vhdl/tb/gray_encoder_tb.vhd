library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================================================================
-- Testbench para el Codificador Binario a Gray de 4 bits
-- Verifica exhaustivamente las 16 combinaciones (0 a 15)
-- Comprueba los valores esperados y la propiedad de cambio de un solo bit.
-- ============================================================================

entity gray_encoder_tb is
end entity gray_encoder_tb;

architecture Behavioral of gray_encoder_tb is
    component gray_encoder is
        port (
            b : in  std_logic_vector(3 downto 0);
            g : out std_logic_vector(3 downto 0)
        );
    end component;

    signal b_tb : std_logic_vector(3 downto 0) := "0000";
    signal g_tb : std_logic_vector(3 downto 0);

    constant T_STEP : time := 20 ns;

    -- Tabla de valores esperados según la Figura 1 del enunciado
    type gray_array is array (0 to 15) of std_logic_vector(3 downto 0);
    constant EXPECTED_GRAY : gray_array := (
        0  => "0000",
        1  => "0001",
        2  => "0011",
        3  => "0010",
        4  => "0110",
        5  => "0111",
        6  => "0101",
        7  => "0100",
        8  => "1100",
        9  => "1101",
        10 => "1111",
        11 => "1110",
        12 => "1010",
        13 => "1011",
        14 => "1001",
        15 => "1000"
    );

    -- Función auxiliar para contar cuántos bits difieren (Distancia de Hamming)
    function hamming_distance(v1, v2 : std_logic_vector(3 downto 0)) return integer is
        variable diff_count : integer := 0;
    begin
        for i in 0 to 3 loop
            if v1(i) /= v2(i) then
                diff_count := diff_count + 1;
            end if;
        end loop;
        return diff_count;
    end function;

begin
    DUT: gray_encoder
        port map (
            b => b_tb,
            g => g_tb
        );

    stim_proc: process
        variable prev_g : std_logic_vector(3 downto 0) := "0000";
    begin
        report "==========================================================";
        report ">>> INICIO DE SIMULACION: gray_encoder_tb (VHDL) <<<";
        report "==========================================================";

        for i in 0 to 15 loop
            b_tb <= std_logic_vector(to_unsigned(i, 4));
            wait for T_STEP;

            -- 1. Verificar valor exacto esperado
            assert g_tb = EXPECTED_GRAY(i)
                report "ERROR en Binario=" & integer'image(i) &
                       ": Se esperaba Gray=" & integer'image(to_integer(unsigned(EXPECTED_GRAY(i)))) &
                       ", obtenido=" & integer'image(to_integer(unsigned(g_tb)))
                severity error;

            -- 2. Verificar propiedad Gray: distancia de Hamming = 1 respecto al anterior (para i > 0)
            if i > 0 then
                assert hamming_distance(g_tb, prev_g) = 1
                    report "ERROR: Entre paso " & integer'image(i-1) & " y " & integer'image(i) &
                           " cambiaron mas o menos de 1 bit!"
                    severity error;
            end if;

            prev_g := g_tb;
        end loop;

        report "==========================================================";
        report ">>> SIMULACION EXITOSA: Todas las pruebas superadas. <<<";
        report "==========================================================";
        wait;
    end process;

end architecture Behavioral;

