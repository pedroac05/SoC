library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dec3to8 is
    port (
        en    : in  std_logic;
        in_v  : in  std_logic_vector(2 downto 0);
        bcode : out std_logic_vector(7 downto 0)
    );
end entity dec3to8;

architecture Structural of dec3to8 is
    -- Componente base decodificador 2-to-4
    component dec2to4 is
        port (
            en    : in  std_logic;
            in_v  : in  std_logic_vector(1 downto 0);
            bcode : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Señales de habilitación para cada bloque 2-to-4
    signal en_low  : std_logic;
    signal en_high : std_logic;
begin
    -- Decodificación del MSB (in_v(2)) para habilitar el bloque inferior o superior
    en_low  <= en and (not in_v(2));
    en_high <= en and in_v(2);

    -- Instancia bloque inferior: maneja salidas bcode(3 downto 0) cuando in_v(2) = '0'
    U_DEC_LOW: dec2to4
        port map (
            en    => en_low,
            in_v  => in_v(1 downto 0),
            bcode => bcode(3 downto 0)
        );

    -- Instancia bloque superior: maneja salidas bcode(7 downto 4) cuando in_v(2) = '1'
    U_DEC_HIGH: dec2to4
        port map (
            en    => en_high,
            in_v  => in_v(1 downto 0),
            bcode => bcode(7 downto 4)
        );

end architecture Structural;
