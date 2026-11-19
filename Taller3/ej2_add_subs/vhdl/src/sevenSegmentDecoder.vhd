library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ============================================================================
-- Módulo: sevenSegmentDecoder (VHDL)
-- Descripción: Decodificador para display de 7 segmentos activo en bajo (DE1-SoC)
--   - "0000" a "1001" (0..9) : Dígitos decimales 0..9
--   - "1010" (10)            : Signo negativo '-' (solo segmento g encendido)
--   - Otros                  : Display apagado ("1111111")
-- Formato de salida seg(6 downto 0) = g f e d c b a
-- ============================================================================

entity sevenSegmentDecoder is
    port (
        code : in  std_logic_vector(3 downto 0);
        seg  : out std_logic_vector(6 downto 0)
    );
end entity sevenSegmentDecoder;

architecture rtl of sevenSegmentDecoder is
begin
    with code select
        seg <= "1000000" when "0000", -- 0
               "1111001" when "0001", -- 1
               "0100100" when "0010", -- 2
               "0110000" when "0011", -- 3
               "0011001" when "0100", -- 4
               "0010010" when "0101", -- 5
               "0000010" when "0110", -- 6
               "1111000" when "0111", -- 7
               "0000000" when "1000", -- 8
               "0010000" when "1001", -- 9
               "0111111" when "1010", -- '-' (signo negativo)
               "1111111" when others; -- Apagado
end architecture rtl;
