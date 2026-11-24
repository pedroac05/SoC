# ==============================================================================
# Script ModelSim / QuestaSim para simulacion Verilog de Buffer FIFO Circular
# Parametros en testbench: ADDR_WIDTH = 3 (8 posiciones), DATA_WIDTH = 8, 50 MHz
# Replica la secuencia (a) a (i) de la Figura 2 del Taller 6
# ==============================================================================

# Crear libreria de trabajo
vlib work
vmap work work

# Compilar modulos fuente y testbench Verilog
vlog -work work ../verilog/src/register_file.v
vlog -work work ../verilog/src/fifo_ctrl.v
vlog -work work ../verilog/src/fifo.v
vlog -work work ../verilog/tb/fifo_tb.v

# Cargar simulacion
vsim work.fifo_tb

# Configurar estilo del panel de ondas
configure wave -signalnamewidth 1
configure wave -namecolwidth 190
configure wave -valuecolwidth 110

# Agregar senales organizadas por bloques
add wave -divider "FASE DE LA FIGURA 2"
add wave -label "fig2_step" -radix ascii -color Gold /fifo_tb/fig2_step

add wave -divider "RELOJ Y CONTROL"
add wave -label "clk"    -color White   /fifo_tb/clk_tb
add wave -label "reset"  -color Red     /fifo_tb/reset_tb
add wave -label "wr"     -color Cyan    /fifo_tb/wr_tb
add wave -label "rd"     -color Magenta /fifo_tb/rd_tb
add wave -label "w_data" -radix hexadecimal -color Yellow /fifo_tb/w_data_tb

add wave -divider "APUNTADORES CIRCULARES (0..7)"
add wave -label "wr_ptr (w_addr)" -radix unsigned -color Cyan    /fifo_tb/dut/w_addr_s
add wave -label "rd_ptr (r_addr)" -radix unsigned -color Magenta /fifo_tb/dut/r_addr_s
add wave -label "wr_en"                           -color Orange  /fifo_tb/dut/wr_en

add wave -divider "BANDERAS DE ESTADO Y SALIDA"
add wave -label "empty"  -color Green  /fifo_tb/empty_tb
add wave -label "full"   -color Red    /fifo_tb/full_tb
add wave -label "r_data" -radix hexadecimal -color Green /fifo_tb/r_data_tb

add wave -divider "MEMORIA REGISTER FILE (8x8)"
add wave -label "array_reg" -radix hexadecimal /fifo_tb/dut/reg_file_unit/array_reg

# Ejecutar simulacion completa (790 ns)
run 790 ns
wave zoom full
WaveRestoreZoom {0 ps} {790 ns}
