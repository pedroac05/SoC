library ieee;
use ieee.std_logic_1164.all;

-- ============================================================================
-- Taller 8 - Ejercicio Propuesto: Envolvente Avalon MM-Slave para ALU FPU FP32
-- Mapa de registros (fpu_address[2:0]):
--   0 ("000") [W]   : op_a_reg (Operando A IEEE 754 de 32 bits)
--   1 ("001") [W]   : op_b_reg (Operando B IEEE 754 de 32 bits)
--   2 ("010") [W]   : selop_reg (bits 1..0: 00=+, 01=-, 10=*, 11=/)
--   3 ("011") [W]   : start (pulso de inicio de 1 ciclo - registro dummy)
--   4 ("100") [R]   : result (Resultado IEEE 754 de 32 bits)
--   5 ("101") [R]   : ready (bit 0)
--   6 ("110") [R/W] : done_tick_reg (Lectura: bit 0; Escritura: limpia bandera/IRQ)
-- ============================================================================
entity fpu_avalon is
    port (
        clk            : in  std_logic;
        reset          : in  std_logic;
        -- Interfaz Avalon-MM Slave (fpu_cpu)
        fpu_address    : in  std_logic_vector(2 downto 0);
        fpu_chipselect : in  std_logic;
        fpu_write      : in  std_logic;
        fpu_writedata  : in  std_logic_vector(31 downto 0);
        fpu_readdata   : out std_logic_vector(31 downto 0);
        -- Interfaz Interrupt Sender (fpu_intr)
        fpu_irq        : out std_logic
    );
end entity fpu_avalon;

architecture arch of fpu_avalon is
    component fpu_alu is
        port (
            clk       : in  std_logic;
            reset     : in  std_logic;
            start     : in  std_logic;
            op_a      : in  std_logic_vector(31 downto 0);
            op_b      : in  std_logic_vector(31 downto 0);
            selop     : in  std_logic_vector(1 downto 0);
            ready     : out std_logic;
            done_tick : out std_logic;
            result    : out std_logic_vector(31 downto 0)
        );
    end component;

    signal op_a_reg      : std_logic_vector(31 downto 0);
    signal op_b_reg      : std_logic_vector(31 downto 0);
    signal selop_reg     : std_logic_vector(1 downto 0);
    signal done_tick_reg : std_logic;

    signal fpu_start     : std_logic;
    signal fpu_ready     : std_logic;
    signal fpu_done_tick : std_logic;
    signal fpu_result    : std_logic_vector(31 downto 0);

    signal wr_en         : std_logic;
    signal wr_op_a       : std_logic;
    signal wr_op_b       : std_logic;
    signal wr_selop      : std_logic;
    signal clr_done_tick : std_logic;
begin
    -- 1. Instanciación de la ALU de Punto Flotante FP32
    fpu_unit : fpu_alu
        port map (
            clk       => clk,
            reset     => reset,
            start     => fpu_start,
            op_a      => op_a_reg,
            op_b      => op_b_reg,
            selop     => selop_reg,
            ready     => fpu_ready,
            done_tick => fpu_done_tick,
            result    => fpu_result
        );

    -- 2. Registros internos
    process (clk, reset)
    begin
        if reset = '1' then
            op_a_reg      <= (others => '0');
            op_b_reg      <= (others => '0');
            selop_reg     <= (others => '0');
            done_tick_reg <= '0';
        elsif rising_edge(clk) then
            if wr_op_a = '1' then
                op_a_reg <= fpu_writedata;
            end if;
            if wr_op_b = '1' then
                op_b_reg <= fpu_writedata;
            end if;
            if wr_selop = '1' then
                selop_reg <= fpu_writedata(1 downto 0);
            end if;
            if fpu_done_tick = '1' then
                done_tick_reg <= '1';
            elsif clr_done_tick = '1' then
                done_tick_reg <= '0';
            end if;
        end if;
    end process;

    -- 3. Decodificación de escritura Avalon
    wr_en         <= '1' when (fpu_write = '1' and fpu_chipselect = '1') else '0';
    wr_op_a       <= '1' when (fpu_address = "000" and wr_en = '1') else '0';
    wr_op_b       <= '1' when (fpu_address = "001" and wr_en = '1') else '0';
    wr_selop      <= '1' when (fpu_address = "010" and wr_en = '1') else '0';
    fpu_start     <= '1' when (fpu_address = "011" and wr_en = '1') else '0';
    clr_done_tick <= '1' when (fpu_address = "110" and wr_en = '1') else '0';

    -- 4. Multiplexación de lectura Avalon (combinacional -> Read wait = 0)
    with fpu_address select
        fpu_readdata <= fpu_result                                 when "100",
                        (31 downto 1 => '0') & fpu_ready           when "101",
                        (31 downto 1 => '0') & done_tick_reg       when others;

    -- 5. Señal de interrupción
    fpu_irq <= done_tick_reg;
end architecture arch;
