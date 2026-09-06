library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity full_adder_mux is
    port (
        a    : in  std_logic;
        b    : in  std_logic;
        cin  : in  std_logic;
        s    : out std_logic;
        cout : out std_logic
    );
end entity full_adder_mux;

architecture Structural of full_adder_mux is
    component mux4to1 is
        port (
            d   : in  std_logic_vector(3 downto 0);
            sel : in  std_logic_vector(1 downto 0);
            y   : out std_logic
        );
    end component;

    signal sel_ab     : std_logic_vector(1 downto 0);
    signal d_sum      : std_logic_vector(3 downto 0);
    signal d_cout     : std_logic_vector(3 downto 0);
    signal not_cin    : std_logic;
begin
    -- Señal de selección: a (MSB), b (LSB)
    sel_ab <= a & b;
    not_cin <= not cin;

    -- Entradas de datos para la SUMA (S):
    -- AB = 00 -> S = cin
    -- AB = 01 -> S = not cin
    -- AB = 10 -> S = not cin
    -- AB = 11 -> S = cin
    d_sum(0) <= cin;
    d_sum(1) <= not_cin;
    d_sum(2) <= not_cin;
    d_sum(3) <= cin;

    -- Entradas de datos para el ACARREO (Cout):
    -- AB = 00 -> Cout = '0'
    -- AB = 01 -> Cout = cin
    -- AB = 10 -> Cout = cin
    -- AB = 11 -> Cout = '1'
    d_cout(0) <= '0';
    d_cout(1) <= cin;
    d_cout(2) <= cin;
    d_cout(3) <= '1';

    -- Instancia MUX para Suma (S)
    U_MUX_SUM: mux4to1
        port map (
            d   => d_sum,
            sel => sel_ab,
            y   => s
        );

    -- Instancia MUX para Acarreo de Salida (Cout)
    U_MUX_COUT: mux4to1
        port map (
            d   => d_cout,
            sel => sel_ab,
            y   => cout
        );

end architecture Structural;
