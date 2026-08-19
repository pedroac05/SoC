library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_logic_top is
    port (
        x1        : in  std_logic;
        x2        : in  std_logic;
        x3        : in  std_logic;
        x4        : in  std_logic;
        f_gate    : out std_logic;
        f_mux     : out std_logic;
        match_out : out std_logic
    );
end entity mux_logic_top;

architecture Structural of mux_logic_top is
    component mux_logic_gate is
        port (
            x1 : in  std_logic;
            x2 : in  std_logic;
            x3 : in  std_logic;
            x4 : in  std_logic;
            f  : out std_logic
        );
    end component;

    component mux_logic_mux is
        port (
            x1 : in  std_logic;
            x2 : in  std_logic;
            x3 : in  std_logic;
            x4 : in  std_logic;
            f  : out std_logic
        );
    end component;

    signal sig_f_gate : std_logic;
    signal sig_f_mux  : std_logic;
begin
    -- Instancia del módulo a nivel compuertas
    U_GATE: mux_logic_gate
        port map (
            x1 => x1,
            x2 => x2,
            x3 => x3,
            x4 => x4,
            f  => sig_f_gate
        );

    -- Instancia del módulo basado en Multiplexor
    U_MUX_IMPL: mux_logic_mux
        port map (
            x1 => x1,
            x2 => x2,
            x3 => x3,
            x4 => x4,
            f  => sig_f_mux
        );

    -- Asignación de salidas y verificación de coincidencia
    f_gate    <= sig_f_gate;
    f_mux     <= sig_f_mux;
    match_out <= sig_f_gate xnor sig_f_mux; -- '1' cuando f_gate = f_mux

end architecture Structural;
