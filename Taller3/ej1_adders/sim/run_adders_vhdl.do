# ==============================================================================
# Script ModelSim / QuestaSim para simulación VHDL de adders (SMALL=4, LARGE=6)
# ==============================================================================

# Crear librería de trabajo
vlib work
vmap work work

# Compilar módulos fuente y testbench VHDL
vcom -93 -work work ../vhdl/src/add_w_carry.vhd
vcom -93 -work work ../vhdl/src/adders.vhd
vcom -93 -work work ../vhdl/tb/adders_tb.vhd

# Cargar simulación
vsim work.adders_tb

# Configurar panel de ondas
add wave -divider "SUMADOR SMALL (4 BITS)"
add wave -radix unsigned /adders_tb/a_tb
add wave -radix unsigned /adders_tb/b_tb
add wave -radix unsigned -color Green /adders_tb/sum8_tb
add wave -color Yellow /adders_tb/cout8_tb

add wave -divider "SUMADOR LARGE (6 BITS)"
add wave -radix unsigned /adders_tb/c_tb
add wave -radix unsigned /adders_tb/d_tb
add wave -radix unsigned -color Cyan /adders_tb/sum16_tb
add wave -color Yellow /adders_tb/cout16_tb

# Ejecutar simulación completa (8 * 20 ns = 160 ns)
run 180 ns
wave zoom full

