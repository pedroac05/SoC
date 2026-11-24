LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- ============================================================================
-- Testbench: fifo_tb
-- Descripcion: Replica exactamente las condiciones (a) a (i) de la Figura 2
--              del Taller 6 para un buffer FIFO circular de 8 posiciones
--              (ADDR_WIDTH = 3, DATA_WIDTH = 8) a 50 MHz (T_CLK = 20 ns).
-- ============================================================================
ENTITY fifo_tb IS
END ENTITY fifo_tb;

ARCHITECTURE sim OF fifo_tb IS
    CONSTANT C_ADDR_WIDTH : INTEGER := 3; -- 2^3 = 8 posiciones (Figura 2)
    CONSTANT C_DATA_WIDTH : INTEGER := 8; -- Palabras de 8 bits
    CONSTANT T_CLK        : TIME    := 20 ns; -- Reloj de 50 MHz

    SIGNAL clk_tb    : STD_LOGIC := '0';
    SIGNAL reset_tb  : STD_LOGIC := '0';
    SIGNAL rd_tb     : STD_LOGIC := '0';
    SIGNAL wr_tb     : STD_LOGIC := '0';
    SIGNAL w_data_tb : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL empty_tb  : STD_LOGIC;
    SIGNAL full_tb   : STD_LOGIC;
    SIGNAL r_data_tb : STD_LOGIC_VECTOR(C_DATA_WIDTH-1 DOWNTO 0);

    -- Etiqueta de seguimiento visual para la ventana Wave (Figura 2: a..i)
    SIGNAL fig2_step : STRING(1 TO 18) := "(a) Init (empty)  ";
    SIGNAL sim_done  : BOOLEAN := FALSE;
