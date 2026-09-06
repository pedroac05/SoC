library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux_logic_tb is
end entity mux_logic_tb;

architecture Behavioral of mux_logic_tb is
    component mux_logic_top is
        port (
            x1        : in  std_logic;
            x2        : in  std_logic;
            x3        : in  std_logic;
            x4        : in  std_logic;
            f_gate    : out std_logic;
            f_mux     : out std_logic;
            match_out : out std_logic
        );
    end component;

    signal x1_tb        : std_logic := '0';
    signal x2_tb        : std_logic := '0';
    signal x3_tb        : std_logic := '0';
    signal x4_tb        : std_logic := '0';
    signal f_gate_tb    : std_logic;
    signal f_mux_tb     : std_logic;
    signal match_out_tb : std_logic;

    constant T_STEP : time := 20 ns;
begin
    DUT: mux_logic_top
        port map (
            x1        => x1_tb,
            x2        => x2_tb,
            x3        => x3_tb,
            x4        => x4_tb,
            f_gate    => f_gate_tb,
            f_mux     => f_mux_tb,
            match_out => match_out_tb
        );

    stim_proc: process
        variable vec_in       : std_logic_vector(3 downto 0);
        variable count_ones   : integer;
        variable expected_val : std_logic;
    begin
        -- Evaluación exhaustiva de las 16 combinaciones posibles
        for i in 0 to 15 loop
            vec_in  := std_logic_vector(to_unsigned(i, 4));
            x1_tb   <= vec_in(3);
            x2_tb   <= vec_in(2);
            x3_tb   <= vec_in(1);
            x4_tb   <= vec_in(0);

            -- Cálculo del valor esperado (Paridad Par)
            count_ones := 0;
            for k in 0 to 3 loop
                if vec_in(k) = '1' then
                    count_ones := count_ones + 1;
                end if;
            end loop;

            if (count_ones mod 2) = 0 then
                expected_val := '1';
            else
                expected_val := '0';
            end if;

            wait for T_STEP;

            -- Verificación automática de Gate-Level, MUX-Based y su concordancia
            assert f_gate_tb = expected_val
                report "ERROR en f_gate para vector " & integer'image(i) & " (" & 
                       std_logic'image(vec_in(3)) & std_logic'image(vec_in(2)) & 
                       std_logic'image(vec_in(1)) & std_logic'image(vec_in(0)) & ")"
                severity error;

            assert f_mux_tb = expected_val
                report "ERROR en f_mux para vector " & integer'image(i) & " (" & 
                       std_logic'image(vec_in(3)) & std_logic'image(vec_in(2)) & 
                       std_logic'image(vec_in(1)) & std_logic'image(vec_in(0)) & ")"
                severity error;

            assert match_out_tb = '1'
                report "DESAJUSTE entre f_gate y f_mux en vector " & integer'image(i)
                severity error;
        end loop;

        report ">>> Simulacion exhaustiva de mux_logic_tb (16 vectores) completada exitosamente. <<<" severity note;
        wait;
    end process;
end architecture Behavioral;
