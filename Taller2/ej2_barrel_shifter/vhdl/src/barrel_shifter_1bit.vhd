library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ============================================================================
-- Ejercicio 2.1: Barrel Shifter de 1 bit de desplazamiento (8 bits de datos)
-- Desplaza el vector de entrada 0 o 1 posición a la izquierda de forma
-- puramente combinacional mediante asignación condicional concurrente.
-- ============================================================================

entity barrel_shifter_1bit is
    port (
        inp   : in  std_logic_vector(7 downto 0); -- Vector de entrada (8 bits)
        shift : in  std_logic;                    -- Control: '0' = sin cambio, '1' = << 1
        outp  : out std_logic_vector(7 downto 0)  -- Vector de salida desplazado
    );
end entity barrel_shifter_1bit;

architecture Concurrent_RTL of barrel_shifter_1bit is
begin
    -- Si shift = '1', desplaza 1 bit a la izquierda concatenando '0' en el LSB
    -- Si shift = '0', mantiene el vector inp intacto
    outp <= (inp(6 downto 0) & '0') when (shift = '1') else inp;
end architecture Concurrent_RTL;