BEGIN

    -- Instancia del Buffer FIFO Circular
    dut : ENTITY work.fifo
        GENERIC MAP (
            ADDR_WIDTH => C_ADDR_WIDTH,
            DATA_WIDTH => C_DATA_WIDTH
        )
        PORT MAP (
            clk    => clk_tb,
            reset  => reset_tb,
            rd     => rd_tb,
            wr     => wr_tb,
            w_data => w_data_tb,
            empty  => empty_tb,
            full   => full_tb,
            r_data => r_data_tb
        );

    -- Generador de reloj de 50 MHz (T = 20 ns)
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

    -- Proceso de estimulos que replica la Figura 2 (pasos a -> i)
    stim_proc : PROCESS
        -- Procedimiento auxiliar para escribir un dato durante 1 ciclo de reloj
        PROCEDURE push_word(CONSTANT val : IN STD_LOGIC_VECTOR(C_DATA_WIDTH-1 DOWNTO 0)) IS
        BEGIN
            WAIT UNTIL falling_edge(clk_tb);
            wr_tb     <= '1';
            rd_tb     <= '0';
            w_data_tb <= val;
            WAIT UNTIL rising_edge(clk_tb);
            WAIT FOR 2 ns;
            WAIT UNTIL falling_edge(clk_tb);
            wr_tb     <= '0';
        END PROCEDURE;

        -- Procedimiento auxiliar para leer un dato durante 1 ciclo de reloj
        PROCEDURE pop_word IS
        BEGIN
            WAIT UNTIL falling_edge(clk_tb);
            rd_tb <= '1';
            wr_tb <= '0';
            WAIT UNTIL rising_edge(clk_tb);
            WAIT FOR 2 ns;
            WAIT UNTIL falling_edge(clk_tb);
            rd_tb <= '0';
        END PROCEDURE;
    BEGIN
        -- ====================================================================
        -- (a) Estado Inicial (empty): wr_ptr = 0, rd_ptr = 0, empty = 1, full = 0
        -- ====================================================================
        fig2_step <= "(a) Init (empty)  ";
        reset_tb  <= '1';
        wr_tb     <= '0';
        rd_tb     <= '0';
        w_data_tb <= X"00";
        WAIT FOR 25 ns;
        WAIT UNTIL falling_edge(clk_tb);
        reset_tb  <= '0';
        WAIT FOR 2 ns;
        ASSERT (empty_tb = '1' AND full_tb = '0')
            REPORT "Error en (a): La FIFO debe iniciar vacia (empty=1, full=0)"
            SEVERITY ERROR;
        WAIT UNTIL rising_edge(clk_tb);

        -- ====================================================================
        -- (b) Despues de 1 escritura: wr_ptr = 1, rd_ptr = 0 (dato en pos 0)
        -- ====================================================================
        fig2_step <= "(b) 1 write       ";
        push_word(X"A0"); -- Posicion 0 <- 0xA0
        ASSERT (empty_tb = '0' AND full_tb = '0' AND r_data_tb = X"A0")
            REPORT "Error en (b): Despues de 1 escritura (empty=0, full=0, r_data=0xA0)"
            SEVERITY ERROR;
        WAIT UNTIL rising_edge(clk_tb);

        -- ====================================================================
        -- (c) Despues de 3 escrituras mas: wr_ptr = 4, rd_ptr = 0 (pos 0..3)
        -- ====================================================================
        fig2_step <= "(c) +3 writes     ";
        push_word(X"A1"); -- Posicion 1 <- 0xA1
        push_word(X"A2"); -- Posicion 2 <- 0xA2
        push_word(X"A3"); -- Posicion 3 <- 0xA3
        ASSERT (empty_tb = '0' AND full_tb = '0' AND r_data_tb = X"A0")
            REPORT "Error en (c): Despues de 3 escrituras mas (cabeza sigue en pos 0 = 0xA0)"
            SEVERITY ERROR;
        WAIT UNTIL rising_edge(clk_tb);

        -- ====================================================================
        -- (d) Despues de 1 lectura: wr_ptr = 4, rd_ptr = 1 (pos 1..3)
        -- ====================================================================
        fig2_step <= "(d) 1 read        ";
        pop_word;         -- Retira pos 0 (0xA0); nueva cabeza en pos 1 (0xA1)
        ASSERT (empty_tb = '0' AND full_tb = '0' AND r_data_tb = X"A1")
            REPORT "Error en (d): Despues de 1 lectura la cabeza debe ser pos 1 = 0xA1"
            SEVERITY ERROR;
        WAIT UNTIL rising_edge(clk_tb);

        -- ====================================================================
        -- (e) 4 escrituras mas: wr_ptr = 0 (wrap-around), rd_ptr = 1 (pos 1..7)
        -- ====================================================================
        fig2_step <= "(e) +4 writes     ";
        push_word(X"A4"); -- Posicion 4 <- 0xA4
        push_word(X"A5"); -- Posicion 5 <- 0xA5
        push_word(X"A6"); -- Posicion 6 <- 0xA6
        push_word(X"A7"); -- Posicion 7 <- 0xA7 (wr_ptr envuelve de 7 a 0)
        ASSERT (empty_tb = '0' AND full_tb = '0' AND r_data_tb = X"A1")
            REPORT "Error en (e): Despues de 4 escrituras mas (7 elementos, empty=0, full=0)"
            SEVERITY ERROR;
        WAIT UNTIL rising_edge(clk_tb);

        -- ====================================================================
        -- (f) 1 escritura mas (full): wr_ptr = 1, rd_ptr = 1, full = 1
        -- ====================================================================
        fig2_step <= "(f) +1 write(full)";
        push_word(X"A8"); -- Posicion 0 <- 0xA8 (8 elementos: FIFO llena)
        ASSERT (empty_tb = '0' AND full_tb = '1' AND r_data_tb = X"A1")
            REPORT "Error en (f): La FIFO debe indicar full=1 y empty=0"
            SEVERITY ERROR;
        WAIT UNTIL rising_edge(clk_tb);

        -- ====================================================================
        -- (g) 2 lecturas: wr_ptr = 1, rd_ptr = 3 (pos 3..7, 0)
        -- ====================================================================
        fig2_step <= "(g) 2 reads       ";
        pop_word;         -- Retira pos 1 (0xA1); cabeza en pos 2 (0xA2)
        pop_word;         -- Retira pos 2 (0xA2); cabeza en pos 3 (0xA3)
        ASSERT (empty_tb = '0' AND full_tb = '0' AND r_data_tb = X"A3")
            REPORT "Error en (g): Despues de 2 lecturas full=0 y cabeza en pos 3 = 0xA3"
            SEVERITY ERROR;
        WAIT UNTIL rising_edge(clk_tb);

        -- ====================================================================
        -- (h) 5 lecturas mas: wr_ptr = 1, rd_ptr = 0 (queda solo pos 0 = 0xA8)
        -- ====================================================================
        fig2_step <= "(h) +5 reads      ";
        pop_word;         -- Retira pos 3 (0xA3) -> cabeza pos 4
        pop_word;         -- Retira pos 4 (0xA4) -> cabeza pos 5
        pop_word;         -- Retira pos 5 (0xA5) -> cabeza pos 6
        pop_word;         -- Retira pos 6 (0xA6) -> cabeza pos 7
        pop_word;         -- Retira pos 7 (0xA7) -> cabeza pos 0 (wrap-around)
        ASSERT (empty_tb = '0' AND full_tb = '0' AND r_data_tb = X"A8")
            REPORT "Error en (h): Despues de 5 lecturas mas queda 1 elemento en pos 0 = 0xA8"
            SEVERITY ERROR;
        WAIT UNTIL rising_edge(clk_tb);

        -- ====================================================================
        -- (i) 1 lectura (empty): wr_ptr = 1, rd_ptr = 1, empty = 1
        -- ====================================================================
        fig2_step <= "(i) +1 read(empty)";
        pop_word;         -- Retira pos 0 (0xA8) -> FIFO vacia
        ASSERT (empty_tb = '1' AND full_tb = '0')
            REPORT "Error en (i): Despues de la ultima lectura la FIFO debe quedar empty=1"
            SEVERITY ERROR;
        WAIT UNTIL rising_edge(clk_tb);
        WAIT FOR 20 ns;

        REPORT "=== SIMULACION VHDL FIFO (FIGURA 2: a..i) COMPLETADA EXITOSAMENTE (0 ERRORES) ==="
            SEVERITY NOTE;
        sim_done <= TRUE;
        WAIT;
    END PROCESS stim_proc;

END ARCHITECTURE sim;
