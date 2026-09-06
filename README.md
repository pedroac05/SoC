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
└── reports/                                  # Documentación técnica, enunciados y reportes
    ├── Taller1/
    │   ├── enunciado_taller1.md              # Enunciado del Taller 1
    │   ├── reporte_taller1.md                # Reporte técnico consolidado (con 18 evidencias)
    │   └── images/                           # Capturas RTL Viewer y formas de onda ModelSim
    │
    └── Taller2/
        ├── enunciado_taller2.md              # Enunciado transcrito con tablas y diagramas
        ├── reporte_taller2.md                # Reporte técnico en desarrollo
        └── images/                           # Carpeta de capturas para evidencias fotográficas
```

---

## 🛠️ Herramientas de Desarrollo
- **Quartus Prime Lite Edition (v13.0 SP1 / superiores)**: Síntesis lógica, mapeo tecnológico y visor RTL Viewer.
- **ModelSim-Altera / QuestaSim**: Simulación funcional combinacional, análisis temporal de formas de onda (*Wave*) y verificación exhaustiva mediante *testbenches*.
