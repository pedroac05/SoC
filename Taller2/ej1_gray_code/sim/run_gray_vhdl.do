# ==============================================================================
# Script de simulación en ModelSim para gray_encoder (VHDL)
# ==============================================================================

# Crear librería de trabajo
vlib work
vmap work work

# Compilar diseño y testbench en VHDL
vcom -93 -work work ../vhdl/src/gray_encoder.vhd
vcom -93 -work work ../vhdl/tb/gray_encoder_tb.vhd

# Iniciar simulación
vsim work.gray_encoder_tb

# Configurar visualización de señales
add wave -divider "ENTRADA BINARIA (4 BITS)"
add wave -radix unsigned /gray_encoder_tb/b_tb
add wave -radix binary   /gray_encoder_tb/b_tb

add wave -divider "SALIDA CODIGO GRAY"
add wave -radix binary   /gray_encoder_tb/g_tb
add wave -radix unsigned /gray_encoder_tb/g_tb

# Ejecutar los 16 vectores (16 * 20 ns = 320 ns)
run 320 ns

# Ajustar zoom a toda la ventana
wave zoom full

