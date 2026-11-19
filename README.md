# Talleres de Diseño Digital y SoC
**System on Chip (SoC) - Pontificia Universidad Javeriana**  
**Departamento de Electrónica**

Este repositorio contiene el desarrollo completo, códigos fuente en **VHDL** y **Verilog**, bancos de prueba (*testbenches*), scripts de automatización de simulación para **ModelSim**, proyectos de **Quartus Prime** y reportes técnicos detallados organizados modularmente por talleres.

---

## 📁 Estructura del Repositorio

```text
SoC/
├── .gitignore
├── README.md
│
├── Taller1/                                  # Taller 1: Gate-Level y RTL-Multiplexores
│   ├── Taller1.qpf                           # Proyecto Quartus Prime
│   ├── Taller1.qsf                           # Configuraciones y asignaciones Quartus
│   ├── ej1_greater_than/                     # Comparador Greater-Than (2 y 4 bits) y Eq (2 bits)
│   │   ├── vhdl/ (src/, tb/)
│   │   ├── verilog/ (src/, tb/)
│   │   └── sim/                              # Scripts de simulación ModelSim (.do)
│   ├── ej2_decoders/                         # Decodificadores Binarios (2:4, 3:8, 4:16)
│   ├── ej3_mux_logic/                        # Síntesis con Multiplexores vs Compuertas
│   └── ej4_arithmetic/                       # Full Adder y Sumador Ripple Carry de 4 bits con MUX
│
├── Taller2/                                  # Taller 2: Circuitos Combinacionales a Nivel RTL
│   ├── Taller2.qpf                           # Proyecto Quartus Prime
│   ├── Taller2.qsf                           # Configuraciones y asignaciones Quartus
│   ├── ej1_gray_code/                        # Codificador Binario a Gray de 4 bits
│   │   ├── vhdl/ (src/, tb/)
│   │   ├── verilog/ (src/, tb/)
│   │   └── sim/
│   ├── ej2_barrel_shifter/                   # Barrel Shifter (1 bit y multietapa 0-7 bits)
│   │   ├── vhdl/ (src/, tb/)
│   │   ├── verilog/ (src/, tb/)
│   │   └── sim/
│   └── ej3_comparator_signed/                # Comparador de Magnitud Signed / Unsigned
│       ├── vhdl/ (src/, tb/)
│       ├── verilog/ (src/, tb/)
│       └── sim/
│
├── Taller3/                                  # Taller 3: RTL Design II — Circuitos Aritméticos
│   ├── Taller3.qpf                           # Proyecto Quartus Prime (Cyclone V DE1-SoC)
│   ├── Taller3.qsf                           # Configuraciones y asignaciones Quartus
│   ├── ej1_adders/                           # Sumadores parametrizables con acarreo (VHDL/Verilog)
│   ├── ej2_add_subs/                         # Sumador-Restador C2 e integración 7-Segmentos DE1-SoC
│   └── ej3_fpu/                              # Unidad de Punto Flotante FP32 IEEE 754 (50 MHz)
│       ├── ip/vhdl/ (fp_add, fp_sub, fp_mul, fp_div)
│       ├── vhdl/ (src/, tb/)
│       ├── verilog/ (src/, tb/)
│       └── sim/
│
└── reports/                                  # Documentación técnica, enunciados y reportes
    ├── Taller1/
    │   ├── enunciado_taller1.md              # Enunciado del Taller 1
    │   ├── reporte_taller1.md                # Reporte técnico consolidado (con 18 evidencias)
    │   └── images/                           # Capturas RTL Viewer y formas de onda ModelSim
    │
    ├── Taller2/
    │   ├── enunciado_taller2.md              # Enunciado del Taller 2
    │   ├── reporte_taller2.md                # Reporte técnico consolidado (con 10 evidencias)
    │   └── images/                           # Capturas RTL Viewer y formas de onda ModelSim
    │
    └── Taller3/
        ├── enunciado_taller3.md              # Enunciado del Taller 3
        ├── reporte_taller3.md                # Reporte técnico consolidado (Parte I y Parte II)
        └── images/                           # Capturas RTL, recursos Fitter y simulaciones ModelSim
```

---

## 🛠️ Herramientas de Desarrollo
- **Quartus Prime Lite Edition (v20.1.1 / v13.0 SP1)**: Síntesis lógica, mapeo tecnológico, generación de bloques IP, visor RTL Viewer y programación JTAG de la tarjeta **DE1-SoC (Cyclone V `5CSEMA5F31C6`)**.
- **ModelSim-Altera / QuestaSim**: Simulación funcional y temporal a 50 MHz, análisis de formas de onda (*Wave*) y verificación exhaustiva mediante *testbenches*.
