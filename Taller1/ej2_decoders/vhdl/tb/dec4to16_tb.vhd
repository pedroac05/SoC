library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dec4to16_tb is
end entity dec4to16_tb;

architecture Behavioral of dec4to16_tb is
    component dec4to16 is
        port (
            en    : in  std_logic;
            in_v  : in  std_logic_vector(3 downto 0);
            bcode : out std_logic_vector(15 downto 0)
        );
    end component;

    signal en_tb    : std_logic := '0';
    signal in_v_tb  : std_logic_vector(3 downto 0) := "0000";
    signal bcode_tb : std_logic_vector(15 downto 0);

    constant T_STEP : time := 20 ns;
begin
    DUT: dec4to16
        port map (
            en    => en_tb,
            in_v  => in_v_tb,
            bcode => bcode_tb
        );

    stim_proc: process
        variable expected_val : std_logic_vector(15 downto 0);
    begin
        -- Caso 1: Enable desactivado (en = '0') -> bcode debe ser "0000000000000000"
        en_tb <= '0';
        for i in 0 to 15 loop
            in_v_tb <= std_logic_vector(to_unsigned(i, 4));
            wait for T_STEP;
            assert bcode_tb = X"0000"
                report "ERROR en en=0: Se esperaba bcode=0000h para in=" & integer'image(i)
                severity error;
        end loop;

        -- Caso 2: Enable activado (en = '1') -> decodificación One-Hot de 16 salidas
        en_tb <= '1';
        for i in 0 to 15 loop
            in_v_tb <= std_logic_vector(to_unsigned(i, 4));
            wait for T_STEP;
            
            expected_val := (others => '0');
            expected_val(i) := '1';

            assert bcode_tb = expected_val
                report "ERROR en en=1: Valor incorrecto para in=" & integer'image(i)
                severity error;
        end loop;

        report ">>> Simulacion exhaustiva de dec4to16_tb completada exitosamente sin errores. <<<" severity note;
        wait;
    end process;
end architecture Behavioral;
