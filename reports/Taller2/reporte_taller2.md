# Taller de Diseño: Circuitos Combinacionales a Nivel RTL
**Pontificia Universidad Javeriana**  
**Departamento de Electrónica**  
**System on Chip (SoC)**  

---

## Ejercicio Número 1: Encoders – Decoders (Código Gray)

Un circuito codificador de código Gray (*Gray Code*) convierte una palabra binaria estándar en una codificación donde dos valores numéricos consecutivos difieren únicamente en un solo bit ($distancia\ de\ Hamming = 1$). Esta propiedad elimina estados transitorios no deseados (*glitches*) en transiciones entre estados discretos.

---

### 1.1. Aplicaciones del Código Gray en Ingeniería

1. **Sistemas de Medición y Encoders Ópticos / Mecánicos de Posición:**
   - En encoders angulares de eje rotativo (*rotary encoders*), si se utilizara binario natural, al pasar de un valor como $3$ (`011`) a $4$ (`100`) los tres bits deberían cambiar simultáneamente. Dado que los sensores físicos nunca leen las ranuras al mismo instante infinitesimal, se generarían lecturas erróneas intermedias (como `000`, `111`, `110`). Con el código Gray, al cambiar un único bit por transición, nunca se presentan transiciones intermedias espurias.
2. **Sistemas Asíncronos de Comunicación y FIFOs (Clock Domain Crossing - CDC):**
   - En memorias FIFO de doble reloj, los punteros de lectura y escritura deben cruzar de un dominio de reloj a otro. Si se envían punteros en binario natural, el cambio multubit simultáneo puede causar metaestabilidad y lecturas catastróficas de valores aleatorios. Al codificar los punteros en código Gray y sincronizarlos con biestables en cascada, solo un bit cambia a la vez, garantizando integridad y seguridad en la sincronización.

---

### 1.2. Tabla de Verdad y Ecuaciones Booleanas

#### 1.2.1. Tabla de Verdad (4 Bits)

| Decimal | Binario ($B_3 B_2 B_1 B_0$) | Gray ($G_3 G_2 G_1 G_0$) | Ecuación / Expresión |
| :---: | :---: | :---: | :---: |
| **0**  | 0000 | 0000 | - |
| **1**  | 0001 | 0001 | - |
| **2**  | 0010 | 0011 | - |
| **3**  | 0011 | 0010 | - |
| **4**  | 0100 | 0110 | - |
| **5**  | 0101 | 0111 | - |
| **6**  | 0110 | 0101 | - |
| **7**  | 0111 | 0100 | - |
| **8**  | 1000 | 1100 | - |
| **9**  | 1001 | 1101 | - |
| **10** | 1010 | 1111 | - |
| **11** | 1011 | 1110 | - |
| **12** | 1100 | 1010 | - |
| **13** | 1101 | 1011 | - |
| **14** | 1110 | 1001 | - |
| **15** | 1111 | 1000 | - |

#### 1.2.2. Ecuaciones Lógicas Derivadas
Analizando la relación entre cada bit de salida $G_k$ y los bits de entrada $B$:
- $$G_3 = B_3$$
- $$G_2 = B_3 \oplus B_2$$
- $$G_1 = B_2 \oplus B_1$$
- $$G_0 = B_1 \oplus B_0$$

En forma general para $N$ bits:
$$G_{N-1} = B_{N-1}$$
$$G_i = B_{i+1} \oplus B_i \quad \forall\ 0 \le i < N-1$$

---

### 1.3. Códigos HDL y Testbenches

#### 1.3.1. Implementación en VHDL (`gray_encoder.vhd`)
*(Espacio reservado para el código HDL)*

#### 1.3.2. Testbench VHDL (`gray_encoder_tb.vhd`)
*(Espacio reservado para el testbench)*

#### 1.3.3. Implementación en Verilog (`gray_encoder.v`)
*(Espacio reservado para el código Verilog)*

#### 1.3.4. Testbench Verilog (`gray_encoder_tb.v`)
*(Espacio reservado para el testbench)*

---

### 1.4. Circuito Generado por Quartus (RTL Viewer)

> **[EVIDENCIA FOTOGRÁFICA 1: RTL VIEWER GRAY ENCODER]**  
> *Guarda la captura de Quartus (Tools $\rightarrow$ Netlist Viewers $\rightarrow$ RTL Viewer) con el nombre `images/gray_encoder_rtl.png`.*

![Circuito RTL del codificador binario a Gray](images/gray_encoder_rtl.png)

---

### 1.5. Simulación en ModelSim y Análisis de Resultados

> **[EVIDENCIA FOTOGRÁFICA 2: SIMULACIÓN MODELSIM GRAY ENCODER]**  
> *Guarda la captura de la forma de onda de ModelSim con el nombre `images/gray_encoder_modelsim.png`.*

![Forma de onda de la simulación del codificador Gray](images/gray_encoder_modelsim.png)

---

## Ejercicio Número 2: Barrel Shifter

Un circuito *Barrel Shifter* realiza desplazamientos combinacionales de palabras binarias en un solo ciclo de propagación de compuertas (sin depender de ciclos de reloj como los registros de desplazamiento secuenciales).

