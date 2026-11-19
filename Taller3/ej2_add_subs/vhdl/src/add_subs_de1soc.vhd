library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================================================================
-- Módulo Top-Level DE1-SoC: add_subs_de1soc (VHDL)
-- Integra add_subs + conversor signo/magnitud BCD + sevenSegmentDecoder
--   - SW(7 downto 4) : Operando A (4 bits unsigned, 0..15)
--   - SW(3 downto 0) : Operando B (4 bits unsigned, 0..15)
--   - SW(9)          : add_subsn ('1' = Suma, '0' = Resta)
--   - LEDR           : Refleja el estado de SW(9 downto 0)
--   - HEX2           : Signo '-' si el resultado es negativo
--   - HEX1           : Decenas (apagado si es 0)
--   - HEX0           : Unidades (0..9)
--   - HEX5..HEX3     : Apagados
-- ============================================================================

entity add_subs_de1soc is
    port (
        SW   : in  std_logic_vector(9 downto 0);
        LEDR : out std_logic_vector(9 downto 0);
        HEX0 : out std_logic_vector(6 downto 0);
        HEX1 : out std_logic_vector(6 downto 0);
        HEX2 : out std_logic_vector(6 downto 0);
        HEX3 : out std_logic_vector(6 downto 0);
        HEX4 : out std_logic_vector(6 downto 0);
        HEX5 : out std_logic_vector(6 downto 0)
    );
end entity add_subs_de1soc;

architecture rtl of add_subs_de1soc is
    signal a_in      : std_logic_vector(3 downto 0);
    signal b_in      : std_logic_vector(3 downto 0);
    signal add_subsn : std_logic;
    signal cout_s    : std_logic;
    signal sum_s     : std_logic_vector(3 downto 0);
    signal res5      : std_logic_vector(4 downto 0);

    signal is_neg    : std_logic;
    signal mag       : unsigned(4 downto 0);
    signal tens_u    : unsigned(3 downto 0);
    signal units_u   : unsigned(3 downto 0);

    signal code_hex0 : std_logic_vector(3 downto 0);
    signal code_hex1 : std_logic_vector(3 downto 0);
    signal code_hex2 : std_logic_vector(3 downto 0);
begin
    -- Asignación de entradas físicas
    a_in      <= SW(7 downto 4);
    b_in      <= SW(3 downto 0);
    add_subsn <= SW(9);
    LEDR      <= SW;

    -- 1. Instanciación del sumador-restador parametrizable (N=4)
    U_ADD_SUBS: entity work.add_subs
        generic map (
            EXTENDED_RANGE => 4
        )
        port map (
            a         => a_in,
            b         => b_in,
            add_subsn => add_subsn,
            cout      => cout_s,
            sum       => sum_s
        );

    res5 <= cout_s & sum_s;

    -- 2. Detección de signo negativo (solo en resta cuando cout = '1')
    is_neg <= (not add_subsn) and cout_s;

    -- 3. Cálculo de magnitud absoluta (0..30)
    mag <= (unsigned(not res5) + 1) when (is_neg = '1') else unsigned(res5);

    -- 4. Conversión combinacional a BCD (Decenas y Unidades para rango 0..30)
    tens_u <= to_unsigned(3, 4) when (mag >= 30) else
              to_unsigned(2, 4) when (mag >= 20) else
              to_unsigned(1, 4) when (mag >= 10) else
              to_unsigned(0, 4);

    units_u <= resize(mag - 30, 4) when (mag >= 30) else
               resize(mag - 20, 4) when (mag >= 20) else
               resize(mag - 10, 4) when (mag >= 10) else
               resize(mag, 4);

    -- 5. Códigos para cada display (con supresión de cero a la izquierda)
    code_hex0 <= std_logic_vector(units_u);
    code_hex1 <= "1111" when (tens_u = 0) else std_logic_vector(tens_u);
    code_hex2 <= "1010" when (is_neg = '1') else "1111"; -- "1010" = '-'

    -- 6. Decodificadores de 7 segmentos
    U_HEX0: entity work.sevenSegmentDecoder port map (code => code_hex0, seg => HEX0);
    U_HEX1: entity work.sevenSegmentDecoder port map (code => code_hex1, seg => HEX1);
    U_HEX2: entity work.sevenSegmentDecoder port map (code => code_hex2, seg => HEX2);

    -- Displays no utilizados apagados (activo en bajo -> '1')
    HEX3 <= (others => '1');
    HEX4 <= (others => '1');
    HEX5 <= (others => '1');

end architecture rtl;
