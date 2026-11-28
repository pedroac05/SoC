library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ============================================================================
-- Taller 8 - Ejercicio Propuesto: ALU de Punto Flotante FP32 (IEEE 754)
-- Integra los 4 IP cores de Intel (fp_add, fp_sub, fp_mul, fp_div) con control
-- de latencia por FSM (idle -> busy -> done) para garantizar resultado válido.
--   selop = "00" -> Suma (A + B)           [Latencia IP: 2 ciclos]
--   selop = "01" -> Resta (A - B)          [Latencia IP: 2 ciclos]
--   selop = "10" -> Multiplicación (A * B) [Latencia IP: 2 ciclos]
--   selop = "11" -> División (A / B)       [Latencia IP: 11 ciclos]
-- ============================================================================
entity fpu_alu is
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        start     : in  std_logic;
        op_a      : in  std_logic_vector(31 downto 0);
        op_b      : in  std_logic_vector(31 downto 0);
        selop     : in  std_logic_vector(1 downto 0);
        ready     : out std_logic;
        done_tick : out std_logic;
        result    : out std_logic_vector(31 downto 0)
    );
end entity fpu_alu;

architecture rtl of fpu_alu is
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

    type state_type is (idle, busy, done);

    -- Ciclos de espera (margen seguro sobre la latencia de cada IP a 50 MHz)
    constant LAT_FAST : unsigned(4 downto 0) := to_unsigned(4, 5);
    constant LAT_DIV  : unsigned(4 downto 0) := to_unsigned(13, 5);

    signal state_reg, state_next : state_type;
    signal cnt_reg, cnt_next     : unsigned(4 downto 0);
    signal a_reg, b_reg          : std_logic_vector(31 downto 0);
    signal op_reg                : std_logic_vector(1 downto 0);
    signal res_reg, res_next     : std_logic_vector(31 downto 0);

    signal res_add : std_logic_vector(31 downto 0);
    signal res_sub : std_logic_vector(31 downto 0);
    signal res_mul : std_logic_vector(31 downto 0);
    signal res_div : std_logic_vector(31 downto 0);
    signal res_mux : std_logic_vector(31 downto 0);
begin
    -- Instanciación paralela de los 4 IP cores FP32
    u_fp_add : fp_add port map (clk => clk, areset => reset, a => a_reg, b => b_reg, q => res_add);
    u_fp_sub : fp_sub port map (clk => clk, areset => reset, a => a_reg, b => b_reg, q => res_sub);
    u_fp_mul : fp_mul port map (clk => clk, areset => reset, a => a_reg, b => b_reg, q => res_mul);
    u_fp_div : fp_div port map (clk => clk, areset => reset, a => a_reg, b => b_reg, q => res_div);

    -- MUX 4:1 según operación registrada
    with op_reg select
        res_mux <= res_add when "00",
                   res_sub when "01",
                   res_mul when "10",
                   res_div when others;

    -- Registros de estado, operandos y resultado
    process (clk, reset)
    begin
        if reset = '1' then
            state_reg <= idle;
            cnt_reg   <= (others => '0');
            a_reg     <= (others => '0');
            b_reg     <= (others => '0');
            op_reg    <= (others => '0');
            res_reg   <= (others => '0');
        elsif rising_edge(clk) then
            state_reg <= state_next;
            cnt_reg   <= cnt_next;
            res_reg   <= res_next;
            if state_reg = idle and start = '1' then
                a_reg  <= op_a;
                b_reg  <= op_b;
                op_reg <= selop;
            end if;
        end if;
    end process;

    -- Lógica de control de latencia (FSM)
    process (state_reg, cnt_reg, res_reg, start, selop, res_mux)
    begin
        ready      <= '0';
        done_tick  <= '0';
        state_next <= state_reg;
        cnt_next   <= cnt_reg;
        res_next   <= res_reg;

        case state_reg is
            when idle =>
                ready <= '1';
                if start = '1' then
                    if selop = "11" then
                        cnt_next <= LAT_DIV;
                    else
                        cnt_next <= LAT_FAST;
                    end if;
                    state_next <= busy;
                end if;

            when busy =>
                if cnt_reg = 0 then
                    res_next   <= res_mux;
                    state_next <= done;
                else
                    cnt_next <= cnt_reg - 1;
                end if;

            when done =>
                done_tick  <= '1';
                state_next <= idle;
        end case;
    end process;

    result <= res_reg;
end architecture rtl;
