library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dec4to16 is
    port (
        en    : in  std_logic;
        in_v  : in  std_logic_vector(3 downto 0);
        bcode : out std_logic_vector(15 downto 0)
    );
end entity dec4to16;

architecture Structural of dec4to16 is
    -- Componente base decodificador 2-to-4
    component dec2to4 is
        port (
            en    : in  std_logic;
            in_v  : in  std_logic_vector(1 downto 0);
            bcode : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Bus interno de 4 señales de habilitación generado por el decodificador de control
    signal en_bus : std_logic_vector(3 downto 0);
begin
    -- 1. Decodificador de control (Nivel 1):
    -- Decodifica los 2 bits más significativos (MSBs: in_v(3 downto 2))
    -- y activa exactamente 1 de las 4 líneas de enable internas.
    U_DEC_CTRL: dec2to4
        port map (
            en    => en,
            in_v  => in_v(3 downto 2),
            bcode => en_bus
        );

    -- 2. Decodificadores de datos (Nivel 2):
    -- Los 4 bloques reciben los mismos 2 bits menos significativos (LSBs: in_v(1 downto 0))
    -- pero solo uno es activado a la vez por en_bus.

    -- Bloque 0: Salidas bcode(3 downto 0) para in_v(3 downto 2) = "00"
    U_DEC0: dec2to4
        port map (
            en    => en_bus(0),
            in_v  => in_v(1 downto 0),
            bcode => bcode(3 downto 0)
        );

    -- Bloque 1: Salidas bcode(7 downto 4) para in_v(3 downto 2) = "01"
    U_DEC1: dec2to4
        port map (
            en    => en_bus(1),
            in_v  => in_v(1 downto 0),
            bcode => bcode(7 downto 4)
        );

    -- Bloque 2: Salidas bcode(11 downto 8) para in_v(3 downto 2) = "10"
    U_DEC2: dec2to4
        port map (
            en    => en_bus(2),
            in_v  => in_v(1 downto 0),
            bcode => bcode(11 downto 8)
        );

    -- Bloque 3: Salidas bcode(15 downto 12) para in_v(3 downto 2) = "11"
    U_DEC3: dec2to4
        port map (
            en    => en_bus(3),
            in_v  => in_v(1 downto 0),
            bcode => bcode(15 downto 12)
        );

end architecture Structural;
