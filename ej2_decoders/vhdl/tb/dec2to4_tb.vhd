library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dec2to4_tb is
end entity dec2to4_tb;

architecture Behavioral of dec2to4_tb is
    component dec2to4 is
        port (
            en    : in  std_logic;
            in_v  : in  std_logic_vector(1 downto 0);
            bcode : out std_logic_vector(3 downto 0)
        );
    end component;

    signal en_tb    : std_logic := '0';
    signal in_v_tb  : std_logic_vector(1 downto 0) := "00";
    signal bcode_tb : std_logic_vector(3 downto 0);

    constant T_STEP : time := 20 ns;
begin
    DUT: dec2to4
        port map (
            en    => en_tb,
            in_v  => in_v_tb,
            bcode => bcode_tb
        );

    stim_proc: process
        variable expected_val : std_logic_vector(3 downto 0);
    begin
        -- Caso 1: Enable desactivado (en = '0') -> bcode debe ser "0000"
        en_tb <= '0';
        for i in 0 to 3 loop
            in_v_tb <= std_logic_vector(to_unsigned(i, 2));
            wait for T_STEP;
            assert bcode_tb = "0000"
                report "ERROR en en=0: Se esperaba bcode=0000, obtenido=" & integer'image(to_integer(unsigned(bcode_tb)))
                severity error;
        end loop;

        -- Caso 2: Enable activado (en = '1') -> decodificación One-Hot
        en_tb <= '1';
        for i in 0 to 3 loop
            in_v_tb <= std_logic_vector(to_unsigned(i, 2));
            wait for T_STEP;
            
            case i is
                when 0 => expected_val := "0001";
                when 1 => expected_val := "0010";
                when 2 => expected_val := "0100";
                when 3 => expected_val := "1000";
                when others => expected_val := "0000";
            end case;

            assert bcode_tb = expected_val
                report "ERROR en en=1, in=" & integer'image(i) & ": Se esperaba bcode=" & integer'image(to_integer(unsigned(expected_val)))
                severity error;
        end loop;

        report ">>> Simulacion de dec2to4_tb finalizada exitosamente sin errores. <<<" severity note;
        wait;
    end process;
end architecture Behavioral;
