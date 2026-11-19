# ==============================================================================
# Script ModelSim para simulación Verilog pura de fpu_top a 50 MHz (T_clk = 20 ns)
# Utiliza el netlist Verilog generado por Quartus 20.1.1 (Taller3.vo) y las
# librerías Cyclone V en Verilog para evitar conflictos de simulación mixta.
# ==============================================================================

vlib work
vmap work work

vlib cyclonev_ver
vmap cyclonev_ver cyclonev_ver
vlog -work cyclonev_ver D:/Programas/Quartus/quartus/eda/sim_lib/mentor/cyclonev_atoms_ncrypt.v
vlog -work cyclonev_ver D:/Programas/Quartus/quartus/eda/sim_lib/cyclonev_atoms.v

vlib altera_lnsim_ver
vmap altera_lnsim_ver altera_lnsim_ver
vlog -sv -work altera_lnsim_ver D:/Programas/Quartus/quartus/eda/sim_lib/altera_lnsim.sv

vlib altera_ver
vmap altera_ver altera_ver
vlog -work altera_ver D:/Programas/Quartus/quartus/eda/sim_lib/altera_primitives.v

# Compilar netlist Verilog completo de fpu_top y testbench a 50 MHz
vlog -work work ../../../Taller3/simulation/modelsim/Taller3.vo
vlog -work work ../verilog/tb/fpu_top_tb.v

# Cargar simulación en Verilog puro (con resolución ps para Taller3.vo)
vsim -t 1ps -L cyclonev_ver -L altera_lnsim_ver -L altera_ver work.fpu_top_tb

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
