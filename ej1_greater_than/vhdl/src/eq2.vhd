library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity eq2 is
    port (
        a  : in  std_logic_vector(1 downto 0);
        b  : in  std_logic_vector(1 downto 0);
        eq : out std_logic
    );
end entity eq2;

architecture Behavioral of eq2 is
begin
    -- Igualdad a nivel compuerta: (a1 XNOR b1) AND (a0 XNOR b0)
    eq <= (a(1) xnor b(1)) and (a(0) xnor b(0));
end architecture Behavioral;
