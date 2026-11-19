# ==============================================================================
# Script ModelSim para simulación VHDL pura de fpu_top a 50 MHz (T_clk = 20 ns)
# Utiliza el netlist VHDL generado por Quartus 20.1.1 (Taller3.vho) para evitar
# conflictos de simulación mixta (SystemVerilog/VHDL) en ModelSim Starter Edition.
# ==============================================================================

# Crear librería de trabajo y librería cyclonev actualizada (Quartus 20.1.1)
vlib work
vmap work work

vlib cyclonev
vmap cyclonev cyclonev
vcom -93 -work cyclonev D:/Programas/Quartus/quartus/eda/sim_lib/cyclonev_atoms.vhd
vcom -93 -work cyclonev D:/Programas/Quartus/quartus/eda/sim_lib/cyclonev_components.vhd

vlib altera_lnsim
vmap altera_lnsim altera_lnsim
vcom -93 -work altera_lnsim D:/Programas/Quartus/quartus/eda/sim_lib/altera_lnsim_components.vhd

# Compilar el netlist VHDL completo de fpu_top y el testbench a 50 MHz
vcom -93 -work work ../../../Taller3/simulation/modelsim/Taller3.vho
vcom -93 -work work ../vhdl/tb/fpu_top_tb.vhd

# Cargar simulación en VHDL puro
vsim -L cyclonev -L altera_lnsim -L altera work.fpu_top_tb

add wave -divider "RELOJ 50 MHz (T = 20 ns) Y CONTROL"
add wave -color White  /fpu_top_tb/clk_tb
add wave -color Red    /fpu_top_tb/areset_tb
add wave -radix binary -color Yellow /fpu_top_tb/selop_tb

add wave -divider "OPERANDOS FP32 (IEEE 754)"
add wave -radix hex /fpu_top_tb/A_tb
add wave -radix hex /fpu_top_tb/B_tb

add wave -divider "RESULTADO FPU (MUX 4:1)"
add wave -radix hex -color Green /fpu_top_tb/result_tb

# Ejecutar simulación completa (~620 ns)
run 620 ns
wave zoom full
