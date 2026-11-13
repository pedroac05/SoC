library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ============================================================================
-- Entidad: comparator_signed
-- Descripción: Comparador combinacional de 4 bits para enteros con signo y sin signo.
--              Implementa una arquitectura paralela con evaluación concurrente
--              bit a bit y selectores priorizados gobernados por la señal 'sig'.
-- Puertos:
--   a   : Operando de entrada A (4 bits).
--   b   : Operando de entrada B (4 bits).
--   sig : Modo de operación:
--         '0' => Operandos sin signo (0 a 15).
--         '1' => Operandos con signo en complemento a 2 (-8 a +7).
--   lg  : Nivel alto ('1') si A > B (larger).
--   eq  : Nivel alto ('1') si A = B (equal).
--   ls  : Nivel alto ('1') si A < B (less).
-- ============================================================================
entity comparator_signed is
    port (
        a   : in  std_logic_vector(3 downto 0);
        b   : in  std_logic_vector(3 downto 0);
        sig : in  std_logic;
        lg  : out std_logic;
        eq  : out std_logic;
        ls  : out std_logic
    );
end entity comparator_signed;

architecture ParallelPriority of comparator_signed is
    -- Señales internas evaluadas concurrentemente (en paralelo)
    signal eq_bits : std_logic_vector(3 downto 0);
    signal gt_bits : std_logic_vector(3 downto 0);
    signal lt_bits : std_logic_vector(3 downto 0);

    -- Salidas internas antes de asignación final
    signal lg_int  : std_logic;
    signal eq_int  : std_logic;
    signal ls_int  : std_logic;
begin
    -- ------------------------------------------------------------------------
    -- 1. ETAPA PARALELA: Evaluación concurrente bit a bit
    -- ------------------------------------------------------------------------
    -- Para cada bit i (de 0 a 3):
    -- eq_bits(i) es '1' si a(i) == b(i)
    -- gt_bits(i) es '1' si a(i) = '1' y b(i) = '0' (mayor en magnitud binaria directa)
    -- lt_bits(i) es '1' si a(i) = '0' y b(i) = '1' (menor en magnitud binaria directa)
    GEN_PARALLEL: for i in 0 to 3 generate
        eq_bits(i) <= a(i) xnor b(i);
        gt_bits(i) <= a(i) and (not b(i));
        lt_bits(i) <= (not a(i)) and b(i);
    end generate GEN_PARALLEL;

    -- ------------------------------------------------------------------------
    -- 2. ETAPA DE SELECTOR PRIORIZADO (When / Else)
    -- ------------------------------------------------------------------------
    -- La igualdad global ocurre si y solo si todos los bits coinciden
    eq_int <= eq_bits(3) and eq_bits(2) and eq_bits(1) and eq_bits(0);

    -- Lógica para la salida 'lg' (a > b):
    -- Prioridad 1: Diferencia en el bit 3 (MSB):
    --   - Si sig = '1': El MSB es de signo. Si a(3)='0' y b(3)='1' => A es positivo y B negativo => A > B.
    --   - Si sig = '0': Binario natural. Si a(3)='1' y b(3)='0' => A > B.
    -- Prioridad 2: Bit 3 igual, diferencia en Bit 2:
    --   - Gana a(2) si a(2) > b(2) (independiente de sig, pues ambos tienen igual signo o magnitud alta).
    -- Prioridad 3: Bits 3..2 iguales, diferencia en Bit 1:
    --   - Gana a(1) si a(1) > b(1).
    -- Prioridad 4: Bits 3..1 iguales, diferencia en Bit 0:
    --   - Gana a(0) si a(0) > b(0).
    -- Else: Son iguales o B es mayor => lg = '0'.
    lg_int <= lt_bits(3) when (eq_bits(3) = '0' and sig = '1') else
              gt_bits(3) when (eq_bits(3) = '0' and sig = '0') else
              gt_bits(2) when (eq_bits(2) = '0') else
              gt_bits(1) when (eq_bits(1) = '0') else
              gt_bits(0) when (eq_bits(0) = '0') else
              '0';

    -- Lógica para la salida 'ls' (a < b):
    -- Prioridad 1: Diferencia en el bit 3 (MSB):
    --   - Si sig = '1': Si a(3)='1' y b(3)='0' => A es negativo y B positivo => A < B.
    --   - Si sig = '0': Si a(3)='0' y b(3)='1' => A < B.
    -- Prioridad 2: Bit 3 igual, diferencia en Bit 2 => lt_bits(2).
    -- Prioridad 3: Bits 3..2 iguales, diferencia en Bit 1 => lt_bits(1).
    -- Prioridad 4: Bits 3..1 iguales, diferencia en Bit 0 => lt_bits(0).
    -- Else: Son iguales o A es mayor => ls = '0'.
    ls_int <= gt_bits(3) when (eq_bits(3) = '0' and sig = '1') else
              lt_bits(3) when (eq_bits(3) = '0' and sig = '0') else
              lt_bits(2) when (eq_bits(2) = '0') else
              lt_bits(1) when (eq_bits(1) = '0') else
              lt_bits(0) when (eq_bits(0) = '0') else
              '0';

    -- Asignación a los puertos de salida
    lg <= lg_int;
    eq <= eq_int;
    ls <= ls_int;

end architecture ParallelPriority;

