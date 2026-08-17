library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gt2_tb is
    -- Un testbench no tiene puertos de entrada/salida externos
end entity gt2_tb;

architecture Behavioral of gt2_tb is

    -- 1. Declaración del componente a probar (DUT: Device Under Test)
    component gt2 is
        port (
            a  : in  std_logic_vector(1 downto 0);
            b  : in  std_logic_vector(1 downto 0);
            gt : out std_logic
        );
    end component;

    -- 2. Señales internas para conectar con el DUT
    signal a_tb  : std_logic_vector(1 downto 0) := "00";
    signal b_tb  : std_logic_vector(1 downto 0) := "00";
    signal gt_tb : std_logic;

    -- Período de retardo para cada estímulo
    constant T_STEP : time := 20 ns;

begin

    -- 3. Instanciación del DUT (Unit Under Test)
    DUT: gt2
        port map (
            a  => a_tb,
            b  => b_tb,
            gt => gt_tb
        );

    -- 4. Proceso de estímulos para probar todas las combinaciones (16 en total)
    stim_proc: process
    begin
        report ">>> Iniciando simulación de gt2_tb <<<" severity note;

        -- Recorremos todas las combinaciones posibles: a de 0 a 3, b de 0 a 3
        for i in 0 to 3 loop
            for j in 0 to 3 loop
                a_tb <= std_logic_vector(to_unsigned(i, 2));
                b_tb <= std_logic_vector(to_unsigned(j, 2));
                wait for T_STEP;
                
                -- Verificación automática
                if i > j then
                    assert gt_tb = '1'
                        report "ERROR: a = " & integer'image(i) & " y b = " & integer'image(j) & " pero gt = 0!"
                        severity error;
                else
                    assert gt_tb = '0'
                        report "ERROR: a = " & integer'image(i) & " y b = " & integer'image(j) & " pero gt = 1!"
                        severity error;
                end if;
            end loop;
        end loop;

        report ">>> Simulación finalizada con éxito (todas las pruebas pasaron) <<<" severity note;
        wait; -- Detiene la ejecución del proceso
    end process;

end architecture Behavioral;
