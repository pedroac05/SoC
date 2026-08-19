# ==============================================================================
# Script ModelSim para simulación en VHDL - Ejercicio 3: MUX Logic
# ==============================================================================

# Crear y mapear librería de trabajo
vlib work
vmap work work

# Compilar archivos fuente en orden jerárquico
vcom -93 -work work ../vhdl/src/mux_logic_gate.vhd
vcom -93 -work work ../vhdl/src/mux4to1.vhd
vcom -93 -work work ../vhdl/src/mux_logic_mux.vhd
vcom -93 -work work ../vhdl/src/mux_logic_top.vhd
vcom -93 -work work ../vhdl/tb/mux_logic_tb.vhd

# Cargar el testbench
vsim work.mux_logic_tb

# Configurar visualización de señales en el visor de ondas
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

# Ejecutar simulación completa (16 vectores * 20ns = 320ns)
run -all
wave zoom full
