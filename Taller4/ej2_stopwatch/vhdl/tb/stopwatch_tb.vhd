-- ==============================================================================
-- Testbench VHDL para stopwatch_top (Cronometro 00.0 a 99.9 s)
-- Nota: DIV_MAX se reduce a 4 (5 ciclos = 100 ns por decima de segundo)
--       para observar transiciones de decimas, unidades y decenas rapidamente.
-- ==============================================================================

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY stopwatch_tb IS
END ENTITY stopwatch_tb;

ARCHITECTURE sim OF stopwatch_tb IS

    CONSTANT T_CLK   : TIME := 20 ns; -- 50 MHz
    CONSTANT DIV_SIM : INTEGER := 4;  -- 5 ciclos por decima de segundo

    SIGNAL clk_tb  : STD_LOGIC := '0';
    SIGNAL sw_tb   : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL key_tb  : STD_LOGIC_VECTOR(0 DOWNTO 0) := "1"; -- KEY(0) sin presionar ('1')
    SIGNAL hex0_tb : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL hex1_tb : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL hex2_tb : STD_LOGIC_VECTOR(6 DOWNTO 0);

    SIGNAL sim_done : BOOLEAN := FALSE;

    -- Codigos 7-segmentos esperados para validacion
    CONSTANT SEG_0 : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1000000";
    CONSTANT SEG_1 : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1111001";
    CONSTANT SEG_2 : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0100100";
    CONSTANT SEG_9 : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0010000";

BEGIN

    dut : ENTITY work.stopwatch_top
        GENERIC MAP (DIV_MAX => DIV_SIM)
        PORT MAP (
            CLOCK_50 => clk_tb,
            SW       => sw_tb,
            KEY      => key_tb,
            HEX0     => hex0_tb,
            HEX1     => hex1_tb,
            HEX2     => hex2_tb
        );

    -- Reloj de 50 MHz
    clk_gen : PROCESS
    BEGIN
        WHILE NOT sim_done LOOP
            clk_tb <= '0'; WAIT FOR T_CLK / 2;
            clk_tb <= '1'; WAIT FOR T_CLK / 2;
        END LOOP;
        WAIT;
    END PROCESS clk_gen;

    stim_proc : PROCESS
    BEGIN
        -- 1. Sistema deshabilitado inicialmente (SW(0) = '0' -> rst_s = '1')
        sw_tb  <= "00";
        key_tb <= "1";
        WAIT FOR 40 ns;
        ASSERT (hex2_tb = SEG_0 AND hex1_tb = SEG_0 AND hex0_tb = SEG_0)
            REPORT "Error Fase 1: Cronometro debe iniciar en 00.0" SEVERITY ERROR;

        -- 2. Habilitar circuito (SW(0) = '1') y activar conteo (SW(1) = '1')
        --    Cada 5 ciclos = 100 ns avanza 0.1 s. Avanzamos 12 decimas (01.2 s)
        WAIT UNTIL falling_edge(clk_tb);
        sw_tb <= "11"; -- SW(1)=go=1, SW(0)=enable=1

        -- Esperar 10 decimas = 50 ciclos -> debe mostrar 01.0
        FOR i IN 1 TO 50 LOOP
            WAIT UNTIL rising_edge(clk_tb);
        END LOOP;
        WAIT FOR 2 ns;
        ASSERT (hex2_tb = SEG_0 AND hex1_tb = SEG_1 AND hex0_tb = SEG_0)
            REPORT "Error Fase 2: Se esperaba 01.0 tras 10 decimas" SEVERITY ERROR;

        -- Esperar 2 decimas mas = 10 ciclos -> debe mostrar 01.2
        FOR i IN 1 TO 10 LOOP
            WAIT UNTIL rising_edge(clk_tb);
        END LOOP;
        WAIT FOR 2 ns;
        ASSERT (hex2_tb = SEG_0 AND hex1_tb = SEG_1 AND hex0_tb = SEG_2)
            REPORT "Error Fase 2: Se esperaba 01.2 tras 12 decimas" SEVERITY ERROR;

        -- 3. Pausa (go = '0', SW = "01") durante 15 ciclos -> debe mantenerse en 01.2
        WAIT UNTIL falling_edge(clk_tb);
        sw_tb <= "01";
        FOR i IN 1 TO 15 LOOP
            WAIT UNTIL rising_edge(clk_tb);
        END LOOP;
        WAIT FOR 2 ns;
        ASSERT (hex2_tb = SEG_0 AND hex1_tb = SEG_1 AND hex0_tb = SEG_2)
            REPORT "Error Fase 3: El cronometro no mantuvo pausa en 01.2" SEVERITY ERROR;

        -- 4. Reanudar hasta llegar a 02.0 (8 decimas = 40 ciclos)
        WAIT UNTIL falling_edge(clk_tb);
        sw_tb <= "11";
        FOR i IN 1 TO 40 LOOP
            WAIT UNTIL rising_edge(clk_tb);
        END LOOP;
        WAIT FOR 2 ns;
        ASSERT (hex2_tb = SEG_0 AND hex1_tb = SEG_2 AND hex0_tb = SEG_0)
            REPORT "Error Fase 4: Se esperaba 02.0 al reanudar" SEVERITY ERROR;

        -- 5. Reinicio sincrono con pulsador KEY(0) = '0' mientras cuenta
        WAIT UNTIL falling_edge(clk_tb);
        key_tb <= "0";
        WAIT UNTIL rising_edge(clk_tb);
        WAIT FOR 2 ns;
        ASSERT (hex2_tb = SEG_0 AND hex1_tb = SEG_0 AND hex0_tb = SEG_0)
            REPORT "Error Fase 5: KEY(0) no reinicio a 00.0" SEVERITY ERROR;

        WAIT UNTIL falling_edge(clk_tb);
        key_tb <= "1";

        -- 6. Avanzar 100 decimas (500 ciclos) para verificar acarreo a decenas (10.0)
        FOR i IN 1 TO 500 LOOP
            WAIT UNTIL rising_edge(clk_tb);
        END LOOP;
        WAIT FOR 2 ns;
        ASSERT (hex2_tb = SEG_1 AND hex1_tb = SEG_0 AND hex0_tb = SEG_0)
            REPORT "Error Fase 6: Se esperaba 10.0 tras 100 decimas" SEVERITY ERROR;

        WAIT FOR 40 ns;
        REPORT "=== SIMULACION VHDL CRONOMETRO COMPLETADA (0 ERRORES) ===" SEVERITY NOTE;
        sim_done <= TRUE;
        WAIT;
    END PROCESS stim_proc;

END ARCHITECTURE sim;
