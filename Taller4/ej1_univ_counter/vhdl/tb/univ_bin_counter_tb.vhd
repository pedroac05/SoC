-- ==============================================================================
-- Testbench VHDL para univ_bin_counter
-- Parametros modificados en testbench: N = 4, MAX_COUNT = "1001" (9 decimal)
-- Frecuencia de reloj simulada: 50 MHz (T_clk = 20 ns)
-- ==============================================================================
-- Escenarios verificados:
--   1. Reset asincrono inicial (rst = '1') -> counter = 0, min_tick = '1'
--   2. Conteo ascendente completo (0 -> 9 -> 0) -> verifica max_tick y rollover
--   3. Pausa (ena = '0') y reanudacion (ena = '1')
--   4. Carga paralela sincrona (load = '1' por 1 ciclo, d = 5) -> cuenta 5..9..0
--   5. Conteo descendente (up = '0') -> verifica decremento, min_tick y underflow (0 -> 9)
--   6. Reinicio sincrono (syn_clr = '1') -> vuelve a 0 en flanco de subida de clk
--   7. Reset asincrono en mitad de ciclo (fuera de flanco de clk) -> efecto inmediato
-- ==============================================================================

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY univ_bin_counter_tb IS
END ENTITY univ_bin_counter_tb;

ARCHITECTURE sim OF univ_bin_counter_tb IS

    -- Parametros modificados para el testbench (contador modulo 10: 0..9)
    CONSTANT C_N         : INTEGER := 4;
    CONSTANT C_MAX_COUNT : STD_LOGIC_VECTOR(C_N-1 DOWNTO 0) := "1001"; -- 9 decimal
    CONSTANT T_CLK       : TIME := 20 ns;                              -- 50 MHz

    -- Senales de estimulo y observacion
    SIGNAL clk_tb      : STD_LOGIC := '0';
    SIGNAL rst_tb      : STD_LOGIC := '0';
    SIGNAL ena_tb      : STD_LOGIC := '0';
    SIGNAL syn_clr_tb  : STD_LOGIC := '0';
    SIGNAL load_tb     : STD_LOGIC := '0';
    SIGNAL up_tb       : STD_LOGIC := '1';
    SIGNAL d_tb        : STD_LOGIC_VECTOR(C_N-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL max_tick_tb : STD_LOGIC;
    SIGNAL min_tick_tb : STD_LOGIC;
    SIGNAL counter_tb  : STD_LOGIC_VECTOR(C_N-1 DOWNTO 0);

    SIGNAL sim_done    : BOOLEAN := FALSE;

BEGIN

    -- Instanciacion del DUT con parametros personalizados
    dut : ENTITY work.univ_bin_counter
        GENERIC MAP (
            N         => C_N,
            MAX_COUNT => C_MAX_COUNT
        )
        PORT MAP (
            clk      => clk_tb,
            rst      => rst_tb,
            ena      => ena_tb,
            syn_clr  => syn_clr_tb,
            load     => load_tb,
            up       => up_tb,
            d        => d_tb,
            max_tick => max_tick_tb,
            min_tick => min_tick_tb,
            counter  => counter_tb
        );

    -- Generador de reloj de 50 MHz (periodo = 20 ns)
    clk_gen : PROCESS
    BEGIN
        WHILE NOT sim_done LOOP
            clk_tb <= '0';
            WAIT FOR T_CLK / 2;
            clk_tb <= '1';
            WAIT FOR T_CLK / 2;
        END LOOP;
        WAIT;
    END PROCESS clk_gen;

    -- Proceso de estimulos y autoverificacion (asserts)
    stim_proc : PROCESS
    BEGIN
        -- ----------------------------------------------------------------------
        -- 1. Reset asincrono inicial
        -- ----------------------------------------------------------------------
        rst_tb     <= '1';
        ena_tb     <= '0';
        syn_clr_tb <= '0';
        load_tb    <= '0';
        up_tb      <= '1';
        d_tb       <= "0000";
        WAIT FOR 25 ns;
        ASSERT (counter_tb = "0000" AND min_tick_tb = '1' AND max_tick_tb = '0')
            REPORT "Error en Fase 1: Reset asincrono inicial" SEVERITY ERROR;

        rst_tb <= '0';
        WAIT UNTIL falling_edge(clk_tb);

        -- ----------------------------------------------------------------------
        -- 2. Conteo ascendente completo: 0 -> 9 (max_tick) -> 0 (rollover) -> 2
        -- ----------------------------------------------------------------------
        ena_tb <= '1';
        up_tb  <= '1';
        FOR i IN 1 TO 9 LOOP
            WAIT UNTIL rising_edge(clk_tb);
            WAIT FOR 2 ns;
            ASSERT (to_integer(unsigned(counter_tb)) = i)
                REPORT "Error en Fase 2 (ascendente): esperado " & INTEGER'image(i) SEVERITY ERROR;
        END LOOP;

        -- En counter = 9 debe estar activa max_tick
        ASSERT (max_tick_tb = '1' AND min_tick_tb = '0')
            REPORT "Error en Fase 2: max_tick debe ser '1' en MAX_COUNT (9)" SEVERITY ERROR;

        -- Siguiente flanco: rollover 9 -> 0
        WAIT UNTIL rising_edge(clk_tb);
        WAIT FOR 2 ns;
        ASSERT (counter_tb = "0000" AND min_tick_tb = '1' AND max_tick_tb = '0')
            REPORT "Error en Fase 2: rollover 9 -> 0 fallido" SEVERITY ERROR;

        -- Avanzar hasta 2
        FOR i IN 1 TO 2 LOOP
            WAIT UNTIL rising_edge(clk_tb);
            WAIT FOR 2 ns;
        END LOOP;
        ASSERT (counter_tb = "0010")
            REPORT "Error en Fase 2: counter deberia ser 2" SEVERITY ERROR;

        -- ----------------------------------------------------------------------
        -- 3. Pausa (ena = '0') durante 3 ciclos y reanudacion (ena = '1')
        -- ----------------------------------------------------------------------
        WAIT UNTIL falling_edge(clk_tb);
        ena_tb <= '0';
        FOR i IN 1 TO 3 LOOP
            WAIT UNTIL rising_edge(clk_tb);
            WAIT FOR 2 ns;
            ASSERT (counter_tb = "0010")
                REPORT "Error en Fase 3: el contador no mantuvo pausa en 2" SEVERITY ERROR;
        END LOOP;

        -- Reanudar conteo por 2 ciclos: 2 -> 3 -> 4
        WAIT UNTIL falling_edge(clk_tb);
        ena_tb <= '1';
        WAIT UNTIL rising_edge(clk_tb);
        WAIT FOR 2 ns;
        ASSERT (counter_tb = "0011") REPORT "Error en Fase 3: reanudacion a 3" SEVERITY ERROR;
        WAIT UNTIL rising_edge(clk_tb);
        WAIT FOR 2 ns;
        ASSERT (counter_tb = "0100") REPORT "Error en Fase 3: reanudacion a 4" SEVERITY ERROR;

        -- ----------------------------------------------------------------------
        -- 4. Carga paralela sincrona (load = '1' por 1 ciclo, d = 6) y conteo hasta MAX_COUNT
        -- ----------------------------------------------------------------------
        WAIT UNTIL falling_edge(clk_tb);
        d_tb    <= "0110"; -- 6 decimal
        load_tb <= '1';
        WAIT UNTIL rising_edge(clk_tb);
        WAIT FOR 2 ns;
        ASSERT (counter_tb = "0110")
            REPORT "Error en Fase 4: carga paralela de d = 6 fallida" SEVERITY ERROR;

        -- Desactivar load despues de 1 ciclo de reloj
        WAIT UNTIL falling_edge(clk_tb);
        load_tb <= '0';
        d_tb    <= "0000";

        -- Continuar contando ascendentemente: 7 -> 8 -> 9 (max_tick) -> 0
        FOR i IN 7 TO 9 LOOP
            WAIT UNTIL rising_edge(clk_tb);
            WAIT FOR 2 ns;
            ASSERT (to_integer(unsigned(counter_tb)) = i)
                REPORT "Error en Fase 4: conteo tras load esperado " & INTEGER'image(i) SEVERITY ERROR;
        END LOOP;
        ASSERT (max_tick_tb = '1')
            REPORT "Error en Fase 4: max_tick tras load debe ser '1' en 9" SEVERITY ERROR;

        -- Siguiente ciclo: 9 -> 0 -> 1 -> 2
        WAIT UNTIL rising_edge(clk_tb); -- 0
        WAIT UNTIL rising_edge(clk_tb); -- 1
        WAIT UNTIL rising_edge(clk_tb); -- 2
        WAIT FOR 2 ns;
        ASSERT (counter_tb = "0010")
            REPORT "Error en Fase 4: esperado 2 antes de invertir direccion" SEVERITY ERROR;

        -- ----------------------------------------------------------------------
        -- 5. Conteo descendente (up = '0'): 2 -> 1 -> 0 (min_tick) -> 9 (underflow) -> 7
        -- ----------------------------------------------------------------------
        WAIT UNTIL falling_edge(clk_tb);
        up_tb <= '0';

        WAIT UNTIL rising_edge(clk_tb); -- 1
        WAIT FOR 2 ns;
        ASSERT (counter_tb = "0001") REPORT "Error en Fase 5: esperado 1" SEVERITY ERROR;

        WAIT UNTIL rising_edge(clk_tb); -- 0
        WAIT FOR 2 ns;
        ASSERT (counter_tb = "0000" AND min_tick_tb = '1')
            REPORT "Error en Fase 5: esperado 0 y min_tick = '1'" SEVERITY ERROR;

        WAIT UNTIL rising_edge(clk_tb); -- 9 (underflow a MAX_COUNT)
        WAIT FOR 2 ns;
        ASSERT (counter_tb = "1001" AND max_tick_tb = '1')
            REPORT "Error en Fase 5: underflow 0 -> 9 (MAX_COUNT) fallido" SEVERITY ERROR;

        WAIT UNTIL rising_edge(clk_tb); -- 8
        WAIT UNTIL rising_edge(clk_tb); -- 7
        WAIT FOR 2 ns;
        ASSERT (counter_tb = "0111") REPORT "Error en Fase 5: esperado 7" SEVERITY ERROR;

        -- ----------------------------------------------------------------------
        -- 6. Reinicio sincrono (syn_clr = '1')
        --    Se activa en flanco de bajada: NO debe borrar hasta el flanco de subida
        -- ----------------------------------------------------------------------
        WAIT UNTIL falling_edge(clk_tb);
        syn_clr_tb <= '1';
        WAIT FOR 4 ns;
        ASSERT (counter_tb = "0111")
            REPORT "Error en Fase 6: syn_clr no debe actuar antes del flanco de reloj" SEVERITY ERROR;

        WAIT UNTIL rising_edge(clk_tb);
        WAIT FOR 2 ns;
        ASSERT (counter_tb = "0000" AND min_tick_tb = '1')
            REPORT "Error en Fase 6: syn_clr fallo al reiniciar en flanco de subida" SEVERITY ERROR;

        WAIT UNTIL falling_edge(clk_tb);
        syn_clr_tb <= '0';
        up_tb      <= '1';

        -- Avanzar 3 ciclos (0 -> 1 -> 2 -> 3) para demostrar reset asincrono en medio del ciclo
        FOR i IN 1 TO 3 LOOP
            WAIT UNTIL rising_edge(clk_tb);
        END LOOP;
        WAIT FOR 2 ns;
        ASSERT (counter_tb = "0011") REPORT "Error en Fase 7: esperado 3 antes de rst" SEVERITY ERROR;

        -- ----------------------------------------------------------------------
        -- 7. Reset asincrono en mitad de ciclo (fuera del flanco de subida de clk)
        -- ----------------------------------------------------------------------
        WAIT FOR 5 ns; -- A mitad del semiperiodo alto de clk
        rst_tb <= '1';
        WAIT FOR 2 ns;
        ASSERT (counter_tb = "0000" AND min_tick_tb = '1')
            REPORT "Error en Fase 7: rst asincrono debe limpiar inmediatamente" SEVERITY ERROR;

        WAIT UNTIL falling_edge(clk_tb);
        WAIT UNTIL falling_edge(clk_tb);
        rst_tb <= '0';
        ena_tb <= '0';
        WAIT FOR 20 ns;

        REPORT "=== SIMULACION VHDL COMPLETADA EXITOSAMENTE (0 ERRORES) ===" SEVERITY NOTE;
        sim_done <= TRUE;
        WAIT;
    END PROCESS stim_proc;

END ARCHITECTURE sim;
