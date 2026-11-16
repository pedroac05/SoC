# ==============================================================================
# Script de simulación en ModelSim para gray_encoder (Verilog)
# ==============================================================================

# Crear librería de trabajo
vlib work
vmap work work

# Compilar diseño y testbench en Verilog
vlog -work work ../verilog/src/gray_encoder.v
vlog -work work ../verilog/tb/gray_encoder_tb.v

# Iniciar simulación
vsim work.gray_encoder_tb

# Configurar visualización de señales
add wave -divider "ENTRADA BINARIA (4 BITS)"
add wave -radix unsigned /gray_encoder_tb/b
add wave -radix binary   /gray_encoder_tb/b

add wave -divider "SALIDA CODIGO GRAY"
add wave -radix binary   /gray_encoder_tb/g
add wave -radix unsigned /gray_encoder_tb/g

# Ejecutar los 16 vectores (16 * 20 ns = 320 ns)
run 320 ns

# Ajustar zoom a toda la ventana
wave zoom full

