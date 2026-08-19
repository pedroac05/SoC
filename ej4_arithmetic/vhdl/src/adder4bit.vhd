library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity adder4bit is
    port (
        a    : in  std_logic_vector(3 downto 0);
        b    : in  std_logic_vector(3 downto 0);
        cin  : in  std_logic;
        s    : out std_logic_vector(3 downto 0);
        cout : out std_logic
    );
end entity adder4bit;

architecture Structural of adder4bit is
    component full_adder_mux is
        port (
            a    : in  std_logic;
            b    : in  std_logic;
            cin  : in  std_logic;
            s    : out std_logic;
            cout : out std_logic
        );
    end component;

    -- Señales internas de acarreo entre etapas (Figura 3)
    signal c : std_logic_vector(3 downto 1);
begin
    -- Etapa 0: Bit menos significativo
    FA0: full_adder_mux
        port map (
            a    => a(0),
            b    => b(0),
            cin  => cin,
            s    => s(0),
            cout => c(1)
        );

    -- Etapa 1
    FA1: full_adder_mux
        port map (
            a    => a(1),
            b    => b(1),
            cin  => c(1),
            s    => s(1),
            cout => c(2)
        );

    -- Etapa 2
    FA2: full_adder_mux
        port map (
            a    => a(2),
            b    => b(2),
            cin  => c(2),
            s    => s(2),
            cout => c(3)
        );

    -- Etapa 3: Bit más significativo
    FA3: full_adder_mux
        port map (
            a    => a(3),
            b    => b(3),
            cin  => c(3),
            s    => s(3),
            cout => cout
        );

end architecture Structural;
