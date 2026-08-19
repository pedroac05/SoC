library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_logic_gate is
    port (
        x1 : in  std_logic;
        x2 : in  std_logic;
        x3 : in  std_logic;
        x4 : in  std_logic;
        f  : out std_logic
    );
end entity mux_logic_gate;

architecture GateLevel of mux_logic_gate is
    signal g1 : std_logic;
    signal g2 : std_logic;
begin
    -- Implementación directa a nivel compuertas (Figura 1: 3 compuertas XNOR)
    g1 <= x1 xnor x2;
    g2 <= x3 xnor x4;
    f  <= g1 xnor g2;
end architecture GateLevel;
