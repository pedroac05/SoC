-- ==============================================================================
-- Pontificia Universidad Javeriana - Departamento de Electronica
-- System on Chip (SoC) - Taller 4: Circuitos Secuenciales (Contadores)
-- Modulo: univ_bin_counter (Contador Binario Universal Parametrizable)
-- ==============================================================================
-- Caracteristicas:
--   * N         : Ancho del registro contador en bits (default = 4).
--   * MAX_COUNT : Valor maximo de conteo (default = 2^N - 1).
--   * Prioridad de control: rst (asincrono) > syn_clr > load > ena (up/down).
--   * Banderas  : max_tick = '1' cuando counter = MAX_COUNT;
--                 min_tick = '1' cuando counter = 0.
-- ==============================================================================

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY univ_bin_counter IS
    GENERIC (
        N         : INTEGER := 4;
        MAX_COUNT : STD_LOGIC_VECTOR := "1111"
    );
    PORT (
        clk      : IN  STD_LOGIC;
        rst      : IN  STD_LOGIC;
        ena      : IN  STD_LOGIC;
        syn_clr  : IN  STD_LOGIC;
        load     : IN  STD_LOGIC;
        up       : IN  STD_LOGIC;
        d        : IN  STD_LOGIC_VECTOR(N-1 DOWNTO 0);
        max_tick : OUT STD_LOGIC;
        min_tick : OUT STD_LOGIC;
        counter  : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
    );
END ENTITY univ_bin_counter;

ARCHITECTURE rtl OF univ_bin_counter IS
    CONSTANT ZEROS      : UNSIGNED(N-1 DOWNTO 0) := (OTHERS => '0');
    CONSTANT MAX_VAL    : UNSIGNED(N-1 DOWNTO 0) := RESIZE(UNSIGNED(MAX_COUNT), N);

    SIGNAL count_s      : UNSIGNED(N-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL count_next   : UNSIGNED(N-1 DOWNTO 0);
BEGIN

    -- ==========================================================================
    -- 1. Registro de estado secuencial (flanco ascendente de clk, reset asincrono)
    -- ==========================================================================
    seq_reg : PROCESS(clk, rst)
    BEGIN
        IF (rst = '1') THEN
            count_s <= ZEROS;
        ELSIF (rising_edge(clk)) THEN
            count_s <= count_next;
        END IF;
    END PROCESS seq_reg;

    -- ==========================================================================
    -- 2. Logica combinacional de estado siguiente
    --    Prioridad: syn_clr > load > (ena & up) > (ena & not up) > hold
    -- ==========================================================================
    count_next <= ZEROS            WHEN (syn_clr = '1') ELSE
                  UNSIGNED(d)      WHEN (load = '1') ELSE
                  ZEROS            WHEN (ena = '1' AND up = '1' AND count_s = MAX_VAL) ELSE
                  count_s + 1      WHEN (ena = '1' AND up = '1') ELSE
                  MAX_VAL          WHEN (ena = '1' AND up = '0' AND count_s = ZEROS) ELSE
                  count_s - 1      WHEN (ena = '1' AND up = '0') ELSE
                  count_s;

    -- ==========================================================================
    -- 3. Logica de salida y banderas de fin de conteo
    -- ==========================================================================
    counter  <= STD_LOGIC_VECTOR(count_s);
    max_tick <= '1' WHEN (count_s = MAX_VAL) ELSE '0';
    min_tick <= '1' WHEN (count_s = ZEROS)   ELSE '0';

END ARCHITECTURE rtl;
