# ==============================================================================
# Script ModelSim / QuestaSim para simulacion VHDL de fifo_hw_top (Figura 4)
# Parametros: DATA_WIDTH = 4 bits, ADDR_WIDTH = 4 (16 registros)
# ==============================================================================

vlib work
vmap work work

vcom -93 -work work ../../ej1_fifo_buffer/vhdl/src/register_file.vhd
vcom -93 -work work ../../ej1_fifo_buffer/vhdl/src/fifo_ctrl.vhd
vcom -93 -work work ../../ej1_fifo_buffer/vhdl/src/fifo.vhd
vcom -93 -work work ../vhdl/src/edge_detect.vhd
vcom -93 -work work ../vhdl/src/bin_to_sseg.vhd
vcom -93 -work work ../vhdl/src/fifo_hw_top.vhd
vcom -93 -work work ../vhdl/tb/fifo_hw_tb.vhd

vsim work.fifo_hw_tb

configure wave -signalnamewidth 1
configure wave -namecolwidth 200
configure wave -valuecolwidth 90

add wave -divider "ENTRADAS DE USUARIO (BOTONES Y SWITCHES)"
add wave -label "clk (50 MHz)"   -color White   /fifo_hw_tb/clk_tb
add wave -label "reset"          -color Red     /fifo_hw_tb/reset_tb
add wave -label "wr (boton)"     -color Cyan    /fifo_hw_tb/wr_tb
add wave -label "rd (boton)"     -color Magenta /fifo_hw_tb/rd_tb
add wave -label "w_data(3..0)"   -radix hexadecimal -color Yellow /fifo_hw_tb/w_data_tb

add wave -divider "PULSOS SINCRONIZADOS (EDGE_DETECT: 1 CICLO)"
add wave -label "wr_tick (push)" -color Cyan    /fifo_hw_tb/dut/wr_tick
add wave -label "rd_tick (pop)"  -color Magenta /fifo_hw_tb/dut/rd_tick

add wave -divider "FIFO INTERNA (16 REGISTROS x 4 BITS)"
add wave -label "wr_ptr"         -radix unsigned    -color Cyan    /fifo_hw_tb/dut/fifo_buffer/w_addr_s
add wave -label "rd_ptr"         -radix unsigned    -color Magenta /fifo_hw_tb/dut/fifo_buffer/r_addr_s
add wave -label "r_data(3..0)"   -radix hexadecimal -color Green   /fifo_hw_tb/dut/r_data_s

add wave -divider "SALIDAS A LEDS Y DISPLAY 7-SEGMENTOS"
add wave -label "empty (LED)"       -color Green  /fifo_hw_tb/empty_tb
add wave -label "full (LED)"        -color Red    /fifo_hw_tb/full_tb
add wave -label "r_data_hex(6..0)"  -radix binary -color Gold /fifo_hw_tb/r_data_hex_tb

run 3960 ns
wave zoom full
WaveRestoreZoom {0 ps} {3960 ns}
