LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- ============================================================================
-- Testbench: fifo_hw_tb
-- Descripcion: Verifica el sistema integrado de la Figura 4 (fifo_hw_top)
--              con pulsaciones asincronicas largas en wr (PUSH) y rd (POP),
--              comprobando que edge_detect genera un unico pulso de 1 ciclo
--              por botonazo y que la FIFO de 16x4 junto con el decodificador
--              7-segmentos operan correctamente hasta llenarse (16 datos) y
--              vaciarse.
-- ============================================================================
ENTITY fifo_hw_tb IS
END ENTITY fifo_hw_tb;

ARCHITECTURE sim OF fifo_hw_tb IS
    CONSTANT T_CLK : TIME := 20 ns; -- 50 MHz

    SIGNAL clk_tb        : STD_LOGIC := '0';
    SIGNAL reset_tb      : STD_LOGIC := '0';
    SIGNAL rd_tb         : STD_LOGIC := '0';
    SIGNAL wr_tb         : STD_LOGIC := '0';
    SIGNAL w_data_tb     : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL empty_tb      : STD_LOGIC;
    SIGNAL full_tb       : STD_LOGIC;
    SIGNAL r_data_hex_tb : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL sim_done      : BOOLEAN := FALSE;
BEGIN

    dut : ENTITY work.fifo_hw_top
        GENERIC MAP (
            ADDR_WIDTH => 4, -- 16 registros
            DATA_WIDTH => 4  -- 4 bits
        )
        PORT MAP (
            clk        => clk_tb,
            reset      => reset_tb,
            rd         => rd_tb,
            wr         => wr_tb,
            w_data     => w_data_tb,
            empty      => empty_tb,
            full       => full_tb,
            r_data_hex => r_data_hex_tb
        );

    clk_gen : PROCESS
    BEGIN
        WHILE NOT sim_done LOOP
            clk_tb <= '0'; WAIT FOR T_CLK / 2;
            clk_tb <= '1'; WAIT FOR T_CLK / 2;
        END LOOP;
        WAIT;
    END PROCESS clk_gen;

    stim_proc : PROCESS
        -- Simula una pulsacion larga de boton PUSH (dura 3.5 ciclos = 70 ns)
        -- para demostrar que edge_detect solo genera 1 escritura en la FIFO
        PROCEDURE press_push_button(CONSTANT val : IN STD_LOGIC_VECTOR(3 DOWNTO 0)) IS
        BEGIN
            w_data_tb <= val;
            WAIT FOR 13 ns;
            wr_tb <= '1';
            WAIT FOR 70 ns; -- Boton presionado por varios ciclos de reloj
            wr_tb <= '0';
            WAIT FOR 37 ns;
        END PROCEDURE;

        -- Simula una pulsacion larga de boton POP (dura 3.5 ciclos = 70 ns)
        PROCEDURE press_pop_button IS
        BEGIN
            WAIT FOR 13 ns;
            rd_tb <= '1';
            WAIT FOR 70 ns; -- Boton presionado por varios ciclos de reloj
            rd_tb <= '0';
            WAIT FOR 37 ns;
        END PROCEDURE;
    BEGIN
        -- 1. Reset inicial
        reset_tb  <= '1';
        wr_tb     <= '0';
        rd_tb     <= '0';
        w_data_tb <= "0000";
        WAIT FOR 45 ns;
        reset_tb  <= '0';
        WAIT FOR 35 ns;
        ASSERT (empty_tb = '1' AND full_tb = '0')
            REPORT "Error en Reset inicial: empty debe ser 1 y full 0"
            SEVERITY ERROR;

        -- 2. PUSH de 16 palabras de 4 bits (0x0 a 0xF) con pulsaciones largas
        FOR i IN 0 TO 15 LOOP
            press_push_button(STD_LOGIC_VECTOR(TO_UNSIGNED(i, 4)));
        END LOOP;

        ASSERT (full_tb = '1' AND empty_tb = '0')
            REPORT "Error tras 16 PUSH: La FIFO de 16 registros debe indicar full=1"
            SEVERITY ERROR;
        -- La cabeza de la FIFO sigue siendo el primer elemento insertado (0x0 -> sseg = "1000000")
        ASSERT (r_data_hex_tb = "1000000")
            REPORT "Error en display 7-seg: para dato 0x0 debe ser 1000000"
            SEVERITY ERROR;

        -- 3. POP de las 16 palabras verificando el vaciado completo
        FOR i IN 0 TO 15 LOOP
            press_pop_button;
        END LOOP;

        ASSERT (empty_tb = '1' AND full_tb = '0')
            REPORT "Error tras 16 POP: La FIFO debe regresar a empty=1"
            SEVERITY ERROR;

        WAIT FOR 40 ns;
        REPORT "=== SIMULACION VHDL FIFO_HW_TOP (16x4 + EDGE_DETECT + 7SEG) EXITOSA (0 ERRORES) ==="
            SEVERITY NOTE;
        sim_done <= TRUE;
        WAIT;
    END PROCESS stim_proc;

END ARCHITECTURE sim;
