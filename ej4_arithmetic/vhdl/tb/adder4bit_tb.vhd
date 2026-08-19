library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adder4bit_tb is
end entity adder4bit_tb;

architecture Behavioral of adder4bit_tb is
    component adder4bit is
        port (
            a    : in  std_logic_vector(3 downto 0);
            b    : in  std_logic_vector(3 downto 0);
            cin  : in  std_logic;
            s    : out std_logic_vector(3 downto 0);
            cout : out std_logic
        );
    end component;

    signal a_tb    : std_logic_vector(3 downto 0) := "0000";
    signal b_tb    : std_logic_vector(3 downto 0) := "0000";
    signal cin_tb  : std_logic := '0';
    signal s_tb    : std_logic_vector(3 downto 0);
    signal cout_tb : std_logic;

    constant T_STEP : time := 20 ns;
begin
    DUT: adder4bit
        port map (
            a    => a_tb,
            b    => b_tb,
            cin  => cin_tb,
            s    => s_tb,
            cout => cout_tb
        );

    stim_proc: process
        variable expected_sum : integer;
        variable expected_s   : std_logic_vector(3 downto 0);
        variable expected_c   : std_logic;
    begin
        -- =====================================================================
        -- FASE 1: 10 VECTORES DE PRUEBA ESPECÍFICOS Y CASOS LÍMITE (OVERFLOW)
        -- =====================================================================
        -- 1. Cero + Cero sin Cin (0 + 0 = 0)
        a_tb <= "0000"; b_tb <= "0000"; cin_tb <= '0'; wait for T_STEP;
        assert s_tb = "0000" and cout_tb = '0' report "Error Vector 1" severity error;

        -- 2. Suma simple sin acarreo (3 + 4 = 7)
        a_tb <= "0011"; b_tb <= "0100"; cin_tb <= '0'; wait for T_STEP;
        assert s_tb = "0111" and cout_tb = '0' report "Error Vector 2" severity error;

        -- 3. Suma con acarreo de entrada Cin (2 + 3 + 1 = 6)
        a_tb <= "0010"; b_tb <= "0011"; cin_tb <= '1'; wait for T_STEP;
        assert s_tb = "0110" and cout_tb = '0' report "Error Vector 3" severity error;

        -- 4. Propagación de acarreo interno (7 + 1 = 8)
        a_tb <= "0111"; b_tb <= "0001"; cin_tb <= '0'; wait for T_STEP;
        assert s_tb = "1000" and cout_tb = '0' report "Error Vector 4" severity error;

        -- 5. Rango máximo sin overflow (10 + 5 = 15)
        a_tb <= "1010"; b_tb <= "0101"; cin_tb <= '0'; wait for T_STEP;
        assert s_tb = "1111" and cout_tb = '0' report "Error Vector 5" severity error;

        -- 6. OVERFLOW / Desbordamiento básico (15 + 1 = 16 => S=0, Cout=1)
        a_tb <= "1111"; b_tb <= "0001"; cin_tb <= '0'; wait for T_STEP;
        assert s_tb = "0000" and cout_tb = '1' report "Error Vector 6 (Overflow)" severity error;

        -- 7. OVERFLOW con valores medios (8 + 9 = 17 => S=1, Cout=1)
        a_tb <= "1000"; b_tb <= "1001"; cin_tb <= '0'; wait for T_STEP;
        assert s_tb = "0001" and cout_tb = '1' report "Error Vector 7 (Overflow)" severity error;

        -- 8. OVERFLOW con Cin activo (12 + 4 + 1 = 17 => S=1, Cout=1)
        a_tb <= "1100"; b_tb <= "0100"; cin_tb <= '1'; wait for T_STEP;
        assert s_tb = "0001" and cout_tb = '1' report "Error Vector 8 (Overflow)" severity error;

        -- 9. Caso simétrico (9 + 9 = 18 => S=2, Cout=1)
        a_tb <= "1001"; b_tb <= "1001"; cin_tb <= '0'; wait for T_STEP;
        assert s_tb = "0010" and cout_tb = '1' report "Error Vector 9 (Overflow)" severity error;

        -- 10. Máximo absoluto posible (15 + 15 + 1 = 31 => S=15, Cout=1)
        a_tb <= "1111"; b_tb <= "1111"; cin_tb <= '1'; wait for T_STEP;
        assert s_tb = "1111" and cout_tb = '1' report "Error Vector 10 (Max Overflow)" severity error;

        -- =====================================================================
        -- FASE 2: VERIFICACIÓN EXHAUSTIVA TOTAL (512 CASOS)
        -- =====================================================================
        for c_val in 0 to 1 loop
            for i in 0 to 15 loop
                for j in 0 to 15 loop
                    a_tb <= std_logic_vector(to_unsigned(i, 4));
                    b_tb <= std_logic_vector(to_unsigned(j, 4));
                    if c_val = 1 then
                        cin_tb <= '1';
                    else
                        cin_tb <= '0';
                    end if;

                    expected_sum := i + j + c_val;
                    expected_s   := std_logic_vector(to_unsigned(expected_sum mod 16, 4));
                    if expected_sum >= 16 then
                        expected_c := '1';
                    else
                        expected_c := '0';
                    end if;

                    wait for T_STEP;

                    assert s_tb = expected_s
                        report "Error de Suma en a=" & integer'image(i) & ", b=" & integer'image(j)
                        severity error;
                    assert cout_tb = expected_c
                        report "Error de Acarreo en a=" & integer'image(i) & ", b=" & integer'image(j)
                        severity error;
                end loop;
            end loop;
        end loop;

        report ">>> Simulacion de adder4bit_tb completada exitosamente (512 vectores evaluados). <<<" severity note;
        wait;
    end process;
end architecture Behavioral;
