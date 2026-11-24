LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- ============================================================================
-- Entidad: fifo_hw_top
-- Descripcion: Circuito de prueba en hardware de la estructura Buffer FIFO
--              con interfase de usuario (Figura 4 del Taller 6).
--              - Datos de entrada: 4 bits (DATA_WIDTH = 4)
--              - Profundidad FIFO: 16 registros (ADDR_WIDTH = 4)
--              - Dos detectores de flanco (edge_detect) para wr (push) y rd (pop)
--              - Conversor bin_to_sseg para visualizacion en display 7-segmentos
-- ============================================================================
ENTITY fifo_hw_top IS
    GENERIC (
        ADDR_WIDTH : INTEGER := 4; -- 2^4 = 16 registros de profundidad
        DATA_WIDTH : INTEGER := 4  -- Palabras de 4 bits
    );
    PORT (
        clk        : IN  STD_LOGIC;
        reset      : IN  STD_LOGIC;
        rd         : IN  STD_LOGIC;
        wr         : IN  STD_LOGIC;
        w_data     : IN  STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
        empty      : OUT STD_LOGIC;
        full       : OUT STD_LOGIC;
        r_data_hex : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END ENTITY fifo_hw_top;

ARCHITECTURE structural OF fifo_hw_top IS
    SIGNAL rd_tick  : STD_LOGIC;
    SIGNAL wr_tick  : STD_LOGIC;
    SIGNAL r_data_s : STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
BEGIN

    -- Detector de flanco de subida para lectura (POP)
    pop_tick_gen : ENTITY work.edge_detect
        PORT MAP (
            clk       => clk,
            async_sig => rd,
            rise      => rd_tick,
            fall      => OPEN
        );

    -- Detector de flanco de subida para escritura (PUSH)
    push_tick_gen : ENTITY work.edge_detect
        PORT MAP (
            clk       => clk,
            async_sig => wr,
            rise      => wr_tick,
            fall      => OPEN
        );

    -- Buffer FIFO circular (16 registros x 4 bits)
    fifo_buffer : ENTITY work.fifo
        GENERIC MAP (
            ADDR_WIDTH => ADDR_WIDTH,
            DATA_WIDTH => DATA_WIDTH
        )
        PORT MAP (
            clk    => clk,
            reset  => reset,
            rd     => rd_tick,
            wr     => wr_tick,
            w_data => w_data,
            empty  => empty,
            full   => full,
            r_data => r_data_s
        );

    -- Conversor de 4 bits a display 7-segmentos
    bin2sseg : ENTITY work.bin_to_sseg
        PORT MAP (
            bin  => r_data_s,
            sseg => r_data_hex
        );

END ARCHITECTURE structural;
