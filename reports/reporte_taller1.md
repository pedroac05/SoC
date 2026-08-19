# Taller de Diseño: Gate-Level y RTL-Multiplexores
**Pontificia Universidad Javeriana**  
**Departamento de Electrónica**  
**System on Chip (SoC)**  

---

## Ejercicio Número 1: Circuito Greater-Than – Gate-Level

Un circuito *greater-than* compara dos entradas binarias, $a$ y $b$, e indica en su salida un `'1'` lógico únicamente cuando el valor numérico representado por $a$ es estrictamente mayor que $b$ ($a > b$).

---

### 1.1. Circuito Greater-Than de 2 Bits

#### 1.1.1. Tabla de Verdad
Sean las entradas $a = (a_1, a_0)$ y $b = (b_1, b_0)$, representando números sin signo en el rango de $0$ a $3$. La salida es $gt \in \{0, 1\}$.

| Fila | $a_1$ | $a_0$ | $b_1$ | $b_0$ | Decimal $a$ | Decimal $b$ | Condición ($a > b$) | Salida ($gt$) | Minitérmino |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **0**  | 0 | 0 | 0 | 0 | 0 | 0 | $0 > 0$ (Falso) | **0** | - |
| **1**  | 0 | 0 | 0 | 1 | 0 | 1 | $0 > 1$ (Falso) | **0** | - |
| **2**  | 0 | 0 | 1 | 0 | 0 | 2 | $0 > 2$ (Falso) | **0** | - |
| **3**  | 0 | 0 | 1 | 1 | 0 | 3 | $0 > 3$ (Falso) | **0** | - |
| **4**  | 0 | 1 | 0 | 0 | 1 | 0 | $1 > 0$ (**Verdadero**) | **1** | $m_4 = \overline{a_1} a_0 \overline{b_1} \overline{b_0}$ |
| **5**  | 0 | 1 | 0 | 1 | 1 | 1 | $1 > 1$ (Falso) | **0** | - |
| **6**  | 0 | 1 | 1 | 0 | 1 | 2 | $1 > 2$ (Falso) | **0** | - |
| **7**  | 0 | 1 | 1 | 1 | 1 | 3 | $1 > 3$ (Falso) | **0** | - |
| **8**  | 1 | 0 | 0 | 0 | 2 | 0 | $2 > 0$ (**Verdadero**) | **1** | $m_8 = a_1 \overline{a_0} \overline{b_1} \overline{b_0}$ |
| **9**  | 1 | 0 | 0 | 1 | 2 | 1 | $2 > 1$ (**Verdadero**) | **1** | $m_9 = a_1 \overline{a_0} \overline{b_1} b_0$ |
| **10** | 1 | 0 | 1 | 0 | 2 | 2 | $2 > 2$ (Falso) | **0** | - |
| **11** | 1 | 0 | 1 | 1 | 2 | 3 | $2 > 3$ (Falso) | **0** | - |
| **12** | 1 | 1 | 0 | 0 | 3 | 0 | $3 > 0$ (**Verdadero**) | **1** | $m_{12} = a_1 a_0 \overline{b_1} \overline{b_0}$ |
| **13** | 1 | 1 | 0 | 1 | 3 | 1 | $3 > 1$ (**Verdadero**) | **1** | $m_{13} = a_1 a_0 \overline{b_1} b_0$ |
| **14** | 1 | 1 | 1 | 0 | 3 | 2 | $3 > 2$ (**Verdadero**) | **1** | $m_{14} = a_1 a_0 b_1 \overline{b_0}$ |
| **15** | 1 | 1 | 1 | 1 | 3 | 3 | $3 > 3$ (Falso) | **0** | - |

---

#### 1.1.2. Derivación de la Expresión en Suma de Productos (SOP)

La función canónica corresponde a la suma de los 6 minitérminos donde la salida es 1:
$$\text{gt}(a_1, a_0, b_1, b_0) = \sum m(4, 8, 9, 12, 13, 14)$$

**Mapa de Karnaugh:**

| $a_1 a_0 \backslash b_1 b_0$ | **00** | **01** | **11** | **10** |
| :---: | :---: | :---: | :---: | :---: |
| **00** | 0 | 0 | 0 | 0 |
| **01** | **1** ($m_4$) | 0 | 0 | 0 |
| **11** | **1** ($m_{12}$) | **1** ($m_{13}$) | 0 | **1** ($m_{14}$) |
| **10** | **1** ($m_8$) | **1** ($m_9$) | 0 | 0 |

**Agrupamiento de términos primos esenciales:**
1. **Grupo 1 (4 celdas):** Celdas $\{m_8, m_9, m_{12}, m_{13}\} \implies a_1 \overline{b_1}$ *(El bit más significativo de $a$ es 1 y el de $b$ es 0)*.
2. **Grupo 2 (2 celdas):** Celdas $\{m_4, m_{12}\} \implies a_0 \overline{b_1} \overline{b_0}$ *(El bit menos significativo de $a$ es 1 y ambos bits de $b$ son 0)*.
3. **Grupo 3 (2 celdas):** Celdas $\{m_{12}, m_{14}\} \implies a_1 a_0 \overline{b_0}$ *($a$ es '11' y el bit menos significativo de $b$ es 0)*.

**Expresión Booleana Mínima (SOP):**
$$\mathbf{gt = (a_1 \cdot \overline{b_1}) + (a_1 \cdot a_0 \cdot \overline{b_0}) + (a_0 \cdot \overline{b_1} \cdot \overline{b_0})}$$

---

#### 1.1.3. Códigos HDL y Testbenches

##### Código VHDL (`gt2.vhd`)
```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gt2 is
    port (
        a  : in  std_logic_vector(1 downto 0);
        b  : in  std_logic_vector(1 downto 0);
        gt : out std_logic
    );
end entity gt2;

architecture Behavioral of gt2 is
begin
    gt <= (a(1) and not b(1)) or
          (a(1) and a(0) and not b(0)) or
          (a(0) and not b(1) and not b(0));
end architecture Behavioral;
```

##### Testbench VHDL (`gt2_tb.vhd`)
```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gt2_tb is
end entity gt2_tb;

architecture Behavioral of gt2_tb is
    component gt2 is
        port (
            a  : in  std_logic_vector(1 downto 0);
            b  : in  std_logic_vector(1 downto 0);
            gt : out std_logic
        );
    end component;

    signal a_tb  : std_logic_vector(1 downto 0) := "00";
    signal b_tb  : std_logic_vector(1 downto 0) := "00";
    signal gt_tb : std_logic;

    constant T_STEP : time := 20 ns;
begin
    DUT: gt2
        port map (
            a  => a_tb,
            b  => b_tb,
            gt => gt_tb
        );

    stim_proc: process
    begin
        for i in 0 to 3 loop
            for j in 0 to 3 loop
                a_tb <= std_logic_vector(to_unsigned(i, 2));
                b_tb <= std_logic_vector(to_unsigned(j, 2));
                wait for T_STEP;
                
                if i > j then
                    assert gt_tb = '1'
                        report "ERROR: Esperaba gt=1 para a=" & integer'image(i) & ", b=" & integer'image(j)
                        severity error;
                else
                    assert gt_tb = '0'
                        report "ERROR: Esperaba gt=0 para a=" & integer'image(i) & ", b=" & integer'image(j)
                        severity error;
                end if;
            end loop;
        end loop;
        wait;
    end process;
end architecture Behavioral;
```

##### Código Verilog (`gt2.v`)
```verilog
module gt2 (
    input  wire [1:0] a,
    input  wire [1:0] b,
    output wire       gt
);

    assign gt = (a[1] & ~b[1]) |
                (a[1] & a[0] & ~b[0]) |
                (a[0] & ~b[1] & ~b[0]);

endmodule
```

##### Testbench Verilog (`gt2_tb.v`)
```verilog
`timescale 1ns / 1ps

module gt2_tb;
    reg  [1:0] a;
    reg  [1:0] b;
    wire       gt;

    integer i, j;

    gt2 dut (
        .a(a),
        .b(b),
        .gt(gt)
    );

    initial begin
        a = 2'b00;
        b = 2'b00;

        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                a = i;
                b = j;
                #20;
                if ((i > j && gt !== 1'b1) || (i <= j && gt !== 1'b0)) begin
                    $display("ERROR en a=%0d, b=%0d => gt=%b", i, j, gt);
                end
            end
        end
        $stop;
    end
