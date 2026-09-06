library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity eq2_tb is
end entity eq2_tb;

architecture Behavioral of eq2_tb is
    component eq2 is
        port (
            a  : in  std_logic_vector(1 downto 0);
            b  : in  std_logic_vector(1 downto 0);
            eq : out std_logic
        );
    end component;

    signal a_tb  : std_logic_vector(1 downto 0) := "00";
    signal b_tb  : std_logic_vector(1 downto 0) := "00";
    signal eq_tb : std_logic;

    constant T_STEP : time := 20 ns;
begin
    DUT: eq2
        port map (
            a  => a_tb,
            b  => b_tb,
            eq => eq_tb
        );

    stim_proc: process
    begin
        for i in 0 to 3 loop
            for j in 0 to 3 loop
                a_tb <= std_logic_vector(to_unsigned(i, 2));
                b_tb <= std_logic_vector(to_unsigned(j, 2));
                wait for T_STEP;
                
                if i = j then
                    assert eq_tb = '1'
                        report "ERROR: Esperaba eq=1 para a=" & integer'image(i) & ", b=" & integer'image(j)
                        severity error;
                else
                    assert eq_tb = '0'
                        report "ERROR: Esperaba eq=0 para a=" & integer'image(i) & ", b=" & integer'image(j)
                        severity error;
                end if;
            end loop;
        end loop;
        
        report "Simulacion de eq2_tb completada exitosamente." severity note;
        wait;
    end process;
end architecture Behavioral;
