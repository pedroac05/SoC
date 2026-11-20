-- ==============================================================================
-- Pontificia Universidad Javeriana - Departamento de Electronica
-- System on Chip (SoC) - Taller 4: Circuitos Secuenciales (Contadores)
-- Modulo: sevenSegmentDecoder (VHDL)
-- Descripcion: Decodificador BCD a 7 segmentos activo en bajo (DE1-SoC)
-- Formato de salida seg(6 downto 0) = g f e d c b a
-- ==============================================================================

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY sevenSegmentDecoder IS
    PORT (
        code : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        seg  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END ENTITY sevenSegmentDecoder;

ARCHITECTURE rtl OF sevenSegmentDecoder IS
BEGIN
    WITH code SELECT
        seg <= "1000000" WHEN "0000", -- 0
               "1111001" WHEN "0001", -- 1
               "0100100" WHEN "0010", -- 2
               "0110000" WHEN "0011", -- 3
               "0011001" WHEN "0100", -- 4
               "0010010" WHEN "0101", -- 5
               "0000010" WHEN "0110", -- 6
               "1111000" WHEN "0111", -- 7
               "0000000" WHEN "1000", -- 8
               "0010000" WHEN "1001", -- 9
               "0111111" WHEN "1010", -- '-'
               "1111111" WHEN OTHERS; -- Apagado
END ARCHITECTURE rtl;
