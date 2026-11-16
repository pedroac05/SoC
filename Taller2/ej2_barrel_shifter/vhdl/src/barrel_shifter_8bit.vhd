library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ============================================================================
-- Ejercicio 2.2: Barrel Shifter Multietapa de 0 a 7 bits (8 bits de datos)
-- Implementado mediante 3 etapas concurrentes en cascada:
--   - Etapa 0 (shift(0)): desplaza 0 o 1 bit  a la izquierda
--   - Etapa 1 (shift(1)): desplaza 0 o 2 bits a la izquierda
--   - Etapa 2 (shift(2)): desplaza 0 o 4 bits a la izquierda
-- ============================================================================

entity barrel_shifter_8bit is
    port (
        inp   : in  std_logic_vector(7 downto 0); -- Vector de entrada (8 bits)
        shift : in  std_logic_vector(2 downto 0); -- Cantidad de desplazamiento (0 a 7)
        outp  : out std_logic_vector(7 downto 0)  -- Vector de salida desplazado
    );
end entity barrel_shifter_8bit;

architecture Cascaded_RTL of barrel_shifter_8bit is
    -- Señales intermedias entre etapas del Barrel Shifter
    signal s0 : std_logic_vector(7 downto 0); -- Salida de Etapa 0 (+1 bit)
    signal s1 : std_logic_vector(7 downto 0); -- Salida de Etapa 1 (+2 bits)
begin
    -- Etapa 0: Desplazamiento de 1 posición controlado por shift(0)
    s0 <= (inp(6 downto 0) & '0') when (shift(0) = '1') else inp;

    -- Etapa 1: Desplazamiento de 2 posiciones controlado por shift(1)
    s1 <= (s0(5 downto 0) & "00") when (shift(1) = '1') else s0;

    -- Etapa 2: Desplazamiento de 4 posiciones controlado por shift(2)
    outp <= (s1(3 downto 0) & "0000") when (shift(2) = '1') else s1;

end architecture Cascaded_RTL;

