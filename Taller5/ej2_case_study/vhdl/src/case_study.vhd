-- ============================================================================
-- Pontificia Universidad Javeriana - System on Chip (SoC)
-- Taller 5: Timing Simulation - Ejercicio No. 2: Caso de Estudio (Figura 13)
-- Descripcion:
--   Circuito con registros de entrada (A, B), cadenas combinacionales con
--   distinta profundidad logica (1 inversor, 3 inversores en serie y 5
--   compuertas AND en cascada) y salidas tanto directas (*_XL) como
--   registradas (*_XL_reg).
--   Se utiliza el atributo de sintesis KEEP (LCELL) para preservar cada
--   nivel logico como una celda fisica independiente en la FPGA y poder
--   medir sus retardos acumulativos de propagacion.
-- ============================================================================

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY case_study IS
    PORT (
        clk         : IN  STD_LOGIC;
        A           : IN  STD_LOGIC;
        B           : IN  STD_LOGIC;
        Aneg_1L     : OUT STD_LOGIC;
        Aneg_1L_reg : OUT STD_LOGIC;
        Bneg_3L     : OUT STD_LOGIC;
        Bneg_3L_reg : OUT STD_LOGIC;
        and_1L      : OUT STD_LOGIC;
        and_1L_reg  : OUT STD_LOGIC;
        and_2L      : OUT STD_LOGIC;
        and_2L_reg  : OUT STD_LOGIC;
        and_3L      : OUT STD_LOGIC;
        and_3L_reg  : OUT STD_LOGIC;
        and_4L      : OUT STD_LOGIC;
        and_4L_reg  : OUT STD_LOGIC;
        and_5L      : OUT STD_LOGIC;
        and_5L_reg  : OUT STD_LOGIC
    );
END ENTITY case_study;

ARCHITECTURE rtl OF case_study IS

    -- Registros de entrada (Flip-Flops D para A y B)
    SIGNAL A_reg : STD_LOGIC := '0';
    SIGNAL B_reg : STD_LOGIC := '0';

    -- Camino 1: 1 nivel de inversor sobre A_reg
    SIGNAL not_a1 : STD_LOGIC;

    -- Camino 2: 3 niveles de inversores en serie sobre B_reg
    SIGNAL not_b1 : STD_LOGIC;
    SIGNAL not_b2 : STD_LOGIC;
    SIGNAL not_b3 : STD_LOGIC;

    -- Caminos 3..7: 5 niveles de compuertas AND en cascada
    SIGNAL and_1L_s : STD_LOGIC;
    SIGNAL and_2L_s : STD_LOGIC;
    SIGNAL and_3L_s : STD_LOGIC;
    SIGNAL and_4L_s : STD_LOGIC;
    SIGNAL and_5L_s : STD_LOGIC;

    -- Registros de salida (Flip-Flops D)
    SIGNAL Aneg_1L_q : STD_LOGIC := '0';
    SIGNAL Bneg_3L_q : STD_LOGIC := '0';
    SIGNAL and_1L_q  : STD_LOGIC := '0';
    SIGNAL and_2L_q  : STD_LOGIC := '0';
    SIGNAL and_3L_q  : STD_LOGIC := '0';
    SIGNAL and_4L_q  : STD_LOGIC := '0';
    SIGNAL and_5L_q  : STD_LOGIC := '0';

    -- Atributo KEEP para evitar que el sintetizador colapse algebraicamente
    -- los 3 inversores en 1 o la cascada de 5 compuertas AND en 1 sola LUT
    ATTRIBUTE keep : BOOLEAN;
    ATTRIBUTE keep OF not_a1   : SIGNAL IS TRUE;
    ATTRIBUTE keep OF not_b1   : SIGNAL IS TRUE;
    ATTRIBUTE keep OF not_b2   : SIGNAL IS TRUE;
    ATTRIBUTE keep OF not_b3   : SIGNAL IS TRUE;
    ATTRIBUTE keep OF and_1L_s : SIGNAL IS TRUE;
    ATTRIBUTE keep OF and_2L_s : SIGNAL IS TRUE;
    ATTRIBUTE keep OF and_3L_s : SIGNAL IS TRUE;
    ATTRIBUTE keep OF and_4L_s : SIGNAL IS TRUE;
    ATTRIBUTE keep OF and_5L_s : SIGNAL IS TRUE;

BEGIN

    -- ========================================================================
    -- 1. Registros de Entrada (Flip-Flops D sincronizados con clk)
    -- ========================================================================
    input_regs : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            A_reg <= A;
            B_reg <= B;
        END IF;
    END PROCESS input_regs;

    -- ========================================================================
    -- 2. Redes Combinacionales por Niveles Logicos (Figura 13)
    -- ========================================================================
    -- 1 inversor para A
    not_a1 <= NOT A_reg;

    -- 3 inversores en cascada para B
    not_b1 <= NOT B_reg;
    not_b2 <= NOT not_b1;
    not_b3 <= NOT not_b2;

    -- 5 compuertas AND de 2 entradas en cascada
    and_1L_s <= A_reg    AND B_reg;
    and_2L_s <= and_1L_s AND A_reg;
    and_3L_s <= and_2L_s AND A_reg;
    and_4L_s <= and_3L_s AND A_reg;
    and_5L_s <= and_4L_s AND A_reg;

    -- ========================================================================
    -- 3. Registros de Salida (Flip-Flops D sincronizados con clk)
    -- ========================================================================
    output_regs : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            Aneg_1L_q <= not_a1;
            Bneg_3L_q <= not_b3;
            and_1L_q  <= and_1L_s;
            and_2L_q  <= and_2L_s;
            and_3L_q  <= and_3L_s;
            and_4L_q  <= and_4L_s;
            and_5L_q  <= and_5L_s;
        END IF;
    END PROCESS output_regs;

    -- ========================================================================
    -- 4. Asignacion de Puertos de Salida Directos y Registrados
    -- ========================================================================
    Aneg_1L     <= not_a1;
    Aneg_1L_reg <= Aneg_1L_q;

    Bneg_3L     <= not_b3;
    Bneg_3L_reg <= Bneg_3L_q;

    and_1L      <= and_1L_s;
    and_1L_reg  <= and_1L_q;

    and_2L      <= and_2L_s;
    and_2L_reg  <= and_2L_q;

    and_3L      <= and_3L_s;
    and_3L_reg  <= and_3L_q;

    and_4L      <= and_4L_s;
    and_4L_reg  <= and_4L_q;

    and_5L      <= and_5L_s;
    and_5L_reg  <= and_5L_q;

END ARCHITECTURE rtl;
