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
├── Taller4/                                  # Taller 4: Circuitos Secuenciales — Contadores
│   ├── Taller4.qpf                           # Proyecto Quartus Prime (Cyclone V DE1-SoC)
│   ├── Taller4.qsf                           # Configuraciones y asignaciones Quartus
│   ├── ej1_univ_counter/                     # Contador Binario Universal Parametrizable
│   │   ├── vhdl/ (src/, tb/)
│   │   ├── verilog/ (src/, tb/)
│   │   └── sim/
│   └── ej2_stopwatch/                        # Cronómetro Digital BCD (00.0 a 99.9 s) en 7-Segmentos
│       ├── vhdl/ (src/, tb/)
│       ├── verilog/ (src/, tb/)
│       └── sim/
│
├── Taller5/                                  # Taller 5: Timing Simulation (RTL vs Gate-Level SDF)
│   ├── dff_timing.qpf                        # Proyecto Quartus II (Cyclone IV GX EP4CGX15BF14C6)
│   ├── dff_timing.qsf                        # Configuraciones Quartus y EDA Netlist Writer (VHDL .vho/.sdo)
│   ├── ej1_dff_timing/                       # Flip-Flop D con generador BIST (dff_timing)
│   │   ├── vhdl/ (src/, tb/)
│   │   ├── verilog/ (src/, tb/)
│   │   └── sim/                              # Scripts ModelSim funcional y Gate-Level SDF (.do)
│   └── ej2_case_study/                       # Caso de estudio: Cadenas de retardo y comparación de familias FPGA
│       ├── vhdl/ (src/, tb/)
│       ├── verilog/ (src/, tb/)
│       └── sim/
│
├── Taller6/                                  # Taller 6: Circuitos de Memoria — Buffer FIFO Circular
│   ├── Taller6.qpf                           # Proyecto Quartus Prime (Cyclone V DE1-SoC)
│   ├── Taller6.qsf                           # Configuraciones y asignaciones de pines Quartus
│   ├── ej1_fifo_buffer/                      # Buffer FIFO circular parametrizable (Register File + Control)
│   │   ├── vhdl/ (src/, tb/)
│   │   ├── verilog/ (src/, tb/)
│   │   └── sim/                              # Scripts ModelSim (.do) replicando la Figura 2 (a..i)
│   └── ej2_fifo_hw/                          # Prueba de Buffer FIFO (16x4) en hardware con edge_detect y 7-Seg
│       ├── vhdl/ (src/, tb/)
│       ├── verilog/ (src/, tb/)
│       └── sim/                              # Scripts ModelSim (.do) para edge_detect y fifo_hw_top
│
├── Taller7/                                  # Taller 7: DE1-SoC — Programación SoC en ARM-Linux
│   └── DE1_SoC_demo/                         # Proyecto híbrido HPS (ARM-Linux) + FPGA
│       ├── hw/ (hdl/, modelsim/, quartus/)   # Hardware FPGA, Platform Designer (soc_system.qsys) y Quartus
│       ├── sw/hps/                           # Software HPS (application/, preloader/, u-boot/, linux/{source,rootfs})
│       └── sdcard/ (a2/, fat32/)             # Imágenes y particiones para arranque en microSD
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
    ├── Taller3/
    │   ├── enunciado_taller3.md              # Enunciado del Taller 3
    │   ├── reporte_taller3.md                # Reporte técnico consolidado (Parte I y Parte II)
    │   └── images/                           # Capturas RTL, recursos Fitter y simulaciones ModelSim
    │
    ├── Taller4/
    │   ├── enunciado_taller4.md              # Enunciado del Taller 4
    │   ├── reporte_taller4.md                # Reporte técnico consolidado (Contadores y Cronómetro)
    │   └── images/                           # Capturas RTL Viewer y simulaciones ModelSim
    │
    ├── Taller5/
    │   ├── enunciado_taller5.md              # Enunciado del Taller 5 (Timing Simulation)
    │   ├── reporte_taller5.md                # Reporte técnico consolidado (Simulación Funcional vs SDF)
    │   └── images/                           # Capturas TimeQuest, RTL Viewer y simulaciones SDF
    │
    ├── Taller6/
    │   ├── enunciado_taller6.md              # Enunciado del Taller 6 (Buffer FIFO Circular)
    │   ├── reporte_taller6.md                # Reporte técnico consolidado (FIFO Circular y Prueba en Hardware)
    │   └── images/                           # Capturas RTL Viewer y simulaciones ModelSim
    │
    └── Taller7/
        ├── enunciado_taller7.md              # Órdenes directas de desarrollo del Taller 7 (DE1-SoC ARM-Linux)
        ├── guia_paso_a_paso_taller7.md       # Checklist de requisitos y guía paso a paso ejecutable
        ├── reporte_taller7.md                # Reporte técnico consolidado (HPS + FPGA, DDR3 y Apps C-Linux)
        └── images/                           # Evidencias de Platform Designer, Quartus y pruebas ARM-Linux
```

---

## 🛠️ Herramientas de Desarrollo
- **Quartus Prime Lite Edition (v20.1.1 / v18.1 / v13.0 SP1) & Intel SoC EDS (v18.1)**: Síntesis lógica, Platform Designer (`.qsys`), generación de Preloader/BSP, mapeo tecnológico y configuración SoC de la tarjeta **DE1-SoC (Cyclone V `5CSEMA5F31C6`)**.
- **ModelSim-Altera / QuestaSim**: Simulación funcional y temporal a 50 MHz, análisis de formas de onda (*Wave*) y verificación exhaustiva mediante *testbenches*.
