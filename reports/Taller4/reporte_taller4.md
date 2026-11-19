# Taller 4: Circuitos Secuenciales — Contadores
**Pontificia Universidad Javeriana**  
**Departamento de Electrónica**  
**System on Chip (SoC)**  

---

## Ejercicio Número 1: Contador Binario Universal (`univ_bin_counter`)

### 1.1. Descripción General del Diseño

El **Contador Binario Universal** (`univ_bin_counter`) es un circuito secuencial síncrono parametrizable de $N$ bits capaz de operar en modo ascendente o descendente con límite superior configurable `MAX_COUNT`, carga paralela síncrona, reinicio síncrono, habilitación de conteo (*pause/resume*), reset asíncrono de inicialización y generación de banderas de estado (`max_tick` y `min_tick`).

#### 1.1.1. Jerarquía de Prioridades y Tabla de Operación
El registro de estado interno `count_reg` se actualiza en el flanco ascendente de `clk` (o asíncronamente ante `rst = '1'`). La lógica de estado siguiente (`count_next`) sigue la jerarquía de control estándar:

| Prioridad | Señal Activa | Tipo | Condición | Acción sobre `counter` (`count_next`) |
| :---: | :---: | :---: | :---: | :--- |
| **1 (Máxima)** | `rst` | Asíncrono | `rst = '1'` | Inicializa inmediatamente el registro a `0` (`(others => '0')`) sin esperar a `clk`. |
| **2** | `syn_clr` | Síncrono | `syn_clr = '1'` | Reinicia el contador a `0` en el flanco de subida de `clk`. |
| **3** | `load` | Síncrono | `load = '1'` | Carga en paralelo el valor de entrada `d[N-1:0]` durante un ciclo de reloj. |
| **4** | `ena` y `up` | Síncrono | `ena = '1'`, `up = '1'` | **Conteo ascendente:** Si `count_reg = MAX_COUNT`, envuelve a `0`; de lo contrario, `count_reg + 1`. |
| **5** | `ena` y `up` | Síncrono | `ena = '1'`, `up = '0'` | **Conteo descendente:** Si `count_reg = 0`, envuelve a `MAX_COUNT`; de lo contrario, `count_reg - 1`. |
| **6 (Mínima)** | `ena` | Síncrono | `ena = '0'` | **Pausa:** Mantiene el estado actual (`count_next = count_reg`). |

#### 1.1.2. Lógica de Banderas de Fin de Conteo (`max_tick` y `min_tick`)
- **`max_tick`**: Se activa en `'1'` de forma combinacional cuando el estado actual del contador alcanza el valor máximo parametrizado (`count_reg = MAX_COUNT`).
- **`min_tick`**: Se activa en `'1'` de forma combinacional cuando el estado actual del contador se encuentra en cero (`count_reg = 0`).

---

### 1.2. Implementación en VHDL (`univ_bin_counter.vhd` y `univ_bin_counter_tb.vhd`)

*(Pendiente de inserción al desarrollar los archivos fuente del Ejercicio 1).*

---

### 1.3. Implementación en Verilog (`univ_bin_counter.v` y `univ_bin_counter_tb.v`)

*(Pendiente de inserción al desarrollar los archivos fuente del Ejercicio 1).*

---

### 1.4. Síntesis RTL y Simulación Funcional (ModelSim)

*(Pendiente de capturas RTL Viewer y formas de onda de ModelSim).*

---

## Ejercicio Número 2: Cronómetro Digital en Displays 7-Segmentos (00.0 a 99.9 s)

### 2.1. Descripción General del Diseño

El sistema de cronómetro digital mide intervalos de tiempo desde **`00.0`** hasta **`99.9` segundos** con una resolución de **décimas de segundo ($0.1\text{ s}$)** utilizando el reloj base de $50\text{ MHz}$ ($T_{\text{clk}} = 20\text{ ns}$) de la tarjeta **DE1-SoC**.

#### 2.1.1. Arquitectura de Contadores en Cascada y Divisor de Frecuencia
Siguiendo el diagrama en bloques de la Figura 2 de la guía, el diseño se estructura en cuatro etapas secuenciales basadas en instancias del contador universal (`univ_bin_counter`) y tres decodificadores BCD a 7 segmentos:

1. **Base de Tiempo de $0.1\text{ s}$ (Contador Módulo $5\,000\,000$):**
   - Con $f_{\text{clk}} = 50\text{ MHz}$, se requieren $50\,000\,000 \times 0.1\text{ s} = 5\,000\,000$ ciclos de reloj para generar un pulso de habilitación cada décima de segundo.
   - Se parametriza con $N = 23\text{ bits}$ ($2^{23} = 8\,388\,608 > 5\,000\,000$) y $\text{MAX\_COUNT} = 4\,999\,999$ (conteo de $0$ a $4\,999\,999$).
   - Su bandera `max_tick` (`tick_01s`) dura exactamente 1 ciclo de reloj cada $0.1\text{ s}$.
2. **Contador BCD de Décimas de Segundo (`HEX0`, $0.0\text{ s} \dots 0.9\text{ s}$):**
   - Parametrizado con $N = 4\text{ bits}$ y $\text{MAX\_COUNT} = 9$ (`"1001"`).
   - Se habilita cuando `ena_dec = go AND tick_01s`.
3. **Contador BCD de Unidades de Segundo (`HEX1`, $0\text{ s} \dots 9\text{ s}$):**
   - Parametrizado con $N = 4\text{ bits}$ y $\text{MAX\_COUNT} = 9$ (`"1001"`).
   - Se habilita en cascada síncrona cuando `ena_uni = go AND tick_01s AND max_tick_dec`.
4. **Contador BCD de Decenas de Segundo (`HEX2`, $00\text{ s} \dots 90\text{ s}$):**
   - Parametrizado con $N = 4\text{ bits}$ y $\text{MAX\_COUNT} = 9$ (`"1001"`).
   - Se habilita en cascada síncrona cuando `ena_ten = go AND tick_01s AND max_tick_dec AND max_tick_uni`.

---

### 2.2. Implementación en VHDL (`stopwatch_top.vhd` y `stopwatch_tb.vhd`)

*(Pendiente de inserción al desarrollar los archivos fuente del Ejercicio 2).*

---

### 2.3. Implementación en Verilog (`stopwatch_top.v` y `stopwatch_tb.v`)

*(Pendiente de inserción al desarrollar los archivos fuente del Ejercicio 2).*

---

### 2.4. Síntesis RTL, Simulación Funcional y Verificación en Hardware (DE1-SoC)

*(Pendiente de capturas RTL Viewer, simulación en ModelSim y enlace al video de funcionamiento en la tarjeta DE1-SoC).*
