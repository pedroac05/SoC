library ieee;
use ieee.std_logic_1164.all;

-- ============================================================================
-- Taller 8 - Actividad 2: Circuito Envolvente Avalon MM-Slave (divisor_avalon)
-- Mapa de registros (div_address[2:0]):
--   0 ("000") [W]   : dvnd_reg (dividendo)
--   1 ("001") [W]   : dvsr_reg (divisor)
--   2 ("010") [W]   : start (pulso de inicio de 1 ciclo - registro dummy)
--   3 ("011") [R]   : quo (cociente)
--   4 ("100") [R]   : rmd (residuo)
--   5 ("101") [R]   : ready (bit 0)
--   6 ("110") [R/W] : done_tick_reg (lectura: bit 0; escritura: limpia bandera/IRQ)
-- ============================================================================
entity divisor_avalon is
    generic (
        W    : integer := 32;
        CBIT : integer := 6
    );
    port (
        clk            : in  std_logic;
        reset          : in  std_logic;
        -- Interfaz Avalon-MM Slave (div_cpu)
        div_address    : in  std_logic_vector(2 downto 0);
        div_chipselect : in  std_logic;
        div_write      : in  std_logic;
        div_writedata  : in  std_logic_vector(W - 1 downto 0);
        div_readdata   : out std_logic_vector(W - 1 downto 0);
        -- Interfaz Interrupt Sender (div_intr)
        div_irq        : out std_logic;
        -- Interfaz Conduit (div_led)
        DIV_LED        : out std_logic_vector(7 downto 0)
    );
end entity divisor_avalon;

architecture arch of divisor_avalon is
    component divisor is
        generic (
            W    : integer := 8;
            CBIT : integer := 4
        );
        port (
            clk       : in  std_logic;
            reset     : in  std_logic;
            start     : in  std_logic;
            dvsr      : in  std_logic_vector(W - 1 downto 0);
            dvnd      : in  std_logic_vector(W - 1 downto 0);
            ready     : out std_logic;
            done_tick : out std_logic;
            quo       : out std_logic_vector(W - 1 downto 0);
            rmd       : out std_logic_vector(W - 1 downto 0)
        );
    end component;

    signal dvnd_reg      : std_logic_vector(W - 1 downto 0);
    signal dvsr_reg      : std_logic_vector(W - 1 downto 0);
    signal done_tick_reg : std_logic;

    signal div_start     : std_logic;
    signal div_ready     : std_logic;
    signal div_done_tick : std_logic;
    signal div_quo       : std_logic_vector(W - 1 downto 0);
    signal div_rmd       : std_logic_vector(W - 1 downto 0);

    signal wr_en         : std_logic;
    signal wr_dvnd       : std_logic;
    signal wr_dvsr       : std_logic;
    signal set_done_tick : std_logic;
    signal clr_done_tick : std_logic;
    signal zeros_pad     : std_logic_vector(W - 2 downto 0);
begin
    zeros_pad <= (others => '0');

    -- ========================================================================
    -- 1. Instanciación del circuito divisor
    -- ========================================================================
    div_unit : divisor
        generic map (
            W    => W,
            CBIT => CBIT
        )
        port map (
            clk       => clk,
            reset     => reset,
            start     => div_start,
            dvsr      => dvsr_reg,
            dvnd      => dvnd_reg,
            ready     => div_ready,
            done_tick => div_done_tick,
            quo       => div_quo,
            rmd       => div_rmd
        );

    -- ========================================================================
    -- 2. Registros internos (dvnd_reg, dvsr_reg, done_tick_reg)
    -- ========================================================================
    process (clk, reset)
    begin
        if reset = '1' then
            dvnd_reg      <= (others => '0');
            dvsr_reg      <= (others => '0');
            done_tick_reg <= '0';
        elsif rising_edge(clk) then
            if wr_dvnd = '1' then
                dvnd_reg <= div_writedata;
            end if;
            if wr_dvsr = '1' then
                dvsr_reg <= div_writedata;
            end if;
            if set_done_tick = '1' then
                done_tick_reg <= '1';
            elsif clr_done_tick = '1' then
                done_tick_reg <= '0';
            end if;
        end if;
    end process;

    -- ========================================================================
    -- 3. Lógica de decodificación de escritura
    -- ========================================================================
    wr_en         <= '1' when (div_write = '1' and div_chipselect = '1') else '0';
    wr_dvnd       <= '1' when (div_address = "000" and wr_en = '1') else '0';
    wr_dvsr       <= '1' when (div_address = "001" and wr_en = '1') else '0';
    div_start     <= '1' when (div_address = "010" and wr_en = '1') else '0';
    clr_done_tick <= '1' when (div_address = "110" and wr_en = '1') else '0';
    set_done_tick <= div_done_tick;

    -- ========================================================================
    -- 4. Multiplexación de lectura (combinacional -> Read wait = 0)
    -- ========================================================================
    with div_address select
        div_readdata <= div_quo                     when "011",
                        div_rmd                     when "100",
                        zeros_pad & div_ready       when "101",
                        zeros_pad & done_tick_reg   when others;

    -- ========================================================================
    -- 5. Señal Conduit para LEDs (8 LSB del residuo)
    -- ========================================================================
    DIV_LED <= div_rmd(7 downto 0);

    -- ========================================================================
    -- 6. Señal de interrupción (Interrupt Sender)
    -- ========================================================================
    div_irq <= done_tick_reg;
end architecture arch;