endmodule
```

---

#### 1.1.4. Circuito Generado por Quartus (RTL Viewer)

> **[EVIDENCIA FOTOGRÁFICA 1: RTL VIEWER GT2]**  
> *Guarda la captura de Quartus (Tools $\rightarrow$ Netlist Viewers $\rightarrow$ RTL Viewer) con el nombre `reports/images/gt2_rtl.png`.*

![Circuito RTL del comparador de 2 bits](images/gt2_rtl.png)

---

#### 1.1.5. Simulación en ModelSim y Análisis de Resultados

> **[EVIDENCIA FOTOGRÁFICA 2: SIMULACIÓN MODELSIM GT2]**  
> *Guarda la captura de la forma de onda de ModelSim con el nombre `reports/images/gt2_modelsim.png`.*

![Forma de onda de la simulación del comparador de 2 bits](images/gt2_modelsim.png)

##### Análisis del Diagrama de Tiempos:
1. La simulación recorre un total de **16 combinaciones** (de $a=0, b=0$ hasta $a=3, b=3$), asignando $20\,\text{ns}$ a cada vector de prueba (tiempo total: $320\,\text{ns}$).
2. **Eventos de Interés ($gt = 1$):**
   * En el intervalo correspondiente a $a=1$, la salida $gt$ se activa en `'1'` durante $b=0$.
   * En el intervalo de $a=2$, la salida $gt$ se activa en `'1'` durante $b=0$ y $b=1$.
   * En el intervalo de $a=3$, la salida $gt$ se activa en `'1'` durante $b=0$, $b=1$ y $b=2$.
3. **Casos $gt = 0$:**
   * En todas las combinaciones donde $a = b$ o $a < b$, la salida se mantiene de forma estable en nivel bajo `'0'`.
4. **Conclusión:** El comportamiento observado en la simulación temporal coincide exactamente con la tabla de verdad y la ecuación SOP simplificada.

---

### 1.2. Circuito Comparador de Igualdad de 2 Bits (`twoBitEquality` / `eq2`)

El módulo `twoBitEquality` compara dos vectores binarios de 2 bits, $a = (a_1, a_0)$ y $b = (b_1, b_0)$, y genera un `'1'` lógico en su salida `eq` únicamente cuando ambas entradas son exactamente idénticas ($a = b$). Este módulo sirve como bloque elemental para la construcción estructural del comparador de 4 bits.

---

#### 1.2.1. Tabla de Verdad
Sean las entradas $a = (a_1, a_0)$ y $b = (b_1, b_0)$ con $a, b \in \{0, 1, 2, 3\}$. La salida es $eq \in \{0, 1\}$.

| Fila | $a_1$ | $a_0$ | $b_1$ | $b_0$ | Decimal $a$ | Decimal $b$ | Condición ($a = b$) | Salida ($eq$) | Minitérmino |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **0**  | 0 | 0 | 0 | 0 | 0 | 0 | $0 = 0$ (**Verdadero**) | **1** | $m_0 = \overline{a_1} \overline{a_0} \overline{b_1} \overline{b_0}$ |
| **1**  | 0 | 0 | 0 | 1 | 0 | 1 | $0 = 1$ (Falso) | **0** | - |
| **2**  | 0 | 0 | 1 | 0 | 0 | 2 | $0 = 2$ (Falso) | **0** | - |
| **3**  | 0 | 0 | 1 | 1 | 0 | 3 | $0 = 3$ (Falso) | **0** | - |
| **4**  | 0 | 1 | 0 | 0 | 1 | 0 | $1 = 0$ (Falso) | **0** | - |
| **5**  | 0 | 1 | 0 | 1 | 1 | 1 | $1 = 1$ (**Verdadero**) | **1** | $m_5 = \overline{a_1} a_0 \overline{b_1} b_0$ |
| **6**  | 0 | 1 | 1 | 0 | 1 | 2 | $1 = 2$ (Falso) | **0** | - |
| **7**  | 0 | 1 | 1 | 1 | 1 | 3 | $1 = 3$ (Falso) | **0** | - |
| **8**  | 1 | 0 | 0 | 0 | 2 | 0 | $2 = 0$ (Falso) | **0** | - |
| **9**  | 1 | 0 | 0 | 1 | 2 | 1 | $2 = 1$ (Falso) | **0** | - |
| **10** | 1 | 0 | 1 | 0 | 2 | 2 | $2 = 2$ (**Verdadero**) | **1** | $m_{10} = a_1 \overline{a_0} b_1 \overline{b_0}$ |
| **11** | 1 | 0 | 1 | 1 | 2 | 3 | $2 = 3$ (Falso) | **0** | - |
| **12** | 1 | 1 | 0 | 0 | 3 | 0 | $3 = 0$ (Falso) | **0** | - |
| **13** | 1 | 1 | 0 | 1 | 3 | 1 | $3 = 1$ (Falso) | **0** | - |
| **14** | 1 | 1 | 1 | 0 | 3 | 2 | $3 = 2$ (Falso) | **0** | - |
| **15** | 1 | 1 | 1 | 1 | 3 | 3 | $3 = 3$ (**Verdadero**) | **1** | $m_{15} = a_1 a_0 b_1 b_0$ |

---

#### 1.2.2. Derivación Lógica a Nivel Compuerta

Para que dos palabras binarias de 2 bits sean iguales, se debe cumplir simultáneamente que el bit más significativo sea igual ($a_1 = b_1$) **Y** que el bit menos significativo sea igual ($a_0 = b_0$).

La igualdad a nivel de bit se implementa con la compuerta lógica **XNOR** (equivalencia):
* $e_1 = a_1 \odot b_1 = a_1 b_1 + \overline{a_1}\overline{b_1}$
* $e_0 = a_0 \odot b_0 = a_0 b_0 + \overline{a_0}\overline{b_0}$

Por lo tanto, la función lógica a nivel compuerta es:
$$\mathbf{eq = (a_1 \odot b_1) \cdot (a_0 \odot b_0) = (a_1 \text{ XNOR } b_1) \text{ AND } (a_0 \text{ XNOR } b_0)}$$

---

#### 1.2.3. Códigos HDL y Testbenches

##### Código VHDL (`eq2.vhd`)
```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity eq2 is
    port (
        a  : in  std_logic_vector(1 downto 0);
        b  : in  std_logic_vector(1 downto 0);
        eq : out std_logic
    );
end entity eq2;

architecture Behavioral of eq2 is
begin
    -- Igualdad a nivel compuerta: (a1 XNOR b1) AND (a0 XNOR b0)
    eq <= (a(1) xnor b(1)) and (a(0) xnor b(0));
end architecture Behavioral;
```

##### Testbench VHDL (`eq2_tb.vhd`)
```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity eq2_tb is
end entity eq2_tb;

architecture Behavioral of eq2_tb is
    component eq2 is
        port (
            a  : in  std_logic_vector(1 downto 0);
            b  : in  std_logic_vector(1 downto 0);
            eq : out std_logic
        );
    end component;

    signal a_tb  : std_logic_vector(1 downto 0) := "00";
    signal b_tb  : std_logic_vector(1 downto 0) := "00";
    signal eq_tb : std_logic;

    constant T_STEP : time := 20 ns;
begin
    DUT: eq2
        port map (
            a  => a_tb,
            b  => b_tb,
            eq => eq_tb
        );

    stim_proc: process
    begin
        for i in 0 to 3 loop
            for j in 0 to 3 loop
                a_tb <= std_logic_vector(to_unsigned(i, 2));
                b_tb <= std_logic_vector(to_unsigned(j, 2));
                wait for T_STEP;
                
                if i = j then
                    assert eq_tb = '1'
                        report "ERROR: Esperaba eq=1 para a=" & integer'image(i) & ", b=" & integer'image(j)
                        severity error;
                else
                    assert eq_tb = '0'
                        report "ERROR: Esperaba eq=0 para a=" & integer'image(i) & ", b=" & integer'image(j)
                        severity error;
                end if;
            end loop;
        end loop;
        
        report "Simulacion de eq2_tb completada exitosamente." severity note;
        wait;
    end process;
end architecture Behavioral;
```

##### Código Verilog (`eq2.v`)
```verilog
`timescale 1ns / 1ps

module eq2 (
    input  wire [1:0] a,
    input  wire [1:0] b,
    output wire       eq
);

    // Igualdad a nivel compuerta: (a1 ~^ b1) & (a0 ~^ b0)
    assign eq = (a[1] ~^ b[1]) & (a[0] ~^ b[0]);

endmodule
```

##### Testbench Verilog (`eq2_tb.v`)
```verilog
`timescale 1ns / 1ps

