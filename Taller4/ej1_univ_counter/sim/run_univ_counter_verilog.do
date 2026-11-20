# ==============================================================================
# Script ModelSim / QuestaSim para simulacion Verilog de univ_bin_counter
# Parametros en testbench: N = 4, MAX_COUNT = 9 (4'b1001), clk = 50 MHz (20 ns)
# ==============================================================================

# Crear libreria de trabajo
vlib work
vmap work work

# Compilar modulo fuente y testbench Verilog
vlog -work work ../verilog/src/univ_bin_counter.v
vlog -work work ../verilog/tb/univ_bin_counter_tb.v

# Cargar simulacion
vsim work.univ_bin_counter_tb

# Configurar estilo del panel de ondas (nombres cortos y columnas legibles)
configure wave -signalnamewidth 1
configure wave -namecolwidth 180
configure wave -valuecolwidth 60

# Agregar senales organizadas por bloques
add wave -divider "RELOJ Y CONTROL"
add wave -label clk     -color White   /univ_bin_counter_tb/clk_tb
add wave -label rst     -color Red     /univ_bin_counter_tb/rst_tb
add wave -label syn_clr -color Orange  /univ_bin_counter_tb/syn_clr_tb
add wave -label ena     -color Cyan    /univ_bin_counter_tb/ena_tb
add wave -label load    -color Magenta /univ_bin_counter_tb/load_tb
add wave -label up      -color Yellow  /univ_bin_counter_tb/up_tb
add wave -label d       -radix unsigned /univ_bin_counter_tb/d_tb

add wave -divider "SALIDAS DEL CONTADOR (N=4, MAX=9)"
add wave -label counter  -radix unsigned -color Green  /univ_bin_counter_tb/counter_tb
add wave -label max_tick                 -color Yellow /univ_bin_counter_tb/max_tick_tb
add wave -label min_tick                 -color Cyan   /univ_bin_counter_tb/min_tick_tb

# Ejecutar simulacion completa (hasta el fin exacto del testbench: 740 ns)
run 740 ns
wave zoom full
WaveRestoreZoom {0 ps} {740 ns}
