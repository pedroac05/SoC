library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gt2 is
    port (
        a : in  std_logic_vector(1 downto 0);
        b : in  std_logic_vector(1 downto 0);
        gt : out std_logic
    );
end entity gt2;

architecture Behavioral of gt2 is
begin
    -- Función SOP obtenida para 2 bits: gt = (a(1) and not b(1)) or (a(1) and a(0) and not b(0)) or (a(0) and not b(1) and not b(0))
    gt <= (a(1) and not b(1)) or
          (a(1) and a(0) and not b(0)) or
          (a(0) and not b(1) and not b(0));
end architecture Behavioral;