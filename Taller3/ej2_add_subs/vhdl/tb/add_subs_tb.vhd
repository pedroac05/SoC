library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================================================================
-- Testbench: add_subs_tb (VHDL)
-- Verifica casos representativos de suma (add_subsn='1') y resta (add_subsn='0')
-- incluyendo resultados positivos, negativos en complemento a 2 y acarreo.
-- ============================================================================

entity add_subs_tb is
end entity add_subs_tb;

architecture Behavioral of add_subs_tb is
    constant C_RANGE : integer := 4;
    constant T_STEP  : time    := 20 ns;

    component add_subs is
        generic (
            EXTENDED_RANGE : integer := 4
        );
        port (
            a         : in  std_logic_vector(EXTENDED_RANGE-1 downto 0);
            b         : in  std_logic_vector(EXTENDED_RANGE-1 downto 0);
            add_subsn : in  std_logic;
            cout      : out std_logic;
            sum       : out std_logic_vector(EXTENDED_RANGE-1 downto 0)
        );
    end component;

    signal a_tb         : std_logic_vector(C_RANGE-1 downto 0) := (others => '0');
    signal b_tb         : std_logic_vector(C_RANGE-1 downto 0) := (others => '0');
    signal add_subsn_tb : std_logic := '1';
    signal cout_tb      : std_logic;
    signal sum_tb       : std_logic_vector(C_RANGE-1 downto 0);
    signal res5_tb      : std_logic_vector(C_RANGE downto 0);
begin
    DUT: add_subs
        generic map (
            EXTENDED_RANGE => C_RANGE
        )
        port map (
            a         => a_tb,
            b         => b_tb,
            add_subsn => add_subsn_tb,
            cout      => cout_tb,
            sum       => sum_tb
        );

    -- Bus combinado de 5 bits (cout & sum) para observar fácilmente el resultado
    res5_tb <= cout_tb & sum_tb;

    stim_proc: process
        type test_vec_t is record
            a_val : integer;
            b_val : integer;
            op    : std_logic; -- '1' = suma, '0' = resta
        end record;

        type test_array_t is array (natural range <>) of test_vec_t;
        -- Casos ilustrativos de la Figura 3 del enunciado + casos frontera
        constant VECTORS : test_array_t := (
            (a_val =>  5, b_val =>  3, op => '1'), --  5 +  3 = +8  (cout=0, res=8)
            (a_val =>  5, b_val =>  3, op => '0'), --  5 -  3 = +2  (cout=0, res=+2)
            (a_val =>  3, b_val =>  5, op => '0'), --  3 -  5 = -2  (cout=1, res=-2 en C2)
            (a_val => 15, b_val => 15, op => '1'), -- 15 + 15 = 30  (cout=1, res=30)
            (a_val => 13, b_val =>  2, op => '1'), -- 13 +  2 = 15  (cout=0, res=15)
            (a_val =>  7, b_val => 15, op => '0'), --  7 - 15 = -8  (cout=1, res=-8 en C2)
            (a_val =>  1, b_val => 15, op => '0'), --  1 - 15 = -14 (cout=1, res=-14 en C2)
            (a_val =>  0, b_val => 15, op => '0'), --  0 - 15 = -15 (cout=1, res=-15 en C2)
            (a_val => 15, b_val =>  0, op => '0'), -- 15 -  0 = +15 (cout=0, res=+15)
            (a_val =>  9, b_val =>  9, op => '0')  --  9 -  9 =  0  (cout=0, res=0)
        );

        variable exp_u  : unsigned(C_RANGE downto 0);
        variable exp_s  : signed(C_RANGE downto 0);
        variable errors : integer := 0;
    begin
        report "================ INICIO TESTBENCH ADD_SUBS (VHDL) ================" severity note;

        for idx in VECTORS'range loop
            a_tb         <= std_logic_vector(to_unsigned(VECTORS(idx).a_val, C_RANGE));
            b_tb         <= std_logic_vector(to_unsigned(VECTORS(idx).b_val, C_RANGE));
            add_subsn_tb <= VECTORS(idx).op;
            wait for T_STEP;

            if VECTORS(idx).op = '1' then
                exp_u := to_unsigned(VECTORS(idx).a_val + VECTORS(idx).b_val, C_RANGE + 1);
                if res5_tb /= std_logic_vector(exp_u) then
                    report "ERROR SUMA: a=" & integer'image(VECTORS(idx).a_val) &
                           " b=" & integer'image(VECTORS(idx).b_val) severity error;
                    errors := errors + 1;
                end if;
            else
                exp_s := to_signed(VECTORS(idx).a_val - VECTORS(idx).b_val, C_RANGE + 1);
                if res5_tb /= std_logic_vector(exp_s) then
                    report "ERROR RESTA: a=" & integer'image(VECTORS(idx).a_val) &
                           " b=" & integer'image(VECTORS(idx).b_val) severity error;
                    errors := errors + 1;
                end if;
            end if;
        end loop;

        if errors = 0 then
            report ">> VERIFICACION EXITOSA: Todos los casos de suma y resta pasaron sin errores!" severity note;
        else
            report ">> VERIFICACION CON FALLAS: Total errores = " & integer'image(errors) severity error;
        end if;

        wait;
    end process;

end architecture Behavioral;
