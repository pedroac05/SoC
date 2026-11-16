library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ============================================================================
-- Codificador Binario a Código Gray de 4 bits
-- Implementado a nivel RTL utilizando asignación seleccionada (with/select/when)
-- según las especificaciones del Taller 2 (literal c).
-- ============================================================================

entity gray_encoder is
    port (
        b : in  std_logic_vector(3 downto 0); -- Código binario de entrada
        g : out std_logic_vector(3 downto 0)  -- Código Gray de salida
    );
end entity gray_encoder;

architecture RTL of gray_encoder is
begin
    -- Sentencia concurrente seleccionada (with / select / when)
    with b select
        g <= "0000" when "0000",
             "0001" when "0001",
             "0011" when "0010",
             "0010" when "0011",
             "0110" when "0100",
             "0111" when "0101",
             "0101" when "0110",
             "0100" when "0111",
             "1100" when "1000",
             "1101" when "1001",
             "1111" when "1010",
             "1110" when "1011",
             "1010" when "1100",
             "1011" when "1101",
             "1001" when "1110",
             "1000" when "1111",
             "0000" when others;
end architecture RTL;

