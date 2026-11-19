library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ============================================================================
-- Testbench: fpu_top_tb (VHDL)
-- Reloj de 50 MHz (T_clk = 20 ns)
-- Verifica las 4 operaciones FP32 (Suma, Resta, Multiplicación, División)
-- y permite medir exactamente las latencias en ciclos y nanosegundos.
-- ============================================================================

entity fpu_top_tb is
end entity fpu_top_tb;

architecture Behavioral of fpu_top_tb is
    component fpu_top is
        port (
            clk    : in  std_logic;
            areset : in  std_logic;
            A      : in  std_logic_vector(31 downto 0);
            B      : in  std_logic_vector(31 downto 0);
            selop  : in  std_logic_vector(1 downto 0);
            result : out std_logic_vector(31 downto 0)
        );
    end component;

    constant CLK_PERIOD : time := 20 ns; -- 50 MHz

    signal clk_tb    : std_logic := '0';
    signal areset_tb : std_logic := '1';
    signal A_tb      : std_logic_vector(31 downto 0) := (others => '0');
    signal B_tb      : std_logic_vector(31 downto 0) := (others => '0');
    signal selop_tb  : std_logic_vector(1 downto 0)  := "00";
    signal result_tb : std_logic_vector(31 downto 0);
begin
    -- Generador de reloj 50 MHz (T = 20 ns)
    clk_tb <= not clk_tb after CLK_PERIOD / 2;

    DUT: fpu_top
        port map (
            clk    => clk_tb,
            areset => areset_tb,
            A      => A_tb,
            B      => B_tb,
            selop  => selop_tb,
            result => result_tb
        );

    stim_proc: process
        variable errors : integer := 0;
    begin
        -- Reset inicial durante 2 ciclos
        areset_tb <= '1';
        wait for 2 * CLK_PERIOD;
        areset_tb <= '0';
        wait until rising_edge(clk_tb);

        -- ====================================================================
        -- PRUEBA 1: A = 6.5 (0x40D00000), B = 2.0 (0x40000000)
        -- ====================================================================
        A_tb <= x"40D00000"; -- 6.5
        B_tb <= x"40000000"; -- 2.0

        -- 1a. Suma (selop = "00") -> Latencia esperada: 2 ciclos (40 ns) -> 8.5 (0x41080000)
        selop_tb <= "00";
        wait for 3 * CLK_PERIOD;
        if result_tb /= x"41080000" then
            report "ERROR ADD1" severity error; errors := errors + 1;
        end if;

        -- 1b. Resta (selop = "01") -> Latencia: 2 ciclos (40 ns) -> 4.5 (0x40900000)
        selop_tb <= "01";
        wait for 2 * CLK_PERIOD;
        if result_tb /= x"40900000" then
            report "ERROR SUB1" severity error; errors := errors + 1;
        end if;

        -- 1c. Multiplicación (selop = "10") -> Latencia: 2 ciclos (40 ns) -> 13.0 (0x41500000)
        selop_tb <= "10";
        wait for 2 * CLK_PERIOD;
        if result_tb /= x"41500000" then
            report "ERROR MUL1" severity error; errors := errors + 1;
        end if;

        -- 1d. División (selop = "11") -> Latencia: 11 ciclos (220 ns) -> 3.25 (0x40500000)
        selop_tb <= "11";
        wait for 7 * CLK_PERIOD; -- Ya llevaba 7 ciclos desde que cambió A_tb/B_tb; completamos >11
        if result_tb /= x"40500000" then
            report "ERROR DIV1" severity error; errors := errors + 1;
        end if;

        -- ====================================================================
        -- PRUEBA 2: A = 10.5 (0x41280000), B = -3.0 (0xC0400000)
        -- ====================================================================
        A_tb <= x"41280000"; --  10.5
        B_tb <= x"C0400000"; --  -3.0

        -- 2a. Suma -> 7.5 (0x40F00000)
        selop_tb <= "00";
        wait for 3 * CLK_PERIOD;
        if result_tb /= x"40F00000" then
            report "ERROR ADD2" severity error; errors := errors + 1;
        end if;

        -- 2b. Resta -> 13.5 (0x41580000)
        selop_tb <= "01";
        wait for 2 * CLK_PERIOD;
        if result_tb /= x"41580000" then
            report "ERROR SUB2" severity error; errors := errors + 1;
        end if;

        -- 2c. Multiplicación -> -31.5 (0xC1FC0000)
        selop_tb <= "10";
        wait for 2 * CLK_PERIOD;
        if result_tb /= x"C1FC0000" then
            report "ERROR MUL2" severity error; errors := errors + 1;
        end if;

        -- 2d. División -> -3.5 (0xC0600000)
        selop_tb <= "11";
        wait for 7 * CLK_PERIOD;
        if result_tb /= x"C0600000" then
            report "ERROR DIV2" severity error; errors := errors + 1;
        end if;

        if errors = 0 then
            report ">> VERIFICACION FPU EXITOSA: Todas las operaciones FP32 pasaron sin errores!" severity note;
        else
            report ">> VERIFICACION CON FALLAS: Total errores = " & integer'image(errors) severity error;
        end if;

        wait;
    end process;

end architecture Behavioral;