---

### 2.1. Barrel Shifter de 1 Bit de Desplazamiento

#### 2.1.1. Análisis y Ecuaciones
- **Entradas:** `inp(7 downto 0)`, `shift` (1 bit).
- **Salida:** `outp(7 downto 0)`.
- Si `shift = '0'`: $\text{outp} = \text{inp}$.
- Si `shift = '1'`: $\text{outp}(0) = \text{'0'}$, $\text{outp}(i) = \text{inp}(i-1)$ para $1 \le i \le 7$.

#### 2.1.2. Códigos HDL
*(Espacio reservado para implementación y testbench)*

#### 2.1.3. Circuito Generado por Quartus (RTL Viewer)
> **[EVIDENCIA FOTOGRÁFICA 3: RTL VIEWER BARREL SHIFTER 1-BIT]**  
> *Guarda la captura con el nombre `images/barrel_shifter_1bit_rtl.png`.*

![Circuito RTL del barrel shifter de 1 bit](images/barrel_shifter_1bit_rtl.png)

#### 2.1.4. Simulación en ModelSim
> **[EVIDENCIA FOTOGRÁFICA 4: SIMULACIÓN MODELSIM BARREL SHIFTER 1-BIT]**  
> *Guarda la captura con el nombre `images/barrel_shifter_1bit_modelsim.png`.*

![Simulación del barrel shifter de 1 bit](images/barrel_shifter_1bit_modelsim.png)

---

### 2.2. Barrel Shifter Multietapa de 0 a 7 Bits (8 Bits de Datos)

#### 2.2.1. Arquitectura en Cascada
Compuesto por 3 etapas secuenciales de multiplexores 2 a 1:
1. **Etapa 0 (controlada por `shift(0)`):** Desplaza 0 o 1 posición.
2. **Etapa 1 (controlada por `shift(1)`):** Desplaza 0 o 2 posiciones.
3. **Etapa 2 (controlada por `shift(2)`):** Desplaza 0 o 4 posiciones.

Cualquier desplazamiento entero de $0$ a $7$ ($2^3 - 1$) se sintetiza como suma de potencias de 2:
$$\text{Desplazamiento} = \text{shift}(0) \cdot 1 + \text{shift}(1) \cdot 2 + \text{shift}(2) \cdot 4$$

#### 2.2.2. Códigos HDL y Testbenches
*(Espacio reservado para implementación estructural y testbench exhaustivo de 0 a 7)*

#### 2.2.3. Circuito Generado por Quartus (RTL Viewer)
> **[EVIDENCIA FOTOGRÁFICA 5: RTL VIEWER BARREL SHIFTER 8-BIT]**  
> *Guarda la captura con el nombre `images/barrel_shifter_8bit_rtl.png`.*

![Circuito RTL del barrel shifter de 8 bits](images/barrel_shifter_8bit_rtl.png)

#### 2.2.4. Simulación en ModelSim
> **[EVIDENCIA FOTOGRÁFICA 6: SIMULACIÓN MODELSIM BARREL SHIFTER 8-BIT]**  
> *Guarda la captura con el nombre `images/barrel_shifter_8bit_modelsim.png`.*

![Simulación del barrel shifter de 8 bits](images/barrel_shifter_8bit_modelsim.png)

---

## Ejercicio Número 3: Comparador Signed - Unsigned

El módulo comparador evalúa la magnitud de dos palabras de 4 bits $a$ y $b$, interpretándolas como enteros sin signo o enteros con signo en complemento a dos según la señal de control `sig`.

---

### 3.1. Fundamentos Teóricos

- **Modo Unsigned (`sig = '0'`):**
  - Rango: $0 \le a, b \le 15$.
  - La comparación sigue el orden numérico binario estándar.
- **Modo Signed (`sig = '1'`):**
  - Rango: $-8 \le a, b \le +7$.
  - El bit más significativo ($a_3, b_3$) es el bit de signo ($1 \implies$ negativo, $0 \implies$ positivo).
  - Si los signos difieren: el operando con bit de signo `0` es estrictamente mayor que el operando con bit de signo `1`.
  - Si los signos son iguales: la comparación de magnitud de los bits restantes determina el resultado.

---

### 3.2. Códigos HDL y Testbenches
*(Espacio reservado para implementación concurrente y testbench exhaustivo)*

---

### 3.3. Circuito Generado por Quartus (RTL Viewer)
> **[EVIDENCIA FOTOGRÁFICA 7: RTL VIEWER COMPARADOR SIGNED/UNSIGNED]**  
> *Guarda la captura con el nombre `images/comparator_signed_rtl.png`.*

![Circuito RTL del comparador signed/unsigned](images/comparator_signed_rtl.png)

---

### 3.4. Simulación en ModelSim y Análisis de Resultados
> **[EVIDENCIA FOTOGRÁFICA 8: SIMULACIÓN MODELSIM COMPARADOR SIGNED/UNSIGNED]**  
> *Guarda la captura con el nombre `images/comparator_signed_modelsim.png`.*

![Simulación del comparador signed/unsigned](images/comparator_signed_modelsim.png)
