# Taller de Diseño: Gate-Level y RTL-Multiplexores
**System on Chip (SoC) - Pontificia Universidad Javeriana**

Este repositorio contiene el desarrollo, simulaciones en VHDL y Verilog, y reportes del taller de diseño digital.

---

## 📁 Estructura del Proyecto

```text
SoC/
├── reports/                          # Documentación, enunciados y reporte del taller
│   ├── enunciado_taller.md           # Enunciado oficial del taller
│   ├── reporte_taller1.md            # Reporte técnico consolidado
│   └── images/                       # Capturas de RTL Viewer y formas de onda ModelSim
│
├── ej1_greater_than/                 # Ejercicio 1: Circuito Greater-Than (2 bits y 4 bits)
│   ├── vhdl/
│   │   ├── src/                      # gt2.vhd, eq2.vhd, gt4.vhd
│   │   └── tb/                       # gt2_tb.vhd, gt4_tb.vhd
│   ├── verilog/
│   │   ├── src/                      # gt2.v, eq2.v, gt4.v
│   │   └── tb/                       # gt2_tb.v, gt4_tb.v
│   └── sim/                          # Scripts de simulación ModelSim (.do)
│
├── ej2_decoders/                     # Ejercicio 2: Decodificadores Binarios (2-to-4, 3-to-8, 4-to-16)
│   ├── vhdl/ (src/, tb/)
│   ├── verilog/ (src/, tb/)
│   └── sim/
│
├── ej3_mux_logic/                    # Ejercicio 3: Función Lógica con MUX vs Gate-Level
│   ├── vhdl/ (src/, tb/)
│   ├── verilog/ (src/, tb/)
│   └── sim/
│
└── ej4_arithmetic/                   # Ejercicio 4: Aritmética Binaria (Full Adder Mux y Ripple Carry Adder 4 bits)
    ├── vhdl/ (src/, tb/)
    ├── verilog/ (src/, tb/)
    └── sim/
```

---

## 🛠️ Herramientas
- **Quartus Prime Lite**: Síntesis y análisis RTL.
- **ModelSim / QuestaSim**: Simulación funcional y verificación de testbenches.
