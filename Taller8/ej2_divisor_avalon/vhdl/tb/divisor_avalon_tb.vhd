library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ============================================================================
-- Testbench para divisor_avalon (Interfaz Avalon MM-Slave, W = 32, CBIT = 6)
-- Simula transacciones del bus Avalon: escritura de dvnd/dvsr/start, polling
-- de ready y done_tick, lectura de quo/rmd, verificación de DIV_LED y div_irq,
-- y limpieza de la bandera done_tick.
-- ============================================================================
entity divisor_avalon_tb is
end entity divisor_avalon_tb;

architecture sim of divisor_avalon_tb is
    constant W_C     : integer := 32;
    constant CBIT_C  : integer := 6;
    constant CLK_PER : time    := 20 ns; -- 50 MHz

    -- Offsets del mapa de memoria
    constant ADDR_DVND  : std_logic_vector(2 downto 0) := "000"; -- 0
    constant ADDR_DVSR  : std_logic_vector(2 downto 0) := "001"; -- 1
    constant ADDR_START : std_logic_vector(2 downto 0) := "010"; -- 2
    constant ADDR_QUO   : std_logic_vector(2 downto 0) := "011"; -- 3
    constant ADDR_RMD   : std_logic_vector(2 downto 0) := "100"; -- 4
    constant ADDR_READY : std_logic_vector(2 downto 0) := "101"; -- 5
    constant ADDR_DONE  : std_logic_vector(2 downto 0) := "110"; -- 6

    signal clk_tb            : std_logic := '0';
    signal reset_tb          : std_logic := '0';
    signal div_address_tb    : std_logic_vector(2 downto 0) := (others => '0');
    signal div_chipselect_tb : std_logic := '0';
    signal div_write_tb      : std_logic := '0';
    signal div_writedata_tb  : std_logic_vector(W_C - 1 downto 0) := (others => '0');
    signal div_readdata_tb   : std_logic_vector(W_C - 1 downto 0);
    signal div_irq_tb        : std_logic;
    signal div_led_tb        : std_logic_vector(7 downto 0);
    signal sim_done          : boolean := false;
begin
    dut : entity work.divisor_avalon
        generic map (
            W    => W_C,
            CBIT => CBIT_C
        )
        port map (
            clk            => clk_tb,
            reset          => reset_tb,
            div_address    => div_address_tb,
            div_chipselect => div_chipselect_tb,
            div_write      => div_write_tb,
            div_writedata  => div_writedata_tb,
            div_readdata   => div_readdata_tb,
            div_irq        => div_irq_tb,
            DIV_LED        => div_led_tb
        );

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

    stim_proc : process
        procedure avalon_write(
            constant addr : in std_logic_vector(2 downto 0);
            constant data : in integer
        ) is
        begin
            wait until falling_edge(clk_tb);
            div_address_tb    <= addr;
            div_chipselect_tb <= '1';
            div_write_tb      <= '1';
            div_writedata_tb  <= std_logic_vector(to_unsigned(data, W_C));
            wait until rising_edge(clk_tb);
            wait for 1 ns;
            div_chipselect_tb <= '0';
            div_write_tb      <= '0';
        end procedure;

        procedure avalon_read(
            constant addr : in std_logic_vector(2 downto 0);
            variable data : out integer
        ) is
        begin
            wait until falling_edge(clk_tb);
            div_address_tb    <= addr;
            div_chipselect_tb <= '1';
            div_write_tb      <= '0';
            wait for 5 ns; -- Read wait = 0 (combinacional)
            data := to_integer(unsigned(div_readdata_tb));
            wait until rising_edge(clk_tb);
            div_chipselect_tb <= '0';
        end procedure;

        procedure test_avalon_div(
            constant a_val : in integer;
            constant b_val : in integer
        ) is
            variable rd_val : integer;
            variable quo_v  : integer;
            variable rmd_v  : integer;
        begin
            -- 1. Escribir dividendo y divisor
            avalon_write(ADDR_DVND, a_val);
            avalon_write(ADDR_DVSR, b_val);

            -- 2. Verificar ready = 1
            loop
                avalon_read(ADDR_READY, rd_val);
                exit when rd_val = 1;
            end loop;

            -- 3. Disparar start (escritura dummy)
            avalon_write(ADDR_START, 1);

            -- 4. Polling de done_tick = 1
            loop
                avalon_read(ADDR_DONE, rd_val);
                exit when rd_val = 1;
            end loop;

            -- Verificar que IRQ está activa antes de limpiar
            assert div_irq_tb = '1'
                report "ERROR: div_irq deberia estar en '1' al finalizar la division"
                severity error;

            -- 5. Limpiar bandera done_tick (escritura dummy en offset 6)
            avalon_write(ADDR_DONE, 1);
            wait for 1 ns;
            assert div_irq_tb = '0'
                report "ERROR: div_irq no se limpio tras escribir en offset 6"
                severity error;

            -- 6. Leer cociente y residuo
            avalon_read(ADDR_QUO, quo_v);
            avalon_read(ADDR_RMD, rmd_v);

            assert quo_v = (a_val / b_val)
                report "ERROR cociente Avalon: esperado=" & integer'image(a_val / b_val) &
                       " obtenido=" & integer'image(quo_v)
                severity error;

            assert rmd_v = (a_val mod b_val)
                report "ERROR residuo Avalon: esperado=" & integer'image(a_val mod b_val) &
                       " obtenido=" & integer'image(rmd_v)
                severity error;

            assert to_integer(unsigned(div_led_tb)) = ((a_val mod b_val) mod 256)
                report "ERROR DIV_LED no coincide con rmd(7 downto 0)"
                severity error;

            report "OK Avalon: " & integer'image(a_val) & " / " & integer'image(b_val) &
                   " => quo=" & integer'image(quo_v) &
                   ", rmd=" & integer'image(rmd_v) &
                   ", DIV_LED=" & integer'image(to_integer(unsigned(div_led_tb)));
        end procedure;
    begin
        -- Reset inicial
        reset_tb <= '1';
        wait for 2 * CLK_PER;
        reset_tb <= '0';
        wait for CLK_PER;

        -- Pruebas por bus Avalon
        test_avalon_div(12345, 100);  -- quo = 123, rmd = 45  (DIV_LED = 45)
        test_avalon_div(1000, 7);     -- quo = 142, rmd = 6   (DIV_LED = 6)
        test_avalon_div(65535, 255);  -- quo = 257, rmd = 0   (DIV_LED = 0)

        wait for 3 * CLK_PER;
        report "Simulacion divisor_avalon_tb finalizada exitosamente.";
        sim_done <= true;
        wait;
    end process;
end architecture sim;