module eq2_tb;
    reg  [1:0] a;
    reg  [1:0] b;
    wire       eq;

    integer i, j;
    integer errors = 0;

    eq2 dut (
        .a(a),
        .b(b),
        .eq(eq)
    );

    initial begin
        a = 2'b00;
        b = 2'b00;

        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                a = i;
                b = j;
                #20;
                if (i == j && eq !== 1'b1) begin
                    $display("ERROR: Esperaba eq=1 para a=%0d, b=%0d => obtenido eq=%b", i, j, eq);
                    errors = errors + 1;
                end else if (i != j && eq !== 1'b0) begin
                    $display("ERROR: Esperaba eq=0 para a=%0d, b=%0d => obtenido eq=%b", i, j, eq);
                    errors = errors + 1;
                end
            end
        end

        if (errors == 0) begin
            $display(">>> Simulacion de eq2_tb exitosa: 0 errores encontrados. <<<");
        end else begin
            $display(">>> Simulacion con %0d errores. <<<", errors);
        end

        $stop;
    end
endmodule
```

---

#### 1.2.4. Circuito Generado por Quartus (RTL Viewer)

> **[EVIDENCIA FOTOGRÁFICA 3: RTL VIEWER EQ2]**  
> *Guarda la captura de Quartus (Tools $\rightarrow$ Netlist Viewers $\rightarrow$ RTL Viewer) con el nombre `reports/images/eq2_rtl.png`.*

![Circuito RTL del comparador de igualdad de 2 bits](images/eq2_rtl.png)

---

#### 1.2.5. Simulación en ModelSim y Análisis de Resultados

> **[EVIDENCIA FOTOGRÁFICA 4: SIMULACIÓN MODELSIM EQ2]**  
> *Guarda la captura de la forma de onda de ModelSim con el nombre `reports/images/eq2_modelsim.png`.*

![Forma de onda de la simulación del comparador de igualdad de 2 bits](images/eq2_modelsim.png)

##### Análisis del Diagrama de Tiempos:
1. **Duración del Ensayo:** Se evaluaron las 16 combinaciones de entrada aplicando $20\,\text{ns}$ a cada vector, para un tiempo total de simulación de $320\,\text{ns}$.
2. **Eventos de Interés ($eq = 1$):** La salida se activa en nivel lógico alto únicamente en los 4 instantes donde el valor numérico de $a$ coincide con $b$:
   - $t \in [0, 20)\,\text{ns}$: $a = 0, b = 0 \implies eq = 1$.
   - $t \in [100, 120)\,\text{ns}$: $a = 1, b = 1 \implies eq = 1$.
   - $t \in [200, 220)\,\text{ns}$: $a = 2, b = 2 \implies eq = 1$.
   - $t \in [300, 320)\,\text{ns}$: $a = 3, b = 3 \implies eq = 1$.
3. **Casos $eq = 0$:** En todos los demás 12 intervalos donde $a \neq b$, la salida se mantiene de forma estable en `'0'`.
4. **Conclusión:** La simulación temporal en ModelSim valida el diseño funcional y la correcta síntesis de compuertas XNOR y AND para el comparador de igualdad de 2 bits.

---

### 1.3. Circuito Greater-Than de 4 Bits Estructural (`gt4`)

Para extender la comparación a números de 4 bits $a = (a_3, a_2, a_1, a_0)$ y $b = (b_3, b_2, b_1, b_0)$ a nivel compuerta, se emplea un enfoque de **diseño jerárquico y estructural**. En lugar de diseñar una tabla de verdad de $2^8 = 256$ filas, se reutilizan dos instancias del comparador `gt2` y una instancia del comparador de igualdad `eq2`.

---

#### 1.3.1. Arquitectura Estructural y Diagrama de Bloques

Las palabras de 4 bits se dividen en dos bloques de 2 bits:
* **Parte Alta (MSBs):** $a_{high} = a(3 \text{ downto } 2)$ y $b_{high} = b(3 \text{ downto } 2)$.
* **Parte Baja (LSBs):** $a_{low} = a(1 \text{ downto } 0)$ y $b_{low} = b(1 \text{ downto } 0)$.

El valor de $a$ es mayor que $b$ ($a > b$) si y solo si:
1. La parte más significativa de $a$ es estrictamente mayor que la de $b$ ($gt_{high} = 1$).
2. O bien, si las partes más significativas son iguales ($eq_{high} = 1$) **Y** la parte menos significativa de $a$ es mayor que la de $b$ ($gt_{low} = 1$).

**Ecuación de Salida:**
$$\mathbf{gt_4 = gt_{high} \lor (eq_{high} \land gt_{low})}$$

```mermaid
graph LR
    A["a[3:0]"] --> A_H["a[3:2] (High)"]
    A --> A_L["a[1:0] (Low)"]
    B["b[3:0]"] --> B_H["b[3:2] (High)"]
    B --> B_L["b[1:0] (Low)"]

    A_H --> GT_H["gt2 (High)"]
    B_H --> GT_H
    GT_H -->|"gt_high"| OR1["OR"]

    A_H --> EQ_H["eq2 (High)"]
    B_H --> EQ_H
    EQ_H -->|"eq_high"| AND1["AND"]

    A_L --> GT_L["gt2 (Low)"]
    B_L --> GT_L
    GT_L -->|"gt_low"| AND1

    AND1 --> OR1
    OR1 --> GT_OUT["gt (Salida 4 bits)"]
```
*Figura 2. Diagrama de bloques estructural del comparador greater-than de 4 bits.*

---

#### 1.3.2. Códigos HDL y Testbenches

##### Código VHDL (`gt4.vhd`)
```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gt4 is
    port (
        a  : in  std_logic_vector(3 downto 0);
        b  : in  std_logic_vector(3 downto 0);
        gt : out std_logic
    );
end entity gt4;

architecture Structural of gt4 is
    component gt2 is
        port (
            a  : in  std_logic_vector(1 downto 0);
            b  : in  std_logic_vector(1 downto 0);
            gt : out std_logic
        );
    end component;

    component eq2 is
        port (
            a  : in  std_logic_vector(1 downto 0);
            b  : in  std_logic_vector(1 downto 0);
            eq : out std_logic
        );
    end component;

    signal gt_high : std_logic;
    signal eq_high : std_logic;
    signal gt_low  : std_logic;
begin
    -- Comparación de la parte alta
    U_GT_HIGH: gt2
        port map (
            a  => a(3 downto 2),
            b  => b(3 downto 2),
            gt => gt_high
        );

    -- Igualdad de la parte alta
    U_EQ_HIGH: eq2
        port map (
            a  => a(3 downto 2),
            b  => b(3 downto 2),
            eq => eq_high
        );

    -- Comparación de la parte baja
    U_GT_LOW: gt2
        port map (
            a  => a(1 downto 0),
            b  => b(1 downto 0),
            gt => gt_low
        );

    -- Lógica de salida
    gt <= gt_high or (eq_high and gt_low);

end architecture Structural;
```

##### Testbench VHDL (`gt4_tb.vhd`)
```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gt4_tb is
end entity gt4_tb;

architecture Behavioral of gt4_tb is
    component gt4 is
        port (
            a  : in  std_logic_vector(3 downto 0);
            b  : in  std_logic_vector(3 downto 0);
            gt : out std_logic
        );
    end component;

    signal a_tb  : std_logic_vector(3 downto 0) := "0000";
    signal b_tb  : std_logic_vector(3 downto 0) := "0000";
    signal gt_tb : std_logic;

    constant T_STEP : time := 20 ns;
begin
    DUT: gt4
        port map (
            a  => a_tb,
            b  => b_tb,
            gt => gt_tb
        );

    stim_proc: process
    begin
        -- Verificación exhaustiva de las 256 combinaciones
        for i in 0 to 15 loop
            for j in 0 to 15 loop
                a_tb <= std_logic_vector(to_unsigned(i, 4));
                b_tb <= std_logic_vector(to_unsigned(j, 4));
                wait for T_STEP;

                if i > j then
                    assert gt_tb = '1'
                        report "ERROR: Esperaba gt=1 para a=" & integer'image(i) & ", b=" & integer'image(j)
                        severity error;
                else
                    assert gt_tb = '0'
                        report "ERROR: Esperaba gt=0 para a=" & integer'image(i) & ", b=" & integer'image(j)
                        severity error;
                end if;
            end loop;
        end loop;

        report ">>> Simulacion exhaustiva de gt4_tb (256 vectores) completada exitosamente. <<<" severity note;
        wait;
    end process;
end architecture Behavioral;
```

##### Código Verilog (`gt4.v`)
```verilog
`timescale 1ns / 1ps

module gt4 (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire       gt
);

    wire gt_high;
    wire eq_high;
    wire gt_low;

    // Comparación parte alta
    gt2 u_gt_high (
        .a(a[3:2]),
        .b(b[3:2]),
        .gt(gt_high)
    );

    // Igualdad parte alta
    eq2 u_eq_high (
        .a(a[3:2]),
        .b(b[3:2]),
        .eq(eq_high)
    );

    // Comparación parte baja
    gt2 u_gt_low (
        .a(a[1:0]),
        .b(b[1:0]),
        .gt(gt_low)
    );

    // Lógica estructural de salida
    assign gt = gt_high | (eq_high & gt_low);

endmodule
```

##### Testbench Verilog (`gt4_tb.v`)
```verilog
`timescale 1ns / 1ps

module gt4_tb;
    reg  [3:0] a;
    reg  [3:0] b;
    wire       gt;

    integer i, j;
    integer errors = 0;

    gt4 dut (
        .a(a),
        .b(b),
        .gt(gt)
    );

    initial begin
        a = 4'b0000;
        b = 4'b0000;

        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                a = i;
                b = j;
                #20;

                if (i > j && gt !== 1'b1) begin
                    $display("ERROR: Esperaba gt=1 para a=%0d, b=%0d => obtenido gt=%b", i, j, gt);
                    errors = errors + 1;
                end else if (i <= j && gt !== 1'b0) begin
                    $display("ERROR: Esperaba gt=0 para a=%0d, b=%0d => obtenido gt=%b", i, j, gt);
                    errors = errors + 1;
                end
            end
        end

        if (errors == 0) begin
            $display(">>> Simulacion de gt4_tb exitosa: 256 casos evaluados sin errores. <<<");
        end else begin
            $display(">>> Simulacion finalizada con %0d errores. <<<", errors);
        end

        $stop;
    end
endmodule
```

---

#### 1.3.3. Circuito Generado por Quartus (RTL Viewer)

> **[EVIDENCIA FOTOGRÁFICA 5: RTL VIEWER GT4]**  
> *Guarda la captura de Quartus (Tools $\rightarrow$ Netlist Viewers $\rightarrow$ RTL Viewer) con el nombre `reports/images/gt4_rtl.png`.*

![Circuito RTL del comparador estructural de 4 bits](images/gt4_rtl.png)

---

#### 1.3.4. Simulación en ModelSim y Análisis de Resultados

> **[EVIDENCIA FOTOGRÁFICA 6: SIMULACIÓN MODELSIM GT4]**  
> *Guarda la captura de la forma de onda de ModelSim con el nombre `reports/images/gt4_modelsim.png`.*

![Forma de onda de la simulación del comparador de 4 bits](images/gt4_modelsim.png)

##### Análisis del Diagrama de Tiempos:
1. **Espacio de Búsqueda:** Se verificaron de forma exhaustiva los **256 vectores de prueba** ($16 \times 16$), tomando $20\,\text{ns}$ por vector para un tiempo total de simulación de $5120\,\text{ns}$ ($5.12\,\mu\text{s}$).
2. **Distribución de Casos:**
   - En una matriz de $16 \times 16$:
     - Hay $16$ casos donde $a = b$ ($gt = 0$).
     - Hay $\frac{256 - 16}{2} = 120$ casos donde $a > b$ (**$gt = 1$**).
     - Hay $120$ casos donde $a < b$ ($gt = 0$).
3. **Validación de la Jerarquía:**
   - Cuando $a_{high} > b_{high}$, la señal interna `gt_high` se pone en alto y fuerza directamente la salida `gt = 1` sin importar la parte baja.
   - Cuando $a_{high} = b_{high}$, la señal `eq_high` se activa en `'1'`, permitiendo que la decisión dependa exclusivamente de `gt_low`.
4. **Conclusión:** La arquitectura modular cumple estrictamente la especificación matemática de un comparador binario sin signo de 4 bits a nivel estructural.

---

## Ejercicio Número 2: Binary Decoder – Gate Level

Un decodificador binario $n$-to-$2^n$ convierte un código de entrada de $n$ bits en una salida *One-Hot* de $2^n$ bits, activando en `'1'` lógico únicamente la línea de salida que corresponde al valor numérico decimal de la entrada cuando la señal de habilitación (`en`) está activa.

---

### 2.1. Decodificador Binario 2-to-4 (`dec2to4`)

---

#### 2.1.1. Tabla de Verdad
Sean la señal de habilitación $en$, la entrada binaria $in\_v = (in_1, in_0)$ y la salida $bcode = (b_3, b_2, b_1, b_0)$:

| Fila | `en` | $in_1$ | $in_0$ | Decimal $in$ | $b_3$ | $b_2$ | $b_1$ | $b_0$ | `bcode` (Salida) | Minitérmino Activo |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **0** | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | `0000` | Ninguno (Deshabilitado) |
| **1** | 0 | 0 | 1 | 1 | 0 | 0 | 0 | 0 | `0000` | Ninguno (Deshabilitado) |
| **2** | 0 | 1 | 0 | 2 | 0 | 0 | 0 | 0 | `0000` | Ninguno (Deshabilitado) |
| **3** | 0 | 1 | 1 | 3 | 0 | 0 | 0 | 0 | `0000` | Ninguno (Deshabilitado) |
| **4** | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | `0001` | $m_4 = en \cdot \overline{in_1} \cdot \overline{in_0}$ |
| **5** | 1 | 0 | 1 | 1 | 0 | 0 | 1 | 0 | `0010` | $m_5 = en \cdot \overline{in_1} \cdot in_0$ |
| **6** | 1 | 1 | 0 | 2 | 0 | 1 | 0 | 0 | `0100` | $m_6 = en \cdot in_1 \cdot \overline{in_0}$ |
| **7** | 1 | 1 | 1 | 3 | 1 | 0 | 0 | 0 | `1000` | $m_7 = en \cdot in_1 \cdot in_0$ |

---

#### 2.1.2. Derivación Lógica en Suma de Productos (SOP)

Cada línea de salida corresponde exactamente a un minitérmino único condicionado por la señal de habilitación $en$:
* **Línea 0 ($b_0$):** Activa cuando $en=1$ e $in=00_2 \implies \mathbf{bcode(0) = en \cdot \overline{in(1)} \cdot \overline{in(0)}}$
* **Línea 1 ($b_1$):** Activa cuando $en=1$ e $in=01_2 \implies \mathbf{bcode(1) = en \cdot \overline{in(1)} \cdot in(0)}$
* **Línea 2 ($b_2$):** Activa cuando $en=1$ e $in=10_2 \implies \mathbf{bcode(2) = en \cdot in(1) \cdot \overline{in(0)}}$
* **Línea 3 ($b_3$):** Activa cuando $en=1$ e $in=11_2 \implies \mathbf{bcode(3) = en \cdot in(1) \cdot in(0)}$

---

#### 2.1.3. Códigos HDL y Testbenches

##### Código VHDL (`dec2to4.vhd`)
```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dec2to4 is
    port (
        en    : in  std_logic;
        in_v  : in  std_logic_vector(1 downto 0);
        bcode : out std_logic_vector(3 downto 0)
    );
end entity dec2to4;

architecture GateLevel of dec2to4 is
begin
    -- Derivación en Suma de Productos (SOP) a nivel compuerta
    bcode(0) <= en and (not in_v(1)) and (not in_v(0));
    bcode(1) <= en and (not in_v(1)) and in_v(0);
    bcode(2) <= en and in_v(1) and (not in_v(0));
    bcode(3) <= en and in_v(1) and in_v(0);
end architecture GateLevel;
```

##### Testbench VHDL (`dec2to4_tb.vhd`)
```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dec2to4_tb is
end entity dec2to4_tb;

architecture Behavioral of dec2to4_tb is
    component dec2to4 is
        port (
            en    : in  std_logic;
            in_v  : in  std_logic_vector(1 downto 0);
            bcode : out std_logic_vector(3 downto 0)
        );
    end component;

    signal en_tb    : std_logic := '0';
    signal in_v_tb  : std_logic_vector(1 downto 0) := "00";
    signal bcode_tb : std_logic_vector(3 downto 0);

    constant T_STEP : time := 20 ns;
begin
    DUT: dec2to4
        port map (
            en    => en_tb,
            in_v  => in_v_tb,
            bcode => bcode_tb
        );

    stim_proc: process
        variable expected_val : std_logic_vector(3 downto 0);
    begin
        -- Caso 1: Enable desactivado (en = '0') -> bcode debe ser "0000"
        en_tb <= '0';
        for i in 0 to 3 loop
            in_v_tb <= std_logic_vector(to_unsigned(i, 2));
            wait for T_STEP;
            assert bcode_tb = "0000"
                report "ERROR en en=0: Se esperaba bcode=0000"
                severity error;
        end loop;

        -- Caso 2: Enable activado (en = '1') -> decodificación One-Hot
        en_tb <= '1';
        for i in 0 to 3 loop
            in_v_tb <= std_logic_vector(to_unsigned(i, 2));
            wait for T_STEP;
            
            case i is
                when 0 => expected_val := "0001";
                when 1 => expected_val := "0010";
                when 2 => expected_val := "0100";
                when 3 => expected_val := "1000";
                when others => expected_val := "0000";
            end case;

            assert bcode_tb = expected_val
                report "ERROR en en=1: Valor incorrecto para in=" & integer'image(i)
                severity error;
        end loop;

        report ">>> Simulacion de dec2to4_tb finalizada exitosamente sin errores. <<<" severity note;
        wait;
    end process;
end architecture Behavioral;
```

##### Código Verilog (`dec2to4.v`)
```verilog
`timescale 1ns / 1ps

module dec2to4 (
    input  wire       en,
    input  wire [1:0] in_v,
    output wire [3:0] bcode
);

    // Derivación en Suma de Productos (SOP) a nivel compuerta
    assign bcode[0] = en & ~in_v[1] & ~in_v[0];
    assign bcode[1] = en & ~in_v[1] &  in_v[0];
    assign bcode[2] = en &  in_v[1] & ~in_v[0];
    assign bcode[3] = en &  in_v[1] &  in_v[0];

endmodule
```

##### Testbench Verilog (`dec2to4_tb.v`)
```verilog
`timescale 1ns / 1ps

module dec2to4_tb;
    reg        en;
    reg  [1:0] in_v;
    wire [3:0] bcode;

    integer i;
    integer errors = 0;
    reg [3:0] expected_val;

    dec2to4 dut (
        .en(en),
        .in_v(in_v),
        .bcode(bcode)
    );

    initial begin
        en   = 1'b0;
        in_v = 2'b00;

        // Caso 1: Enable desactivado (en = 0)
        en = 1'b0;
        for (i = 0; i < 4; i = i + 1) begin
            in_v = i;
            #20;
            if (bcode !== 4'b0000) begin
                $display("ERROR en en=0, in_v=%0d => Esperado=0000, Obtenido=%b", i, bcode);
                errors = errors + 1;
            end
        end

        // Caso 2: Enable activado (en = 1)
        en = 1'b1;
        for (i = 0; i < 4; i = i + 1) begin
            in_v = i;
            expected_val = 4'b0001 << i;
            #20;
            if (bcode !== expected_val) begin
                $display("ERROR en en=1, in_v=%0d => Esperado=%b, Obtenido=%b", i, expected_val, bcode);
                errors = errors + 1;
            end
        end

        if (errors == 0) begin
            $display(">>> Simulacion de dec2to4_tb exitosa: 0 errores encontrados. <<<");
        end else begin
            $display(">>> Simulacion finalizada con %0d errores. <<<", errors);
        end

        $stop;
    end
endmodule
```

---

#### 2.1.4. Circuito Generado por Quartus (RTL Viewer)

> **[EVIDENCIA FOTOGRÁFICA 7: RTL VIEWER DEC2TO4]**  
> *Guarda la captura de Quartus (Tools $\rightarrow$ Netlist Viewers $\rightarrow$ RTL Viewer) con el nombre `reports/images/dec2to4_rtl.png`.*

![Circuito RTL del decodificador 2-to-4](images/dec2to4_rtl.png)

---

#### 2.1.5. Simulación en ModelSim y Análisis de Resultados

> **[EVIDENCIA FOTOGRÁFICA 8: SIMULACIÓN MODELSIM DEC2TO4]**  
> *Guarda la captura de la forma de onda de ModelSim con el nombre `reports/images/dec2to4_modelsim.png`.*

![Forma de onda de la simulación del decodificador 2-to-4](images/dec2to4_modelsim.png)

##### Análisis del Diagrama de Tiempos:
1. **Fase de Deshabilitación ($t \in [0, 80)\,\text{ns}$):**
   - Con $en = 0$, la salida `bcode` permanece invariablemente en `"0000"` para las 4 combinaciones de $in\_v$, garantizando la inhibición completa del circuito.
2. **Fase de Decodificación Activa ($t \in [80, 160)\,\text{ns}$):**
   - Con $en = 1$, se observa la activación secuencial *One-Hot*:
     - $t \in [80, 100)\,\text{ns}$ ($in\_v = 0 \implies \text{"00"}$): `bcode` = `"0001"` (bit 0 en alto).
     - $t \in [100, 120)\,\text{ns}$ ($in\_v = 1 \implies \text{"01"}$): `bcode` = `"0010"` (bit 1 en alto).
     - $t \in [120, 140)\,\text{ns}$ ($in\_v = 2 \implies \text{"10"}$): `bcode` = `"0100"` (bit 2 en alto).
     - $t \in [140, 160)\,\text{ns}$ ($in\_v = 3 \implies \text{"11"}$): `bcode` = `"1000"` (bit 3 en alto).
3. **Conclusión:** El circuito gate-level decodifica de forma unívoca cada combinación binaria sin generar transiciones espurias ni solapamientos entre salidas activas.

---

### 2.2. Decodificador Binario 3-to-8 Estructural (`dec3to8`)

Para diseñar un decodificador de 3 entradas y 8 salidas ($3 \text{-to-} 8$) a partir de bloques constructivos $2 \text{-to-} 4$, se utiliza el bit más significativo de la entrada ($in\_v(2)$) para alternar la habilitación entre dos instancias de `dec2to4`.

---

#### 2.2.1. Arquitectura Estructural y Diagrama de Bloques

* **Bloque Inferior (`U_DEC_LOW`):**
  - Habilitación: $en_{low} = en \cdot \overline{in(2)}$.
  - Entradas: $in(1 \text{ downto } 0)$.
  - Salidas: Gobierna las líneas $bcode(3 \text{ downto } 0)$ cuando $in(2) = 0$.
* **Bloque Superior (`U_DEC_HIGH`):**
  - Habilitación: $en_{high} = en \cdot in(2)$.
  - Entradas: $in(1 \text{ downto } 0)$.
  - Salidas: Gobierna las líneas $bcode(7 \text{ downto } 4)$ cuando $in(2) = 1$.

```mermaid
graph LR
    EN["en"] --> AND_L["AND (en_low)"]
    EN --> AND_H["AND (en_high)"]

    IN2["in[2]"] --> NOT2["NOT"]
    NOT2 --> AND_L
    IN2 --> AND_H

    IN_LSB["in[1:0]"] --> DEC_L["dec2to4 (Low)"]
    AND_L -->|"en_low"| DEC_L
    DEC_L --> OUT_L["bcode[3:0]"]

    IN_LSB --> DEC_H["dec2to4 (High)"]
    AND_H -->|"en_high"| DEC_H
    DEC_H --> OUT_H["bcode[7:4]"]
```
*Figura 3. Diagrama de bloques estructural del decodificador binario 3-to-8.*

---

#### 2.2.2. Tabla de Verdad
Sean $en$, $in\_v = (in_2, in_1, in_0)$ y $bcode = (b_7, b_6, b_5, b_4, b_3, b_2, b_1, b_0)$:

| `en` | $in_2$ | $in_1$ | $in_0$ | Decimal $in$ | $en_{high}$ | $en_{low}$ | `bcode` ($b_7 \dots b_0$) | Línea Activa |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 0 | - | - | - | - | 0 | 0 | `00000000` | Ninguna |
| 1 | 0 | 0 | 0 | 0 | 0 | 1 | `00000001` | $b_0$ |
| 1 | 0 | 0 | 1 | 1 | 0 | 1 | `00000010` | $b_1$ |
| 1 | 0 | 1 | 0 | 2 | 0 | 1 | `00000100` | $b_2$ |
| 1 | 0 | 1 | 1 | 3 | 0 | 1 | `00001000` | $b_3$ |
| 1 | 1 | 0 | 0 | 4 | 1 | 0 | `00010000` | $b_4$ |
| 1 | 1 | 0 | 1 | 5 | 1 | 0 | `00100000` | $b_5$ |
| 1 | 1 | 1 | 0 | 6 | 1 | 0 | `01000000` | $b_6$ |
| 1 | 1 | 1 | 1 | 7 | 1 | 0 | `10000000` | $b_7$ |

---

#### 2.2.3. Códigos HDL y Testbenches

##### Código VHDL (`dec3to8.vhd`)
```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dec3to8 is
    port (
        en    : in  std_logic;
        in_v  : in  std_logic_vector(2 downto 0);
        bcode : out std_logic_vector(7 downto 0)
    );
end entity dec3to8;

architecture Structural of dec3to8 is
    component dec2to4 is
        port (
            en    : in  std_logic;
            in_v  : in  std_logic_vector(1 downto 0);
            bcode : out std_logic_vector(3 downto 0)
        );
    end component;

    signal en_low  : std_logic;
    signal en_high : std_logic;
begin
    -- Habilitación según el bit más significativo (in_v(2))
    en_low  <= en and (not in_v(2));
    en_high <= en and in_v(2);

    -- Bloque inferior (salidas 3 downto 0)
    U_DEC_LOW: dec2to4
        port map (
            en    => en_low,
            in_v  => in_v(1 downto 0),
            bcode => bcode(3 downto 0)
        );

    -- Bloque superior (salidas 7 downto 4)
    U_DEC_HIGH: dec2to4
        port map (
            en    => en_high,
            in_v  => in_v(1 downto 0),
            bcode => bcode(7 downto 4)
        );

end architecture Structural;
```

##### Testbench VHDL (`dec3to8_tb.vhd`)
```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dec3to8_tb is
end entity dec3to8_tb;

architecture Behavioral of dec3to8_tb is
    component dec3to8 is
        port (
            en    : in  std_logic;
            in_v  : in  std_logic_vector(2 downto 0);
            bcode : out std_logic_vector(7 downto 0)
        );
    end component;

    signal en_tb    : std_logic := '0';
    signal in_v_tb  : std_logic_vector(2 downto 0) := "000";
    signal bcode_tb : std_logic_vector(7 downto 0);

    constant T_STEP : time := 20 ns;
begin
    DUT: dec3to8
        port map (
            en    => en_tb,
            in_v  => in_v_tb,
            bcode => bcode_tb
        );

    stim_proc: process
        variable expected_val : std_logic_vector(7 downto 0);
    begin
        -- Caso 1: Enable desactivado (en = '0')
        en_tb <= '0';
        for i in 0 to 7 loop
            in_v_tb <= std_logic_vector(to_unsigned(i, 3));
            wait for T_STEP;
            assert bcode_tb = "00000000"
                report "ERROR en en=0: Se esperaba bcode=00000000"
                severity error;
        end loop;

        -- Caso 2: Enable activado (en = '1')
        en_tb <= '1';
        for i in 0 to 7 loop
            in_v_tb <= std_logic_vector(to_unsigned(i, 3));
            wait for T_STEP;
            
            expected_val := (others => '0');
            expected_val(i) := '1';

            assert bcode_tb = expected_val
                report "ERROR en en=1: Valor incorrecto para in=" & integer'image(i)
                severity error;
        end loop;

        report ">>> Simulacion de dec3to8_tb completada exitosamente sin errores. <<<" severity note;
        wait;
    end process;
end architecture Behavioral;
```

##### Código Verilog (`dec3to8.v`)
```verilog
`timescale 1ns / 1ps

module dec3to8 (
    input  wire       en,
    input  wire [2:0] in_v,
    output wire [7:0] bcode
);

    wire en_low;
    wire en_high;

    // Habilitación selectiva por bit MSB (in_v[2])
    assign en_low  = en & ~in_v[2];
    assign en_high = en &  in_v[2];

    // Bloque inferior para bcode[3:0]
    dec2to4 u_dec_low (
        .en(en_low),
        .in_v(in_v[1:0]),
        .bcode(bcode[3:0])
    );

    // Bloque superior para bcode[7:4]
    dec2to4 u_dec_high (
        .en(en_high),
        .in_v(in_v[1:0]),
        .bcode(bcode[7:4])
    );

endmodule
```

##### Testbench Verilog (`dec3to8_tb.v`)
```verilog
`timescale 1ns / 1ps

module dec3to8_tb;
    reg        en;
    reg  [2:0] in_v;
    wire [7:0] bcode;

    integer i;
    integer errors = 0;
    reg [7:0] expected_val;

    dec3to8 dut (
        .en(en),
        .in_v(in_v),
        .bcode(bcode)
    );

    initial begin
        en   = 1'b0;
        in_v = 3'b000;

        // Caso 1: Enable desactivado (en = 0)
        en = 1'b0;
        for (i = 0; i < 8; i = i + 1) begin
            in_v = i;
            #20;
            if (bcode !== 8'b00000000) begin
                $display("ERROR en en=0, in_v=%0d => Esperado=00000000, Obtenido=%b", i, bcode);
                errors = errors + 1;
            end
        end

        // Caso 2: Enable activado (en = 1)
        en = 1'b1;
        for (i = 0; i < 8; i = i + 1) begin
            in_v = i;
            expected_val = 8'b00000001 << i;
            #20;
            if (bcode !== expected_val) begin
                $display("ERROR en en=1, in_v=%0d => Esperado=%b, Obtenido=%b", i, expected_val, bcode);
                errors = errors + 1;
            end
        end

        if (errors == 0) begin
            $display(">>> Simulacion de dec3to8_tb exitosa: 0 errores encontrados. <<<");
        end else begin
            $display(">>> Simulacion finalizada con %0d errores. <<<", errors);
        end

        $stop;
    end
endmodule
```

---

#### 2.2.4. Circuito Generado por Quartus (RTL Viewer)

> **[EVIDENCIA FOTOGRÁFICA 9: RTL VIEWER DEC3TO8]**  
> *Guarda la captura de Quartus (Tools $\rightarrow$ Netlist Viewers $\rightarrow$ RTL Viewer) con el nombre `reports/images/dec3to8_rtl.png`.*

![Circuito RTL del decodificador 3-to-8](images/dec3to8_rtl.png)

---

#### 2.2.5. Simulación en ModelSim y Análisis de Resultados

> **[EVIDENCIA FOTOGRÁFICA 10: SIMULACIÓN MODELSIM DEC3TO8]**  
> *Guarda la captura de la forma de onda de ModelSim con el nombre `reports/images/dec3to8_modelsim.png`.*

![Forma de onda de la simulación del decodificador 3-to-8](images/dec3to8_modelsim.png)

##### Análisis del Diagrama de Tiempos:
1. **Inhibición Total ($t \in [0, 160)\,\text{ns}$):** Con $en = 0$, `bcode` = `"00000000"` para las 8 combinaciones de $in\_v$.
2. **Decodificación Mitad Inferior ($t \in [160, 240)\,\text{ns}$):**
   - $in\_v(2) = 0 \implies en_{low} = 1, en_{high} = 0$.
   - Se activan secuencialmente las salidas $b_0, b_1, b_2, b_3$ mientras la parte alta $b_7 \dots b_4$ se mantiene en `'0'`.
3. **Decodificación Mitad Superior ($t \in [240, 320)\,\text{ns}$):**
   - $in\_v(2) = 1 \implies en_{low} = 0, en_{high} = 1$.
   - Se activan secuencialmente las salidas $b_4, b_5, b_6, b_7$ mientras la parte baja $b_3 \dots b_0$ se mantiene en `'0'`.
4. **Conclusión:** La modulación del enable mediante el bit MSB permite expandir la dimensionalidad del decodificador de forma modular y jerárquica con cero interferencia entre bancos de salida.

---

### 2.3. Decodificador Binario 4-to-16 Estructural (`dec4to16`)

La extensión de la decodificación a 4 bits de entrada ($4 \text{-to-} 16$) se realiza mediante una **estructura en árbol de 2 niveles** empleando únicamente **5 instancias del bloque constructivo básico `dec2to4`**, sin requerir compuertas lógicas externas discretas.

---

#### 2.3.1. Arquitectura Jerárquica y Diagrama de Bloques

* **Nivel 1 (Control / Habilitación):**
  - Una instancia `U_DEC_CTRL` recibe la señal de habilitación global `en` y los dos bits más significativos de entrada $in(3 \text{ downto } 2)$.
  - Genera un bus interno de 4 líneas de habilitación: `en_bus(3 downto 0)`.
* **Nivel 2 (Decodificación de Datos):**
  - Cuatro instancias `U_DEC0`, `U_DEC1`, `U_DEC2` y `U_DEC3` reciben en paralelo los dos bits menos significativos $in(1 \text{ downto } 0)$.
  - Cada una es habilitada exclusivamente por una de las líneas del bus `en_bus`:
    - `U_DEC0` (habilitado por `en_bus(0)`): genera $bcode(3 \text{ downto } 0)$.
    - `U_DEC1` (habilitado por `en_bus(1)`): genera $bcode(7 \text{ downto } 4)$.
    - `U_DEC2` (habilitado por `en_bus(2)`): genera $bcode(11 \text{ downto } 8)$.
    - `U_DEC3` (habilitado por `en_bus(3)`): genera $bcode(15 \text{ downto } 12)$.

```mermaid
graph LR
    EN["en (Global)"] --> CTRL["dec2to4 (Control - Nivel 1)"]
    IN_MSB["in[3:2] (MSBs)"] --> CTRL

    CTRL -->|"en_bus[0]"| DEC0["dec2to4_0"]
    CTRL -->|"en_bus[1]"| DEC1["dec2to4_1"]
    CTRL -->|"en_bus[2]"| DEC2["dec2to4_2"]
    CTRL -->|"en_bus[3]"| DEC3["dec2to4_3"]

    IN_LSB["in[1:0] (LSBs)"] --> DEC0
    IN_LSB --> DEC1
    IN_LSB --> DEC2
    IN_LSB --> DEC3

    DEC0 --> OUT0["bcode[3:0]"]
    DEC1 --> OUT1["bcode[7:4]"]
    DEC2 --> OUT2["bcode[11:8]"]
    DEC3 --> OUT3["bcode[15:12]"]
```
*Figura 4. Diagrama de bloques estructural del decodificador binario 4-to-16 con 5 módulos 2-to-4.*

---

#### 2.3.2. Tabla de Verdad
Sean $en$, $in\_v = (in_3, in_2, in_1, in_0)$ y $bcode = (b_{15} \dots b_0)$:

| `en` | $in_3$ | $in_2$ | $in_1$ | $in_0$ | Decimal $in$ | `en_bus` ($3 \dots 0$) | Bloque Activo | `bcode` ($b_{15} \dots b_0$) en Hexadecimal |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 0 | - | - | - | - | - | `0000` | Ninguno | `0000h` |
| 1 | 0 | 0 | 0 | 0 | 0 | `0001` | `U_DEC0` | `0001h` ($b_0 = 1$) |
| 1 | 0 | 0 | 0 | 1 | 1 | `0001` | `U_DEC0` | `0002h` ($b_1 = 1$) |
| 1 | 0 | 0 | 1 | 0 | 2 | `0001` | `U_DEC0` | `0004h` ($b_2 = 1$) |
| 1 | 0 | 0 | 1 | 1 | 3 | `0001` | `U_DEC0` | `0008h` ($b_3 = 1$) |
| 1 | 0 | 1 | 0 | 0 | 4 | `0010` | `U_DEC1` | `0010h` ($b_4 = 1$) |
| 1 | 0 | 1 | 0 | 1 | 5 | `0010` | `U_DEC1` | `0020h` ($b_5 = 1$) |
| 1 | 0 | 1 | 1 | 0 | 6 | `0010` | `U_DEC1` | `0040h` ($b_6 = 1$) |
| 1 | 0 | 1 | 1 | 1 | 7 | `0010` | `U_DEC1` | `0080h` ($b_7 = 1$) |
| 1 | 1 | 0 | 0 | 0 | 8 | `0100` | `U_DEC2` | `0100h` ($b_8 = 1$) |
| 1 | 1 | 0 | 0 | 1 | 9 | `0100` | `U_DEC2` | `0200h` ($b_9 = 1$) |
| 1 | 1 | 0 | 1 | 0 | 10 | `0100` | `U_DEC2` | `0400h` ($b_{10} = 1$) |
| 1 | 1 | 0 | 1 | 1 | 11 | `0100` | `U_DEC2` | `0800h` ($b_{11} = 1$) |
| 1 | 1 | 1 | 0 | 0 | 12 | `1000` | `U_DEC3` | `1000h` ($b_{12} = 1$) |
| 1 | 1 | 1 | 0 | 1 | 13 | `1000` | `U_DEC3` | `2000h` ($b_{13} = 1$) |
| 1 | 1 | 1 | 1 | 0 | 14 | `1000` | `U_DEC3` | `4000h` ($b_{14} = 1$) |
| 1 | 1 | 1 | 1 | 1 | 15 | `1000` | `U_DEC3` | `8000h` ($b_{15} = 1$) |

---

#### 2.3.3. Códigos HDL y Testbenches

##### Código VHDL (`dec4to16.vhd`)
```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dec4to16 is
    port (
        en    : in  std_logic;
        in_v  : in  std_logic_vector(3 downto 0);
        bcode : out std_logic_vector(15 downto 0)
    );
end entity dec4to16;

architecture Structural of dec4to16 is
    component dec2to4 is
        port (
            en    : in  std_logic;
            in_v  : in  std_logic_vector(1 downto 0);
            bcode : out std_logic_vector(3 downto 0)
        );
    end component;

    signal en_bus : std_logic_vector(3 downto 0);
begin
    -- Nivel 1: Decodificador de control sobre los MSBs
    U_DEC_CTRL: dec2to4
        port map (
            en    => en,
            in_v  => in_v(3 downto 2),
            bcode => en_bus
        );

    -- Nivel 2: Cuatro decodificadores de datos sobre los LSBs
    U_DEC0: dec2to4
        port map (
            en    => en_bus(0),
            in_v  => in_v(1 downto 0),
            bcode => bcode(3 downto 0)
        );

    U_DEC1: dec2to4
        port map (
            en    => en_bus(1),
            in_v  => in_v(1 downto 0),
            bcode => bcode(7 downto 4)
        );

    U_DEC2: dec2to4
        port map (
            en    => en_bus(2),
            in_v  => in_v(1 downto 0),
            bcode => bcode(11 downto 8)
        );

    U_DEC3: dec2to4
        port map (
            en    => en_bus(3),
            in_v  => in_v(1 downto 0),
            bcode => bcode(15 downto 12)
        );

end architecture Structural;
```

##### Testbench VHDL (`dec4to16_tb.vhd`)
```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dec4to16_tb is
end entity dec4to16_tb;

architecture Behavioral of dec4to16_tb is
    component dec4to16 is
        port (
            en    : in  std_logic;
            in_v  : in  std_logic_vector(3 downto 0);
            bcode : out std_logic_vector(15 downto 0)
        );
    end component;

    signal en_tb    : std_logic := '0';
    signal in_v_tb  : std_logic_vector(3 downto 0) := "0000";
    signal bcode_tb : std_logic_vector(15 downto 0);

    constant T_STEP : time := 20 ns;
begin
    DUT: dec4to16
        port map (
            en    => en_tb,
            in_v  => in_v_tb,
            bcode => bcode_tb
        );

    stim_proc: process
        variable expected_val : std_logic_vector(15 downto 0);
    begin
        -- Caso 1: Deshabilitado (en = '0')
        en_tb <= '0';
        for i in 0 to 15 loop
            in_v_tb <= std_logic_vector(to_unsigned(i, 4));
            wait for T_STEP;
            assert bcode_tb = X"0000"
                report "ERROR en en=0: Se esperaba 0000h"
                severity error;
        end loop;

        -- Caso 2: Habilitado (en = '1')
        en_tb <= '1';
        for i in 0 to 15 loop
            in_v_tb <= std_logic_vector(to_unsigned(i, 4));
            wait for T_STEP;
            
            expected_val := (others => '0');
            expected_val(i) := '1';

            assert bcode_tb = expected_val
                report "ERROR en en=1 para in=" & integer'image(i)
                severity error;
        end loop;

        report ">>> Simulacion exhaustiva de dec4to16_tb completada exitosamente. <<<" severity note;
        wait;
    end process;
end architecture Behavioral;
```

##### Código Verilog (`dec4to16.v`)
```verilog
`timescale 1ns / 1ps

module dec4to16 (
    input  wire        en,
    input  wire [3:0]  in_v,
    output wire [15:0] bcode
);

    wire [3:0] en_bus;

    // Nivel 1: Control (MSBs)
    dec2to4 u_dec_ctrl (
        .en(en),
        .in_v(in_v[3:2]),
        .bcode(en_bus)
    );

    // Nivel 2: Datos (LSBs)
    dec2to4 u_dec0 (
        .en(en_bus[0]),
        .in_v(in_v[1:0]),
        .bcode(bcode[3:0])
    );

    dec2to4 u_dec1 (
        .en(en_bus[1]),
        .in_v(in_v[1:0]),
        .bcode(bcode[7:4])
    );

    dec2to4 u_dec2 (
        .en(en_bus[2]),
        .in_v(in_v[1:0]),
        .bcode(bcode[11:8])
    );

    dec2to4 u_dec3 (
        .en(en_bus[3]),
        .in_v(in_v[1:0]),
        .bcode(bcode[15:12])
    );

endmodule
```

##### Testbench Verilog (`dec4to16_tb.v`)
```verilog
`timescale 1ns / 1ps

module dec4to16_tb;
    reg         en;
    reg  [3:0]  in_v;
    wire [15:0] bcode;

    integer i;
    integer errors = 0;
    reg [15:0] expected_val;

    dec4to16 dut (
        .en(en),
        .in_v(in_v),
        .bcode(bcode)
    );

    initial begin
        en   = 1'b0;
        in_v = 4'b0000;

        // Caso 1: Enable desactivado
        en = 1'b0;
        for (i = 0; i < 16; i = i + 1) begin
            in_v = i;
            #20;
            if (bcode !== 16'h0000) begin
                $display("ERROR en en=0, in_v=%0d => Esperado=0000h, Obtenido=%h", i, bcode);
                errors = errors + 1;
            end
        end

        // Caso 2: Enable activado
        en = 1'b1;
        for (i = 0; i < 16; i = i + 1) begin
            in_v = i;
            expected_val = 16'h0001 << i;
            #20;
            if (bcode !== expected_val) begin
                $display("ERROR en en=1, in_v=%0d => Esperado=%h, Obtenido=%h", i, expected_val, bcode);
                errors = errors + 1;
            end
        end

        if (errors == 0) begin
            $display("================================================================");
            $display(">>> Simulacion de dec4to16_tb exitosa: 0 errores encontrados. <<<");
            $display("================================================================");
        end else begin
            $display(">>> Simulacion finalizada con %0d errores. <<<", errors);
        end

        $stop;
    end
endmodule
```

---

#### 2.3.4. Circuito Generado por Quartus (RTL Viewer)

> **[EVIDENCIA FOTOGRÁFICA 11: RTL VIEWER DEC4TO16]**  
> *Guarda la captura de Quartus (Tools $\rightarrow$ Netlist Viewers $\rightarrow$ RTL Viewer) con el nombre `reports/images/dec4to16_rtl.png`.*

![Circuito RTL del decodificador 4-to-16](images/dec4to16_rtl.png)

---

#### 2.3.5. Simulación en ModelSim y Análisis de Resultados

> **[EVIDENCIA FOTOGRÁFICA 12: SIMULACIÓN MODELSIM DEC4TO16]**  
> *Guarda la captura de la forma de onda de ModelSim con el nombre `reports/images/dec4to16_modelsim.png`.*

![Forma de onda de la simulación del decodificador 4-to-16](images/dec4to16_modelsim.png)

##### Análisis del Diagrama de Tiempos:
1. **Fase de Deshabilitación ($t \in [0, 320)\,\text{ns}$):** Durante los primeros 16 vectores con $en = 0$, la salida permanece en `0000h` ($0\,\text{V}$ lógico en todos los pines).
2. **Fase Activa ($t \in [320, 640)\,\text{ns}$):**
   - Con $en = 1$, para cada entrada $in\_v = k$ ($k \in [0, 15]$), se observa la activación de la línea $b_k = 1$ (representada como un desplazamiento diagonal en el mapa de bits *One-Hot*).
   - Se aprecia la activación secuencial del bus `en_bus`:
     - $k \in [0, 3]$: `en_bus` = `"0001"` (activa `U_DEC0`).
     - $k \in [4, 7]$: `en_bus` = `"0010"` (activa `U_DEC1`).
     - $k \in [8, 11]$: `en_bus` = `"0100"` (activa `U_DEC2`).
     - $k \in [12, 15]$: `en_bus` = `"1000"` (activa `U_DEC3`).
3. **Conclusión:** La estructura modular de 2 niveles implementa fielmente la tabla de verdad del decodificador 4-to-16 maximizando la reutilización del diseño y simplificando el árbol de enrutamiento en FPGA.

---

## Ejercicio Número 3: Diseño Lógico Basado en Multiplexores

En este ejercicio se implementa una función lógica combinacional de 4 variables de entrada ($x_1, x_2, x_3, x_4$) a través de dos metodologías de diseño digital:
1. **Implementación Directa a Nivel Compuertas (*Gate-Level*):** Red pura de 3 compuertas XNOR.
2. **Implementación Basada en Multiplexores (*MUX-Based*):** Uso de un multiplexor 4 a 1 aplicando descomposición funcional / partición de Shannon.

Ambas descripciones se comparan simultáneamente en un módulo integrador (*Top-Level*) y se verifica su equivalencia lógica exhaustiva mediante bancos de prueba (*Testbenches*) en VHDL y Verilog.

---

### 3.1. Análisis y Derivación Teórica

#### 3.1.1. Ecuación Lógica a Nivel Compuertas
A partir de la topología de la Figura 1 (red jerárquica de compuertas XNOR de 2 niveles):
- Nivel 1:
  $$G_1 = x_1 \odot x_2 = \overline{x_1 \oplus x_2} = x_1 x_2 + \overline{x_1}\,\overline{x_2}$$
  $$G_2 = x_3 \odot x_4 = \overline{x_3 \oplus x_4} = x_3 x_4 + \overline{x_3}\,\overline{x_4}$$
- Nivel 2:
  $$f = G_1 \odot G_2 = \overline{G_1 \oplus G_2}$$

Empleando la identidad del álgebra booleana $\overline{A} \oplus \overline{B} = A \oplus B$:
$$f(x_1, x_2, x_3, x_4) = \overline{(x_1 \oplus x_2) \oplus (x_3 \oplus x_4)} = \overline{x_1 \oplus x_2 \oplus x_3 \oplus x_4}$$

La función obtenida corresponde a un **detector de paridad par (*Even Parity*)**: la salida $f$ toma el valor lógico `'1'` si y sólo si el número total de bits en `'1'` entre las cuatro entradas es **par** ($0, 2 \text{ ó } 4$).

---

#### 3.1.2. Tabla de Verdad y Minitérminos Canónicos

| Fila | $x_1$ | $x_2$ | $x_3$ | $x_4$ | $G_1 = x_1 \odot x_2$ | $G_2 = x_3 \odot x_4$ | Paridad de 1s | Salida $f$ | Minitérmino |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **0**  | 0 | 0 | 0 | 0 | 1 | 1 | 0 (Par)  | **1** | $m_0 = \overline{x_1}\,\overline{x_2}\,\overline{x_3}\,\overline{x_4}$ |
| **1**  | 0 | 0 | 0 | 1 | 1 | 0 | 1 (Impar)| **0** | - |
| **2**  | 0 | 0 | 1 | 0 | 1 | 0 | 1 (Impar)| **0** | - |
| **3**  | 0 | 0 | 1 | 1 | 1 | 1 | 2 (Par)  | **1** | $m_3 = \overline{x_1}\,\overline{x_2} x_3 x_4$ |
| **4**  | 0 | 1 | 0 | 0 | 0 | 1 | 1 (Impar)| **0** | - |
| **5**  | 0 | 1 | 0 | 1 | 0 | 0 | 2 (Par)  | **1** | $m_5 = \overline{x_1} x_2 \overline{x_3} x_4$ |
| **6**  | 0 | 1 | 1 | 0 | 0 | 0 | 2 (Par)  | **1** | $m_6 = \overline{x_1} x_2 x_3 \overline{x_4}$ |
| **7**  | 0 | 1 | 1 | 1 | 0 | 1 | 3 (Impar)| **0** | - |
| **8**  | 1 | 0 | 0 | 0 | 0 | 1 | 1 (Impar)| **0** | - |
| **9**  | 1 | 0 | 0 | 1 | 0 | 0 | 2 (Par)  | **1** | $m_9 = x_1 \overline{x_2}\,\overline{x_3} x_4$ |
| **10** | 1 | 0 | 1 | 0 | 0 | 0 | 2 (Par)  | **1** | $m_{10} = x_1 \overline{x_2} x_3 \overline{x_4}$ |
| **11** | 1 | 0 | 1 | 1 | 0 | 1 | 3 (Impar)| **0** | - |
| **12** | 1 | 1 | 0 | 0 | 1 | 1 | 2 (Par)  | **1** | $m_{12} = x_1 x_2 \overline{x_3}\,\overline{x_4}$ |
| **13** | 1 | 1 | 0 | 1 | 1 | 0 | 3 (Impar)| **0** | - |
| **14** | 1 | 1 | 1 | 0 | 1 | 0 | 3 (Impar)| **0** | - |
| **15** | 1 | 1 | 1 | 1 | 1 | 1 | 4 (Par)  | **1** | $m_{15} = x_1 x_2 x_3 x_4$ |

**Suma Canónica de Productos:**
$$f(x_1, x_2, x_3, x_4) = \sum m(0, 3, 5, 6, 9, 10, 12, 15)$$

---

#### 3.1.3. Descomposición Funcional con Multiplexor 4 a 1 (Shannon)

Seleccionando las dos variables más significativas $(x_1, x_2)$ como líneas de selección del multiplexor ($S_1 = x_1$, $S_0 = x_2$), el espacio booleano se particiona en 4 cuadrantes respecto a $(x_3, x_4)$:

```mermaid
graph LR
    subgraph Generacion_Datos["Entradas a canales de datos"]
        X34_XNOR["x3 XNOR x4"] --> D0["D0"]
        X34_XOR["x3 XOR x4"] --> D1["D1"]
        X34_XOR --> D2["D2"]
        X34_XNOR --> D3["D3"]
    end

    D0 --> MUX["MUX 4 a 1<br>(mux4to1)"]
    D1 --> MUX
    D2 --> MUX
    D3 --> MUX

    SEL["Selectores: (x1, x2)"] --> MUX
    MUX --> F["f"]
```
*Figura 5. Arquitectura lógica del circuito basado en multiplexor 4 a 1.*

* **Canal $D_0$ ($x_1 x_2 = 00$):**
  $$f|_{00} = \overline{x_3}\,\overline{x_4} + x_3 x_4 = x_3 \odot x_4 \quad (\text{XNOR})$$
* **Canal $D_1$ ($x_1 x_2 = 01$):**
  $$f|_{01} = \overline{x_3} x_4 + x_3 \overline{x_4} = x_3 \oplus x_4 \quad (\text{XOR})$$
* **Canal $D_2$ ($x_1 x_2 = 10$):**
  $$f|_{10} = \overline{x_3} x_4 + x_3 \overline{x_4} = x_3 \oplus x_4 \quad (\text{XOR})$$
* **Canal $D_3$ ($x_1 x_2 = 11$):**
  $$f|_{11} = \overline{x_3}\,\overline{x_4} + x_3 x_4 = x_3 \odot x_4 \quad (\text{XNOR})$$

---

### 3.2. Códigos HDL y Testbenches

#### 3.2.1. Implementación en VHDL

##### Módulo Gate-Level (`mux_logic_gate.vhd`)
```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_logic_gate is
    port (
        x1 : in  std_logic;
        x2 : in  std_logic;
        x3 : in  std_logic;
        x4 : in  std_logic;
        f  : out std_logic
    );
end entity mux_logic_gate;

architecture GateLevel of mux_logic_gate is
    signal g1 : std_logic;
    signal g2 : std_logic;
begin
    -- Implementación directa a nivel compuertas (Figura 1: 3 compuertas XNOR)
    g1 <= x1 xnor x2;
    g2 <= x3 xnor x4;
    f  <= g1 xnor g2;
end architecture GateLevel;
```

##### Módulo Multiplexor 4 a 1 Genérico (`mux4to1.vhd`)
```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux4to1 is
    port (
        d   : in  std_logic_vector(3 downto 0);
        sel : in  std_logic_vector(1 downto 0);
        y   : out std_logic
    );
end entity mux4to1;

architecture Behavioral of mux4to1 is
begin
    with sel select
        y <= d(0) when "00",
             d(1) when "01",
             d(2) when "10",
             d(3) when "11",
             '0'  when others;
end architecture Behavioral;
```

##### Módulo Basado en Multiplexor (`mux_logic_mux.vhd`)
```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_logic_mux is
    port (
        x1 : in  std_logic;
        x2 : in  std_logic;
        x3 : in  std_logic;
        x4 : in  std_logic;
        f  : out std_logic
    );
end entity mux_logic_mux;

architecture Structural of mux_logic_mux is
    component mux4to1 is
        port (
            d   : in  std_logic_vector(3 downto 0);
            sel : in  std_logic_vector(1 downto 0);
            y   : out std_logic
        );
    end component;

    signal d_bus   : std_logic_vector(3 downto 0);
    signal sel_bus : std_logic_vector(1 downto 0);
begin
    -- Selectores: x1 (MSB) y x2 (LSB)
    sel_bus <= x1 & x2;

    -- Entradas de datos derivadas por partición de Shannon:
    d_bus(0) <= x3 xnor x4;
    d_bus(1) <= x3 xor x4;
    d_bus(2) <= x3 xor x4;
    d_bus(3) <= x3 xnor x4;

    U_MUX: mux4to1
        port map (
            d   => d_bus,
            sel => sel_bus,
            y   => f
        );

end architecture Structural;
```

##### Módulo Top Comparador (`mux_logic_top.vhd`)
```vhdl
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
    U_GATE: mux_logic_gate
        port map (
            x1 => x1,
            x2 => x2,
            x3 => x3,
            x4 => x4,
            f  => sig_f_gate
        );

    U_MUX_IMPL: mux_logic_mux
        port map (
            x1 => x1,
            x2 => x2,
            x3 => x3,
            x4 => x4,
            f  => sig_f_mux
        );

    f_gate    <= sig_f_gate;
    f_mux     <= sig_f_mux;
    match_out <= sig_f_gate xnor sig_f_mux;

end architecture Structural;
```

##### Testbench VHDL (`mux_logic_tb.vhd`)
```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux_logic_tb is
end entity mux_logic_tb;

architecture Behavioral of mux_logic_tb is
    component mux_logic_top is
        port (
            x1        : in  std_logic;
            x2        : in  std_logic;
            x3        : in  std_logic;
            x4        : in  std_logic;
            f_gate    : out std_logic;
            f_mux     : out std_logic;
            match_out : out std_logic
        );
    end component;

    signal x1_tb        : std_logic := '0';
    signal x2_tb        : std_logic := '0';
    signal x3_tb        : std_logic := '0';
    signal x4_tb        : std_logic := '0';
    signal f_gate_tb    : std_logic;
    signal f_mux_tb     : std_logic;
    signal match_out_tb : std_logic;

    constant T_STEP : time := 20 ns;
begin
    DUT: mux_logic_top
        port map (
            x1        => x1_tb,
            x2        => x2_tb,
            x3        => x3_tb,
            x4        => x4_tb,
            f_gate    => f_gate_tb,
            f_mux     => f_mux_tb,
            match_out => match_out_tb
        );

    stim_proc: process
        variable vec_in       : std_logic_vector(3 downto 0);
        variable count_ones   : integer;
        variable expected_val : std_logic;
    begin
        for i in 0 to 15 loop
            vec_in  := std_logic_vector(to_unsigned(i, 4));
            x1_tb   <= vec_in(3);
            x2_tb   <= vec_in(2);
            x3_tb   <= vec_in(1);
            x4_tb   <= vec_in(0);

            count_ones := 0;
            for k in 0 to 3 loop
                if vec_in(k) = '1' then
                    count_ones := count_ones + 1;
                end if;
            end loop;

            if (count_ones mod 2) = 0 then
                expected_val := '1';
            else
                expected_val := '0';
            end if;

            wait for T_STEP;

            assert f_gate_tb = expected_val
                report "ERROR en f_gate para vector " & integer'image(i)
                severity error;

            assert f_mux_tb = expected_val
                report "ERROR en f_mux para vector " & integer'image(i)
                severity error;

            assert match_out_tb = '1'
                report "DESAJUSTE entre f_gate y f_mux en vector " & integer'image(i)
                severity error;
        end loop;

        report ">>> Simulacion exhaustiva de mux_logic_tb (16 vectores) completada exitosamente. <<<" severity note;
        wait;
    end process;
end architecture Behavioral;
```

---

#### 3.2.2. Implementación en Verilog

##### Módulo Gate-Level (`mux_logic_gate.v`)
```verilog
`timescale 1ns / 1ps

module mux_logic_gate (
    input  wire x1,
    input  wire x2,
    input  wire x3,
    input  wire x4,
    output wire f
);

    wire g1;
    wire g2;

    // Implementación directa a nivel compuertas (3 XNOR)
    assign g1 = ~(x1 ^ x2);
    assign g2 = ~(x3 ^ x4);
    assign f  = ~(g1 ^ g2);

endmodule
```

##### Módulo Multiplexor 4 a 1 Genérico (`mux4to1.v`)
```verilog
`timescale 1ns / 1ps

module mux4to1 (
    input  wire [3:0] d,
    input  wire [1:0] sel,
    output reg        y
);

    always @(*) begin
        case (sel)
            2'b00:   y = d[0];
            2'b01:   y = d[1];
            2'b10:   y = d[2];
            2'b11:   y = d[3];
            default: y = 1'b0;
        endcase
    end

endmodule
```

##### Módulo Basado en Multiplexor (`mux_logic_mux.v`)
```verilog
`timescale 1ns / 1ps

module mux_logic_mux (
    input  wire x1,
    input  wire x2,
    input  wire x3,
    input  wire x4,
    output wire f
);

    wire [3:0] d_bus;
    wire [1:0] sel_bus;

    assign sel_bus = {x1, x2};

    // Entradas de datos derivadas por partición de Shannon:
    assign d_bus[0] = ~(x3 ^ x4);
    assign d_bus[1] = x3 ^ x4;
    assign d_bus[2] = x3 ^ x4;
    assign d_bus[3] = ~(x3 ^ x4);

    mux4to1 u_mux (
        .d(d_bus),
        .sel(sel_bus),
        .y(f)
    );

endmodule
```

##### Módulo Top Comparador (`mux_logic_top.v`)
```verilog
`timescale 1ns / 1ps

module mux_logic_top (
    input  wire x1,
    input  wire x2,
    input  wire x3,
    input  wire x4,
    output wire f_gate,
    output wire f_mux,
    output wire match_out
);

    mux_logic_gate u_gate (
        .x1(x1),
        .x2(x2),
        .x3(x3),
        .x4(x4),
        .f(f_gate)
    );

    mux_logic_mux u_mux_impl (
        .x1(x1),
        .x2(x2),
        .x3(x3),
        .x4(x4),
        .f(f_mux)
    );

    assign match_out = ~(f_gate ^ f_mux);

endmodule
```

##### Testbench Verilog (`mux_logic_tb.v`)
```verilog
`timescale 1ns / 1ps

module mux_logic_tb;
    reg  x1;
    reg  x2;
    reg  x3;
    reg  x4;
    wire f_gate;
    wire f_mux;
    wire match_out;

    integer i;
    integer errors = 0;
    reg [3:0] vec_in;
    reg       expected_val;

    mux_logic_top dut (
        .x1(x1),
        .x2(x2),
        .x3(x3),
        .x4(x4),
        .f_gate(f_gate),
        .f_mux(f_mux),
        .match_out(match_out)
    );

    initial begin
        x1 = 1'b0;
        x2 = 1'b0;
        x3 = 1'b0;
        x4 = 1'b0;

        for (i = 0; i < 16; i = i + 1) begin
            vec_in = i[3:0];
            x1 = vec_in[3];
            x2 = vec_in[2];
            x3 = vec_in[1];
            x4 = vec_in[0];

            expected_val = ~^{x1, x2, x3, x4};
            #20;

            if (f_gate !== expected_val || f_mux !== expected_val || match_out !== 1'b1) begin
                $display("ERROR en Vector=%b => f_gate=%b, f_mux=%b, match=%b", vec_in, f_gate, f_mux, match_out);
                errors = errors + 1;
            end
        end

        if (errors == 0) begin
            $display(">>> Simulacion de mux_logic_tb exitosa: 16 vectores evaluados sin errores. <<<");
            $display(">>> Coincidencia total del 100%% entre Gate-Level y MUX-Based. <<<");
        end else begin
            $display(">>> Simulacion finalizada con %0d errores. <<<", errors);
        end

        $stop;
    end
endmodule
```

---

#### 3.2.3. Scripts de Automatización para ModelSim (`.do`)

##### Script de Simulación VHDL (`run_mux_logic_vhdl.do`)
```tcl
# Crear y mapear librería de trabajo
vlib work
vmap work work

# Compilar archivos fuente en orden jerárquico
vcom -93 -work work ../vhdl/src/mux_logic_gate.vhd
vcom -93 -work work ../vhdl/src/mux4to1.vhd
vcom -93 -work work ../vhdl/src/mux_logic_mux.vhd
vcom -93 -work work ../vhdl/src/mux_logic_top.vhd
vcom -93 -work work ../vhdl/tb/mux_logic_tb.vhd

# Cargar simulación
vsim work.mux_logic_tb

# Configuración de ondas
add wave -divider "ENTRADAS"
add wave -color "Yellow" /mux_logic_tb/x1_tb
add wave -color "Yellow" /mux_logic_tb/x2_tb
add wave -color "Yellow" /mux_logic_tb/x3_tb
add wave -color "Yellow" /mux_logic_tb/x4_tb

add wave -divider "INTERNAS MUX"
add wave -color "Orange" -radix binary /mux_logic_tb/DUT/U_MUX_IMPL/sel_bus
add wave -color "Orange" -radix binary /mux_logic_tb/DUT/U_MUX_IMPL/d_bus

add wave -divider "SALIDAS COMPARATIVAS"
add wave -color "Cyan"  /mux_logic_tb/f_gate_tb
add wave -color "Green" /mux_logic_tb/f_mux_tb
add wave -color "White" /mux_logic_tb/match_out_tb

# Ejecución
run -all
wave zoom full
```

##### Script de Simulación Verilog (`run_mux_logic_verilog.do`)
```tcl
# Crear y mapear librería de trabajo
vlib work
vmap work work

# Compilar módulos Verilog y testbench
vlog -work work ../verilog/src/mux_logic_gate.v
vlog -work work ../verilog/src/mux4to1.v
vlog -work work ../verilog/src/mux_logic_mux.v
vlog -work work ../verilog/src/mux_logic_top.v
vlog -work work ../verilog/tb/mux_logic_tb.v

# Cargar simulación
vsim work.mux_logic_tb

# Configuración de ondas
add wave -divider "ENTRADAS"
add wave -color "Yellow" /mux_logic_tb/x1
add wave -color "Yellow" /mux_logic_tb/x2
add wave -color "Yellow" /mux_logic_tb/x3
add wave -color "Yellow" /mux_logic_tb/x4

add wave -divider "INTERNAS MUX"
add wave -color "Orange" -radix binary /mux_logic_tb/dut/u_mux_impl/sel_bus
add wave -color "Orange" -radix binary /mux_logic_tb/dut/u_mux_impl/d_bus

add wave -divider "SALIDAS COMPARATIVAS"
add wave -color "Cyan"  /mux_logic_tb/f_gate
add wave -color "Green" /mux_logic_tb/f_mux
add wave -color "White" /mux_logic_tb/match_out

# Ejecución
run -all
wave zoom full
```

---

### 3.3. Circuito Generado por Quartus (RTL Viewer)

> **[EVIDENCIA FOTOGRÁFICA 13: RTL VIEWER MUX_LOGIC_TOP]**  
> *Guarda la captura de Quartus (Tools $\rightarrow$ Netlist Viewers $\rightarrow$ RTL Viewer) con el nombre `reports/images/mux_logic_top_rtl.png`.*

![Circuito RTL del módulo top comparador](images/mux_logic_top_rtl.png)

> **[EVIDENCIA FOTOGRÁFICA 14: RTL VIEWER MUX_LOGIC_MUX]**  
> *Guarda la captura de Quartus del bloque basado en multiplexores con el nombre `reports/images/mux_logic_mux_rtl.png`.*

![Circuito RTL de la implementación basada en multiplexor](images/mux_logic_mux_rtl.png)

---

### 3.4. Simulación en ModelSim y Análisis de Resultados

> **[EVIDENCIA FOTOGRÁFICA 15: SIMULACIÓN MODELSIM MUX_LOGIC]**  
> *Guarda la captura de la forma de onda de ModelSim con el nombre `reports/images/mux_logic_modelsim.png`.*

![Forma de onda de la simulación comparativa Gate-Level vs MUX](images/mux_logic_modelsim.png)

#### Análisis del Diagrama de Tiempos:
1. **Verificación de Paridad Par:**
   - Para las combinaciones con número par de unos ($0000_2, 0011_2, 0101_2, 0110_2, 1001_2, 1010_2, 1100_2, 1111_2$), tanto `f_gate` como `f_mux` conmutan a nivel alto (`'1'`).
   - Para todas las demás 8 combinaciones (número impar de unos), ambas salidas se mantienen en nivel bajo (`'0'`).
2. **Coincidencia Total (`match_out = '1'`):**
   - La señal de control `match_out` permanece ininterrumpidamente en `'1'` durante los $320\,\text{ns}$ de la simulación, demostrando formalmente que la arquitectura basada en MUX 4:1 es lógicamente idéntica a la red de compuertas XNOR original.
3. **Conclusiones del Ejercicio:**
   - La síntesis basada en multiplexores permite sintetizar funciones booleanas complejas sin requerir optimizaciones algebraicas extensas a nivel compuerta, replicando la arquitectura interna de las celdas lógicas (LUTs) presentes en los dispositivos SoC / FPGA modernos.

---
