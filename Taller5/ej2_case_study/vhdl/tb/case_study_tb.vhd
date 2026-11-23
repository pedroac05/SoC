-- ============================================================================
-- Testbench Funcional para el Ejercicio No. 2: Caso de Estudio (Figura 13)
-- Reloj base: 50 MHz (periodo 20 ns)
-- ============================================================================

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY case_study_tb IS
END ENTITY case_study_tb;

ARCHITECTURE testbench OF case_study_tb IS
    SIGNAL clk_tb         : STD_LOGIC := '0';
    SIGNAL A_tb           : STD_LOGIC := '0';
    SIGNAL B_tb           : STD_LOGIC := '0';
    SIGNAL Aneg_1L_tb     : STD_LOGIC;
    SIGNAL Aneg_1L_reg_tb : STD_LOGIC;
    SIGNAL Bneg_3L_tb     : STD_LOGIC;
    SIGNAL Bneg_3L_reg_tb : STD_LOGIC;
    SIGNAL and_1L_tb      : STD_LOGIC;
    SIGNAL and_1L_reg_tb  : STD_LOGIC;
    SIGNAL and_2L_tb      : STD_LOGIC;
    SIGNAL and_2L_reg_tb  : STD_LOGIC;
    SIGNAL and_3L_tb      : STD_LOGIC;
    SIGNAL and_3L_reg_tb  : STD_LOGIC;
    SIGNAL and_4L_tb      : STD_LOGIC;
    SIGNAL and_4L_reg_tb  : STD_LOGIC;
    SIGNAL and_5L_tb      : STD_LOGIC;
    SIGNAL and_5L_reg_tb  : STD_LOGIC;
BEGIN

    -- Generacion de reloj de 50 MHz (periodo = 20 ns)
    clk_tb <= NOT clk_tb AFTER 10 ns;

    -- Instancia del Dispositivo Bajo Prueba (DUT)
    dut : ENTITY work.case_study
        PORT MAP (
            clk         => clk_tb,
            A           => A_tb,
            B           => B_tb,
            Aneg_1L     => Aneg_1L_tb,
            Aneg_1L_reg => Aneg_1L_reg_tb,
            Bneg_3L     => Bneg_3L_tb,
            Bneg_3L_reg => Bneg_3L_reg_tb,
            and_1L      => and_1L_tb,
            and_1L_reg  => and_1L_reg_tb,
            and_2L      => and_2L_tb,
            and_2L_reg  => and_2L_reg_tb,
            and_3L      => and_3L_tb,
            and_3L_reg  => and_3L_reg_tb,
            and_4L      => and_4L_tb,
            and_4L_reg  => and_4L_reg_tb,
            and_5L      => and_5L_tb,
            and_5L_reg  => and_5L_reg_tb
        );

    -- Proceso de estimulos para evaluar todas las cadenas de retardo
    stim_proc : PROCESS
    BEGIN
        -- Estado inicial: A = 0, B = 0 (40 ns)
        A_tb <= '0';
        B_tb <= '0';
        WAIT FOR 40 ns;

        -- Fase 1: Activar A = 1 (evalua Aneg_1L: 1 -> 0)
        A_tb <= '1';
        B_tb <= '0';
        WAIT FOR 60 ns;

        -- Fase 2: Con A = 1 fijo, conmutar B: 0 -> 1
        -- Esto propaga el flanco ascendente por los 3 inversores (Bneg_3L)
        -- y secuencialmente por las 5 compuertas AND (and_1L -> and_2L -> and_3L -> and_4L -> and_5L)
        A_tb <= '1';
        B_tb <= '1';
        WAIT FOR 80 ns;

        -- Fase 3: Con A = 1 fijo, conmutar B: 1 -> 0
        -- Esto propaga el flanco descendente en cascada por las 5 compuertas AND y los 3 inversores
        A_tb <= '1';
        B_tb <= '0';
        WAIT FOR 80 ns;

        -- Fase 4: Conmutar A y B simultaneamente a 1 y luego A: 1 -> 0
        A_tb <= '1';
        B_tb <= '1';
        WAIT FOR 80 ns;

        A_tb <= '0';
        B_tb <= '1';
        WAIT FOR 80 ns;

        A_tb <= '0';
        B_tb <= '0';
        WAIT FOR 80 ns;

        WAIT;
    END PROCESS stim_proc;

END ARCHITECTURE testbench;
