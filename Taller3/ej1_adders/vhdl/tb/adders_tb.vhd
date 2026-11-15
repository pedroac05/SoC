library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================================================================
-- Testbench: adders_tb
-- Descripción: Verifica el funcionamiento del módulo adders con los genéricos
--              SMALL = 4 bits y LARGE = 6 bits, probando sumas sin acarreo,
--              casos límite y desbordamiento (cout = '1') con aserciones.
-- ============================================================================
entity adders_tb is
end entity adders_tb;

architecture Behavioral of adders_tb is
    constant C_LARGE : integer := 6;
    constant C_SMALL : integer := 4;
    constant T_STEP  : time    := 20 ns;

    component adders is
        generic (
            LARGE : integer := 16;
            SMALL : integer := 8
        );
        port (
            a      : in  std_logic_vector(SMALL-1 downto 0);
            b      : in  std_logic_vector(SMALL-1 downto 0);
            c      : in  std_logic_vector(LARGE-1 downto 0);
            d      : in  std_logic_vector(LARGE-1 downto 0);
            cout8  : out std_logic;
            sum8   : out std_logic_vector(SMALL-1 downto 0);
            cout16 : out std_logic;
            sum16  : out std_logic_vector(LARGE-1 downto 0)
        );
    end component;

    -- Señales de estímulo
    signal a_tb : std_logic_vector(C_SMALL-1 downto 0) := (others => '0');
    signal b_tb : std_logic_vector(C_SMALL-1 downto 0) := (others => '0');
    signal c_tb : std_logic_vector(C_LARGE-1 downto 0) := (others => '0');
    signal d_tb : std_logic_vector(C_LARGE-1 downto 0) := (others => '0');

    -- Señales de salida
    signal cout8_tb  : std_logic;
    signal sum8_tb   : std_logic_vector(C_SMALL-1 downto 0);
    signal cout16_tb : std_logic;
    signal sum16_tb  : std_logic_vector(C_LARGE-1 downto 0);
begin
    -- Instanciación del DUT con LARGE = 6 y SMALL = 4
    DUT: adders
        generic map (
            LARGE => C_LARGE,
            SMALL => C_SMALL
        )
        port map (
            a      => a_tb,
            b      => b_tb,
            c      => c_tb,
            d      => d_tb,
            cout8  => cout8_tb,
            sum8   => sum8_tb,
            cout16 => cout16_tb,
            sum16  => sum16_tb
        );

    -- Proceso de estímulos y autoverificación
    stim_proc: process
        type test_vec_t is record
            a_val : integer;
            b_val : integer;
            c_val : integer;
            d_val : integer;
        end record;

        type test_array_t is array (natural range <>) of test_vec_t;
        constant VECTORS : test_array_t := (
            (a_val =>  0, b_val =>  0, c_val =>  0, d_val =>  0), -- Cero + cero
            (a_val =>  3, b_val =>  5, c_val => 10, d_val => 20), -- Sumas simples sin carry
            (a_val => 15, b_val =>  0, c_val => 63, d_val =>  0), -- Límite sin overflow
            (a_val =>  9, b_val =>  6, c_val => 40, d_val => 23), -- Máximo representable (15 y 63)
            (a_val => 15, b_val =>  1, c_val => 63, d_val =>  1), -- Primer overflow (cout=1, sum=0)
            (a_val => 10, b_val => 12, c_val => 50, d_val => 30), -- Suma con carry y residuo != 0
            (a_val => 15, b_val => 15, c_val => 63, d_val => 63), -- Máximos operandos (15+15=30, 63+63=126)
            (a_val =>  7, b_val =>  8, c_val => 32, d_val => 32)  -- 7+8=15 (cout=0), 32+32=64 (cout=1)
        );

        variable exp_small : unsigned(C_SMALL downto 0);
        variable exp_large : unsigned(C_LARGE downto 0);
        variable errors    : integer := 0;
    begin
        report "================ INICIO TESTBENCH ADDERS (SMALL=4, LARGE=6) ================" severity note;

        for idx in VECTORS'range loop
            a_tb <= std_logic_vector(to_unsigned(VECTORS(idx).a_val, C_SMALL));
            b_tb <= std_logic_vector(to_unsigned(VECTORS(idx).b_val, C_SMALL));
            c_tb <= std_logic_vector(to_unsigned(VECTORS(idx).c_val, C_LARGE));
            d_tb <= std_logic_vector(to_unsigned(VECTORS(idx).d_val, C_LARGE));
            wait for T_STEP;

            exp_small := to_unsigned(VECTORS(idx).a_val + VECTORS(idx).b_val, C_SMALL + 1);
            exp_large := to_unsigned(VECTORS(idx).c_val + VECTORS(idx).d_val, C_LARGE + 1);

            if (sum8_tb /= std_logic_vector(exp_small(C_SMALL-1 downto 0))) or (cout8_tb /= exp_small(C_SMALL)) then
                report "ERROR SUMADOR SMALL (4b): a=" & integer'image(VECTORS(idx).a_val) &
                       " b=" & integer'image(VECTORS(idx).b_val) severity error;
                errors := errors + 1;
            end if;

            if (sum16_tb /= std_logic_vector(exp_large(C_LARGE-1 downto 0))) or (cout16_tb /= exp_large(C_LARGE)) then
                report "ERROR SUMADOR LARGE (6b): c=" & integer'image(VECTORS(idx).c_val) &
                       " d=" & integer'image(VECTORS(idx).d_val) severity error;
                errors := errors + 1;
            end if;
        end loop;

        if errors = 0 then
            report ">> VERIFICACION EXITOSA: Todos los vectores (SMALL=4, LARGE=6) pasaron sin errores!" severity note;
        else
            report ">> VERIFICACION CON FALLAS: Total errores = " & integer'image(errors) severity error;
        end if;

        wait;
    end process;

end architecture Behavioral;

