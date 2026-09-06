library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gt4_tb is
end entity gt4_tb;

architecture Behavioral of gt4_tb is
    component gt4 is
        port (
            a  : in  std_logic_vector(3 downto 0);
            b  : in  std_logic_vector(3 downto 0);
            gt : out std_logic
        );
    end component;

    signal a_tb  : std_logic_vector(3 downto 0) := "0000";
    signal b_tb  : std_logic_vector(3 downto 0) := "0000";
    signal gt_tb : std_logic;

    constant T_STEP : time := 20 ns;
begin
    DUT: gt4
        port map (
            a  => a_tb,
            b  => b_tb,
            gt => gt_tb
        );

    stim_proc: process
    begin
        -- Recorrer exhaustivamente las 256 combinaciones posibles (16x16)
        for i in 0 to 15 loop
            for j in 0 to 15 loop
                a_tb <= std_logic_vector(to_unsigned(i, 4));
                b_tb <= std_logic_vector(to_unsigned(j, 4));
                wait for T_STEP;

                if i > j then
                    assert gt_tb = '1'
                        report "ERROR: Esperaba gt=1 para a=" & integer'image(i) & ", b=" & integer'image(j) & " (obtenido: " & std_logic'image(gt_tb) & ")"
                        severity error;
                else
                    assert gt_tb = '0'
                        report "ERROR: Esperaba gt=0 para a=" & integer'image(i) & ", b=" & integer'image(j) & " (obtenido: " & std_logic'image(gt_tb) & ")"
                        severity error;
                end if;
            end loop;
        end loop;

        report ">>> Simulacion exhaustiva de gt4_tb (256 vectores) completada exitosamente sin errores. <<<" severity note;
        wait;
    end process;
end architecture Behavioral;
