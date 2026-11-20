# ==============================================================================
# Script ModelSim / QuestaSim para simulacion Verilog de stopwatch_top
# DIV_MAX = 4 (1 decima de segundo cada 100 ns @ 50 MHz)
# ==============================================================================

vlib work
vmap work work

# Compilar univ_bin_counter (Ej1) + decodificador + stopwatch_top + testbench
vlog -work work ../../ej1_univ_counter/verilog/src/univ_bin_counter.v
vlog -work work ../verilog/src/sevenSegmentDecoder.v
vlog -work work ../verilog/src/stopwatch_top.v
vlog -work work ../verilog/tb/stopwatch_tb.v

vsim work.stopwatch_tb

configure wave -signalnamewidth 1
configure wave -namecolwidth 170
configure wave -valuecolwidth 60

add wave -divider "ENTRADAS DE CONTROL (DE1-SoC)"
add wave -label CLOCK_50   -color White  /stopwatch_tb/clk_tb
add wave -label enable_SW0 -color Cyan   /stopwatch_tb/sw_tb(0)
add wave -label go_SW1     -color Yellow /stopwatch_tb/sw_tb(1)
add wave -label key0_clr   -color Red    /stopwatch_tb/key_tb(0)

add wave -divider "PULSOS DE CASCADA"
add wave -label tick_01s -color Orange  /stopwatch_tb/dut/tick_01s
add wave -label tick_dec -color Magenta /stopwatch_tb/dut/tick_dec
add wave -label tick_uni -color Cyan    /stopwatch_tb/dut/tick_uni

add wave -divider "DIGITOS BCD (DECENAS : UNIDADES . DECIMAS)"
add wave -label decenas  -radix unsigned -color Green /stopwatch_tb/dut/ten_s
add wave -label unidades -radix unsigned -color Green /stopwatch_tb/dut/uni_s
add wave -label decimas  -radix unsigned -color Green /stopwatch_tb/dut/dec_s

add wave -divider "DISPLAYS 7-SEGMENTOS (ACTIVO BAJO)"
add wave -label HEX2 -radix binary /stopwatch_tb/hex2_tb
add wave -label HEX1 -radix binary /stopwatch_tb/hex1_tb
add wave -label HEX0 -radix binary /stopwatch_tb/hex0_tb

run 12400 ns
wave zoom full
WaveRestoreZoom {0 ps} {12400 ns}
