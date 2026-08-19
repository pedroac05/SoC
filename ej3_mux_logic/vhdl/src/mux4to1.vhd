library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux4to1 is
    port (
        d   : in  std_logic_vector(3 downto 0);
        sel : in  std_logic_vector(1 downto 0);
        y   : out std_logic
    );
end entity mux4to1;

architecture Behavioral of mux4to1 is
begin
    with sel select
        y <= d(0) when "00",
             d(1) when "01",
             d(2) when "10",
             d(3) when "11",
             '0'  when others;
end architecture Behavioral;
