library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================================================================
-- Módulo: add_subs (VHDL)
-- Descripción: Sumador-Restador parametrizable asincrónico (sin reloj).
--   - add_subsn = '1' -> Suma (a + b), resultado unsigned de N+1 bits (cout & sum)
--   - add_subsn = '0' -> Resta (a - b), resultado signed en C2 de N+1 bits
-- Implementación: XOR bit a bit con selección when-else sobre operandos
-- extendidos a N+1 bits y acarreo de entrada cin = not add_subsn.
-- ============================================================================

entity add_subs is
    generic (
        EXTENDED_RANGE : integer := 4
    );
    port (
        a         : in  std_logic_vector(EXTENDED_RANGE-1 downto 0);
        b         : in  std_logic_vector(EXTENDED_RANGE-1 downto 0);
        add_subsn : in  std_logic; -- '1' = Suma, '0' = Resta
        cout      : out std_logic;
        sum       : out std_logic_vector(EXTENDED_RANGE-1 downto 0)
    );
end entity add_subs;

architecture rtl of add_subs is
    signal a_ext    : unsigned(EXTENDED_RANGE downto 0);
    signal b_ext    : unsigned(EXTENDED_RANGE downto 0);
    signal b_mask   : std_logic_vector(EXTENDED_RANGE downto 0);
    signal b_xor    : unsigned(EXTENDED_RANGE downto 0);
    signal c_in     : unsigned(0 downto 0);
    signal sum_ext  : unsigned(EXTENDED_RANGE downto 0);
begin
    -- Extensión a N+1 bits sin signo para soportar suma hasta 30 y resta hasta -15
    a_ext <= unsigned('0' & a);

    -- Máscara XOR y acarreo de entrada seleccionados mediante when-else
    b_mask <= (others => '0') when (add_subsn = '1') else (others => '1');
    c_in   <= "0"             when (add_subsn = '1') else "1";

    -- Inversión bit a bit mediante compuerta XOR para complemento a 1
    b_xor <= unsigned(('0' & b) xor b_mask);

    -- Sumador único de N+1 bits: suma A + B + 0 ó A + (~B) + 1
    sum_ext <= a_ext + b_xor + c_in;

    -- Separación de los N bits inferiores (sum) y el bit N (cout / signo)
    sum  <= std_logic_vector(sum_ext(EXTENDED_RANGE-1 downto 0));
    cout <= sum_ext(EXTENDED_RANGE);

end architecture rtl;
