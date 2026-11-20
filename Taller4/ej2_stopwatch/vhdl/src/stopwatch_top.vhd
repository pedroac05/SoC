-- ==============================================================================
-- Pontificia Universidad Javeriana - Departamento de Electronica
-- System on Chip (SoC) - Taller 4: Circuitos Secuenciales (Contadores)
-- Modulo: stopwatch_top (Cronometro Digital 00.0 a 99.9 s para DE1-SoC)
-- ==============================================================================
-- Controles en tarjeta DE1-SoC:
--   * CLOCK_50 : Reloj base de 50 MHz (T = 20 ns)
--   * SW(0)    : enable general (1 = circuito activo, 0 = reset asincrono)
--   * SW(1)    : go (1 = contar, 0 = pausar)
--   * KEY(0)   : syn_clr (pulsador activo en bajo -> reinicio sincrono a 00.0)
--   * HEX0     : Decimas de segundo (0..9)
--   * HEX1     : Unidades de segundo (0..9)
--   * HEX2     : Decenas de segundo (0..9)
-- ==============================================================================

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY stopwatch_top IS
    GENERIC (
        -- 50 MHz * 0.1 s = 5,000,000 ciclos -> cuenta de 0 a 4,999,999
        DIV_MAX : INTEGER := 4999999
    );
    PORT (
        CLOCK_50 : IN  STD_LOGIC;
        SW       : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        KEY      : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
        HEX0     : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        HEX1     : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        HEX2     : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END ENTITY stopwatch_top;

ARCHITECTURE rtl OF stopwatch_top IS

    -- Senales de control internas
    SIGNAL rst_s     : STD_LOGIC;
    SIGNAL go_s      : STD_LOGIC;
    SIGNAL syn_clr_s : STD_LOGIC;

    -- Pulsos de habilitacion en cascada
    SIGNAL tick_01s  : STD_LOGIC;
    SIGNAL tick_dec  : STD_LOGIC;
    SIGNAL tick_uni  : STD_LOGIC;

    SIGNAL ena_dec   : STD_LOGIC;
    SIGNAL ena_uni   : STD_LOGIC;
    SIGNAL ena_ten   : STD_LOGIC;

    -- Conteos BCD de cada digito
    SIGNAL dec_s     : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL uni_s     : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL ten_s     : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

    -- Mapeo de controles fisicos de la DE1-SoC
    rst_s     <= NOT SW(0);   -- SW(0) = '1' habilita el sistema; '0' lo resetea
    go_s      <= SW(1);       -- SW(1) = '1' inicia/reanuda; '0' pausa
    syn_clr_s <= NOT KEY(0);  -- KEY(0) es activo en bajo en la DE1-SoC

    -- --------------------------------------------------------------------------
    -- 1. Divisor de frecuencia (Mod-5,000,000 para 0.1 s @ 50 MHz)
    -- --------------------------------------------------------------------------
    u_div_01s : ENTITY work.univ_bin_counter
        GENERIC MAP (
            N         => 23,
            MAX_COUNT => STD_LOGIC_VECTOR(TO_UNSIGNED(DIV_MAX, 23))
        )
        PORT MAP (
            clk      => CLOCK_50,
            rst      => rst_s,
            ena      => go_s,
            syn_clr  => syn_clr_s,
            load     => '0',
            up       => '1',
            d        => (OTHERS => '0'),
            max_tick => tick_01s,
            min_tick => OPEN,
            counter  => OPEN
        );

    -- Habilitacion en cascada sincrona
    ena_dec <= go_s AND tick_01s;
    ena_uni <= ena_dec AND tick_dec;
    ena_ten <= ena_uni AND tick_uni;

    -- --------------------------------------------------------------------------
    -- 2. Contador BCD de Decimas de segundo (0..9) -> HEX0
    -- --------------------------------------------------------------------------
    u_cnt_dec : ENTITY work.univ_bin_counter
        GENERIC MAP (
            N         => 4,
            MAX_COUNT => "1001"
        )
        PORT MAP (
            clk      => CLOCK_50,
            rst      => rst_s,
            ena      => ena_dec,
            syn_clr  => syn_clr_s,
            load     => '0',
            up       => '1',
            d        => "0000",
            max_tick => tick_dec,
            min_tick => OPEN,
            counter  => dec_s
        );

    -- --------------------------------------------------------------------------
    -- 3. Contador BCD de Unidades de segundo (0..9) -> HEX1
    -- --------------------------------------------------------------------------
    u_cnt_uni : ENTITY work.univ_bin_counter
        GENERIC MAP (
            N         => 4,
            MAX_COUNT => "1001"
        )
        PORT MAP (
            clk      => CLOCK_50,
            rst      => rst_s,
            ena      => ena_uni,
            syn_clr  => syn_clr_s,
            load     => '0',
            up       => '1',
            d        => "0000",
            max_tick => tick_uni,
            min_tick => OPEN,
            counter  => uni_s
        );

    -- --------------------------------------------------------------------------
    -- 4. Contador BCD de Decenas de segundo (0..9) -> HEX2
    -- --------------------------------------------------------------------------
    u_cnt_ten : ENTITY work.univ_bin_counter
        GENERIC MAP (
            N         => 4,
            MAX_COUNT => "1001"
        )
        PORT MAP (
            clk      => CLOCK_50,
            rst      => rst_s,
            ena      => ena_ten,
            syn_clr  => syn_clr_s,
            load     => '0',
            up       => '1',
            d        => "0000",
            max_tick => OPEN,
            min_tick => OPEN,
            counter  => ten_s
        );

    -- --------------------------------------------------------------------------
    -- 5. Decodificadores BCD a 7 segmentos (activos en bajo)
    -- --------------------------------------------------------------------------
    u_hex0 : ENTITY work.sevenSegmentDecoder PORT MAP (code => dec_s, seg => HEX0);
    u_hex1 : ENTITY work.sevenSegmentDecoder PORT MAP (code => uni_s, seg => HEX1);
    u_hex2 : ENTITY work.sevenSegmentDecoder PORT MAP (code => ten_s, seg => HEX2);

END ARCHITECTURE rtl;
