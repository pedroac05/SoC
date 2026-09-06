library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_logic_mux is
    port (
        x1 : in  std_logic;
        x2 : in  std_logic;
        x3 : in  std_logic;
        x4 : in  std_logic;
        f  : out std_logic
    );
end entity mux_logic_mux;

architecture Structural of mux_logic_mux is
    component mux4to1 is
        port (
            d   : in  std_logic_vector(3 downto 0);
            sel : in  std_logic_vector(1 downto 0);
            y   : out std_logic
        );
    end component;

    signal d_bus   : std_logic_vector(3 downto 0);
    signal sel_bus : std_logic_vector(1 downto 0);
begin
    -- Selectores: x1 como MSB (sel1) y x2 como LSB (sel0)
    sel_bus <= x1 & x2;

    -- Entradas de datos derivadas por partición de Shannon:
    -- d(0) [00] = x3 XNOR x4
    -- d(1) [01] = x3 XOR x4
    -- d(2) [10] = x3 XOR x4
    -- d(3) [11] = x3 XNOR x4
    d_bus(0) <= x3 xnor x4;
    d_bus(1) <= x3 xor x4;
    d_bus(2) <= x3 xor x4;
    d_bus(3) <= x3 xnor x4;

    U_MUX: mux4to1
        port map (
            d   => d_bus,
            sel => sel_bus,
            y   => f
        );

end architecture Structural;
