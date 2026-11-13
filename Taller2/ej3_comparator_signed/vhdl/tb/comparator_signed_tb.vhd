library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity comparator_signed_tb is
end entity comparator_signed_tb;

architecture Behavioral of comparator_signed_tb is
    -- Declaración del DUT (Device Under Test)
    component comparator_signed is
        port (
            a   : in  std_logic_vector(3 downto 0);
            b   : in  std_logic_vector(3 downto 0);
            sig : in  std_logic;
            lg  : out std_logic;
            eq  : out std_logic;
            ls  : out std_logic
        );
    end component;

    -- Señales de estímulo
    signal a_tb   : std_logic_vector(3 downto 0) := (others => '0');
    signal b_tb   : std_logic_vector(3 downto 0) := (others => '0');
    signal sig_tb : std_logic := '0';

    -- Señales de monitoreo
    signal lg_tb  : std_logic;
    signal eq_tb  : std_logic;
    signal ls_tb  : std_logic;

    -- Periodo de prueba por vector
    constant T_STEP : time := 10 ns;
begin
    -- Instanciación del DUT
    DUT: comparator_signed
        port map (
            a   => a_tb,
            b   => b_tb,
            sig => sig_tb,
            lg  => lg_tb,
            eq  => eq_tb,
            ls  => ls_tb
        );

    -- Proceso de estímulos exhaustivo (512 vectores: sig=0 y sig=1, para todo a y b)
    stim_proc: process
        variable a_signed, b_signed : signed(3 downto 0);
        variable a_uns, b_uns       : unsigned(3 downto 0);
        variable exp_lg, exp_eq, exp_ls : std_logic;
        variable total_errors : integer := 0;
    begin
        report "================ INICIO TESTBENCH COMPARADOR SIGNED/UNSIGNED ================" severity note;

        -- --------------------------------------------------------------------
        -- PARTE 1: Modo Unsigned (sig = '0') -> 256 combinaciones
        -- --------------------------------------------------------------------
        sig_tb <= '0';
        for i in 0 to 15 loop
            for j in 0 to 15 loop
                a_tb <= std_logic_vector(to_unsigned(i, 4));
                b_tb <= std_logic_vector(to_unsigned(j, 4));
                wait for T_STEP;

                a_uns := to_unsigned(i, 4);
                b_uns := to_unsigned(j, 4);

                if a_uns > b_uns then
                    exp_lg := '1'; exp_eq := '0'; exp_ls := '0';
                elsif a_uns = b_uns then
                    exp_lg := '0'; exp_eq := '1'; exp_ls := '0';
                else
                    exp_lg := '0'; exp_eq := '0'; exp_ls := '1';
                end if;

                assert (lg_tb = exp_lg and eq_tb = exp_eq and ls_tb = exp_ls)
                    report "ERROR UNSIGNED: a=" & integer'image(i) & " b=" & integer'image(j) &
                           " -> Obtenido: lg=" & std_logic'image(lg_tb) & " eq=" & std_logic'image(eq_tb) & " ls=" & std_logic'image(ls_tb)
                    severity error;

                if not (lg_tb = exp_lg and eq_tb = exp_eq and ls_tb = exp_ls) then
                    total_errors := total_errors + 1;
                end if;
            end loop;
        end loop;

        -- --------------------------------------------------------------------
        -- PARTE 2: Modo Signed (sig = '1') -> 256 combinaciones (-8 a +7)
        -- --------------------------------------------------------------------
        sig_tb <= '1';
        for i in -8 to 7 loop
            for j in -8 to 7 loop
                a_tb <= std_logic_vector(to_signed(i, 4));
                b_tb <= std_logic_vector(to_signed(j, 4));
                wait for T_STEP;

                a_signed := to_signed(i, 4);
                b_signed := to_signed(j, 4);

                if a_signed > b_signed then
                    exp_lg := '1'; exp_eq := '0'; exp_ls := '0';
                elsif a_signed = b_signed then
                    exp_lg := '0'; exp_eq := '1'; exp_ls := '0';
                else
                    exp_lg := '0'; exp_eq := '0'; exp_ls := '1';
                end if;

                assert (lg_tb = exp_lg and eq_tb = exp_eq and ls_tb = exp_ls)
                    report "ERROR SIGNED: a=" & integer'image(i) & " b=" & integer'image(j) &
                           " -> Obtenido: lg=" & std_logic'image(lg_tb) & " eq=" & std_logic'image(eq_tb) & " ls=" & std_logic'image(ls_tb)
                    severity error;

                if not (lg_tb = exp_lg and eq_tb = exp_eq and ls_tb = exp_ls) then
                    total_errors := total_errors + 1;
                end if;
            end loop;
        end loop;

        -- --------------------------------------------------------------------
        -- Reporte de Resultados
        -- --------------------------------------------------------------------
        if total_errors = 0 then
            report ">> VERIFICACION EXITOSA: Los 512 casos (unsigned y signed) fueron correctos!" severity note;
        else
            report ">> VERIFICACION CON FALLAS: Total de errores: " & integer'image(total_errors) severity error;
        end if;

        wait;
    end process;

end architecture Behavioral;

