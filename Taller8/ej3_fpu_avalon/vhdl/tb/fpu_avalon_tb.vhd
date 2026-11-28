library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ============================================================================
-- Testbench para fpu_avalon (ALU FP32 IEEE 754 en bus Avalon MM-Slave)
-- Prueba las 4 operaciones (+, -, *, /) con operandos conocidos en IEEE 754:
--   A = 12.5  (0x41480000)
--   B =  2.5  (0x40200000)
--   A + B = 15.0  (0x41700000)
--   A - B = 10.0  (0x41200000)
--   A * B = 31.25 (0x41FA0000)
--   A / B =  5.0  (0x40A00000)
-- ============================================================================
entity fpu_avalon_tb is
end entity fpu_avalon_tb;

architecture sim of fpu_avalon_tb is
    constant CLK_PER : time := 20 ns; -- 50 MHz

    constant ADDR_OP_A  : std_logic_vector(2 downto 0) := "000"; -- 0
    constant ADDR_OP_B  : std_logic_vector(2 downto 0) := "001"; -- 1
    constant ADDR_SELOP : std_logic_vector(2 downto 0) := "010"; -- 2
    constant ADDR_START : std_logic_vector(2 downto 0) := "011"; -- 3
    constant ADDR_RES   : std_logic_vector(2 downto 0) := "100"; -- 4
    constant ADDR_READY : std_logic_vector(2 downto 0) := "101"; -- 5
    constant ADDR_DONE  : std_logic_vector(2 downto 0) := "110"; -- 6

    signal clk_tb            : std_logic := '0';
    signal reset_tb          : std_logic := '0';
    signal fpu_address_tb    : std_logic_vector(2 downto 0) := (others => '0');
    signal fpu_chipselect_tb : std_logic := '0';
    signal fpu_write_tb      : std_logic := '0';
    signal fpu_writedata_tb  : std_logic_vector(31 downto 0) := (others => '0');
    signal fpu_readdata_tb   : std_logic_vector(31 downto 0);
    signal fpu_irq_tb        : std_logic;
    signal sim_done          : boolean := false;
begin
    dut : entity work.fpu_avalon
        port map (
            clk            => clk_tb,
            reset          => reset_tb,
            fpu_address    => fpu_address_tb,
            fpu_chipselect => fpu_chipselect_tb,
            fpu_write      => fpu_write_tb,
            fpu_writedata  => fpu_writedata_tb,
            fpu_readdata   => fpu_readdata_tb,
            fpu_irq        => fpu_irq_tb
        );

    clk_proc : process
    begin
        while not sim_done loop
            clk_tb <= '0';
            wait for CLK_PER / 2;
            clk_tb <= '1';
            wait for CLK_PER / 2;
        end loop;
        wait;
    end process;

    stim_proc : process
        procedure avalon_write(
            constant addr : in std_logic_vector(2 downto 0);
            constant data : in std_logic_vector(31 downto 0)
        ) is
        begin
            wait until falling_edge(clk_tb);
            fpu_address_tb    <= addr;
            fpu_chipselect_tb <= '1';
            fpu_write_tb      <= '1';
            fpu_writedata_tb  <= data;
            wait until rising_edge(clk_tb);
            wait for 1 ns;
            fpu_chipselect_tb <= '0';
            fpu_write_tb      <= '0';
        end procedure;

        procedure avalon_read(
            constant addr : in std_logic_vector(2 downto 0);
            variable data : out std_logic_vector(31 downto 0)
        ) is
        begin
            wait until falling_edge(clk_tb);
            fpu_address_tb    <= addr;
            fpu_chipselect_tb <= '1';
            fpu_write_tb      <= '0';
            wait for 5 ns;
            data := fpu_readdata_tb;
            wait until rising_edge(clk_tb);
            fpu_chipselect_tb <= '0';
        end procedure;

        procedure run_fpu_op(
            constant a_hex   : in std_logic_vector(31 downto 0);
            constant b_hex   : in std_logic_vector(31 downto 0);
            constant op_code : in std_logic_vector(1 downto 0);
            constant exp_hex : in std_logic_vector(31 downto 0);
            constant label_s : in string
        ) is
            variable rd_val : std_logic_vector(31 downto 0);
        begin
            avalon_write(ADDR_OP_A, a_hex);
            avalon_write(ADDR_OP_B, b_hex);
            avalon_write(ADDR_SELOP, (31 downto 2 => '0') & op_code);

            -- Esperar ready = 1
            loop
                avalon_read(ADDR_READY, rd_val);
                exit when rd_val(0) = '1';
            end loop;

            -- Disparar start
            avalon_write(ADDR_START, x"00000001");

            -- Esperar done_tick = 1
            loop
                avalon_read(ADDR_DONE, rd_val);
                exit when rd_val(0) = '1';
            end loop;

            -- Limpiar done_tick
            avalon_write(ADDR_DONE, x"00000001");

            -- Leer resultado
            avalon_read(ADDR_RES, rd_val);

            assert rd_val = exp_hex
                report "ERROR FPU (" & label_s & "): resultado no coincide con IEEE 754 esperado"
                severity error;

            report "OK FPU (" & label_s & "): resultado IEEE 754 coincide.";
        end procedure;
    begin
        reset_tb <= '1';
        wait for 3 * CLK_PER;
        reset_tb <= '0';
        wait for CLK_PER;

        -- A = 12.5 (0x41480000), B = 2.5 (0x40200000)
        run_fpu_op(x"41480000", x"40200000", "00", x"41700000", "12.5 + 2.5 = 15.0");
        run_fpu_op(x"41480000", x"40200000", "01", x"41200000", "12.5 - 2.5 = 10.0");
        run_fpu_op(x"41480000", x"40200000", "10", x"41FA0000", "12.5 * 2.5 = 31.25");
        run_fpu_op(x"41480000", x"40200000", "11", x"40A00000", "12.5 / 2.5 = 5.0");

        wait for 3 * CLK_PER;
        report "Simulacion fpu_avalon_tb finalizada exitosamente.";
        sim_done <= true;
        wait;
    end process;
end architecture sim;
