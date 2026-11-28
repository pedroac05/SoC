library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ============================================================================
-- Testbench para divisor entero parametrizable (W = 8, CBIT = 4, f = 50 MHz)
-- Verifica múltiples casos de división entera sin signo con aserciones.
-- ============================================================================
entity divisor_tb is
end entity divisor_tb;

architecture sim of divisor_tb is
    constant W_C      : integer := 8;
    constant CBIT_C   : integer := 4;
    constant CLK_PER  : time    := 20 ns; -- 50 MHz

    signal clk_tb       : std_logic := '0';
    signal reset_tb     : std_logic := '0';
    signal start_tb     : std_logic := '0';
    signal dvnd_tb      : std_logic_vector(W_C - 1 downto 0) := (others => '0');
    signal dvsr_tb      : std_logic_vector(W_C - 1 downto 0) := (others => '0');
    signal ready_tb     : std_logic;
    signal done_tick_tb : std_logic;
    signal quo_tb       : std_logic_vector(W_C - 1 downto 0);
    signal rmd_tb       : std_logic_vector(W_C - 1 downto 0);
    signal sim_done     : boolean := false;
begin
    -- Instancia del DUT
    dut : entity work.divisor
        generic map (
            W    => W_C,
            CBIT => CBIT_C
        )
        port map (
            clk       => clk_tb,
            reset     => reset_tb,
            start     => start_tb,
            dvsr      => dvsr_tb,
            dvnd      => dvnd_tb,
            ready     => ready_tb,
            done_tick => done_tick_tb,
            quo       => quo_tb,
            rmd       => rmd_tb
        );

    -- Generación de reloj de 50 MHz
    clk_proc : process
    begin
        while not sim_done loop
            clk_tb <= '0';
            wait for CLK_PER / 2;
            clk_tb <= '1';
            wait for CLK_PER / 2;
        end loop;
        wait;
    end process;

    -- Estímulos y verificación automática
    stim_proc : process
        procedure run_division(
            constant a_val : in integer;
            constant b_val : in integer
        ) is
            variable exp_q : integer;
            variable exp_r : integer;
        begin
            exp_q := a_val / b_val;
            exp_r := a_val mod b_val;

            -- Esperar a que el divisor esté listo
            wait until ready_tb = '1' and rising_edge(clk_tb);
            dvnd_tb  <= std_logic_vector(to_unsigned(a_val, W_C));
            dvsr_tb  <= std_logic_vector(to_unsigned(b_val, W_C));
            start_tb <= '1';
            wait until rising_edge(clk_tb);
            start_tb <= '0';

            -- Esperar pulso done_tick
            wait until done_tick_tb = '1' and rising_edge(clk_tb);
            wait for 1 ns;

            assert to_integer(unsigned(quo_tb)) = exp_q
                report "ERROR cociente: " & integer'image(a_val) & " / " & integer'image(b_val) &
                       " esperado=" & integer'image(exp_q) &
                       " obtenido=" & integer'image(to_integer(unsigned(quo_tb)))
                severity error;

            assert to_integer(unsigned(rmd_tb)) = exp_r
                report "ERROR residuo: " & integer'image(a_val) & " mod " & integer'image(b_val) &
                       " esperado=" & integer'image(exp_r) &
                       " obtenido=" & integer'image(to_integer(unsigned(rmd_tb)))
                severity error;

            report "OK: " & integer'image(a_val) & " / " & integer'image(b_val) &
                   " => quo=" & integer'image(to_integer(unsigned(quo_tb))) &
                   ", rmd=" & integer'image(to_integer(unsigned(rmd_tb)));
        end procedure;
    begin
        -- Reset inicial
        reset_tb <= '1';
        wait for 2 * CLK_PER;
        reset_tb <= '0';
        wait for CLK_PER;

        -- Casos de prueba (incluye división exacta, con residuo, dividendo < divisor y extremos)
        run_division(25, 4);    -- quo = 6,   rmd = 1
        run_division(100, 10);  -- quo = 10,  rmd = 0
        run_division(255, 16);  -- quo = 15,  rmd = 15
        run_division(7, 15);    -- quo = 0,   rmd = 7
        run_division(255, 1);   -- quo = 255, rmd = 0

        wait for 3 * CLK_PER;
        report "Simulacion divisor_tb finalizada exitosamente.";
        sim_done <= true;
        wait;
    end process;
end architecture sim;
