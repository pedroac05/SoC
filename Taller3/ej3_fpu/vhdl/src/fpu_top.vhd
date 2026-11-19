library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ============================================================================
-- Módulo Top-Level: fpu_top (VHDL)
-- Unidad Aritmética de Punto Flotante FP32 (IEEE 754)
-- Integra 4 bloques IP paralelos (fp_add, fp_sub, fp_mul, fp_div) generados
-- para Cyclone V a 50 MHz con menor latencia posible + MUX 4:1 de 32 bits.
--   - selop = "00" -> Suma (A + B)         [Latencia: 2 ciclos = 40 ns]
--   - selop = "01" -> Resta (A - B)        [Latencia: 2 ciclos = 40 ns]
--   - selop = "10" -> Multiplicación (A*B) [Latencia: 2 ciclos = 40 ns]
--   - selop = "11" -> División (A / B)     [Latencia: 11 ciclos = 220 ns]
-- ============================================================================

entity fpu_top is
    port (
        clk    : in  std_logic;
        areset : in  std_logic := '0';
        A      : in  std_logic_vector(31 downto 0);
        B      : in  std_logic_vector(31 downto 0);
        selop  : in  std_logic_vector(1 downto 0);
        result : out std_logic_vector(31 downto 0)
    );
end entity fpu_top;

architecture rtl of fpu_top is
    component fp_add is
        port (
            a      : in  std_logic_vector(31 downto 0);
            b      : in  std_logic_vector(31 downto 0);
            q      : out std_logic_vector(31 downto 0);
            clk    : in  std_logic;
            areset : in  std_logic
        );
    end component;

    component fp_sub is
        port (
            a      : in  std_logic_vector(31 downto 0);
            b      : in  std_logic_vector(31 downto 0);
            q      : out std_logic_vector(31 downto 0);
            clk    : in  std_logic;
            areset : in  std_logic
        );
    end component;

    component fp_mul is
        port (
            a      : in  std_logic_vector(31 downto 0);
            b      : in  std_logic_vector(31 downto 0);
            q      : out std_logic_vector(31 downto 0);
            clk    : in  std_logic;
            areset : in  std_logic
        );
    end component;

    component fp_div is
        port (
            a      : in  std_logic_vector(31 downto 0);
            b      : in  std_logic_vector(31 downto 0);
            q      : out std_logic_vector(31 downto 0);
            clk    : in  std_logic;
            areset : in  std_logic
        );
    end component;

    signal result_add : std_logic_vector(31 downto 0);
    signal result_sub : std_logic_vector(31 downto 0);
    signal result_mul : std_logic_vector(31 downto 0);
    signal result_div : std_logic_vector(31 downto 0);
begin
    U_FP_ADD: fp_add port map (clk => clk, areset => areset, a => A, b => B, q => result_add);
    U_FP_SUB: fp_sub port map (clk => clk, areset => areset, a => A, b => B, q => result_sub);
    U_FP_MUL: fp_mul port map (clk => clk, areset => areset, a => A, b => B, q => result_mul);
    U_FP_DIV: fp_div port map (clk => clk, areset => areset, a => A, b => B, q => result_div);

    -- MUX 4:1 de 32 bits controlado por selop
    with selop select
        result <= result_add when "00",
                  result_sub when "01",
                  result_mul when "10",
                  result_div when others;

end architecture rtl;
