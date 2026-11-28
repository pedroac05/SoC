# ==============================================================================
# Script ModelSim / QuestaSim para simulacion VHDL de divisor (Actividad 1)
# Parametros en testbench: W = 8, CBIT = 4, f_clk = 50 MHz (T = 20 ns)
# ==============================================================================

vlib work
vmap work work

vcom -93 -work work ../vhdl/src/divisor.vhd
vcom -93 -work work ../vhdl/tb/divisor_tb.vhd

vsim work.divisor_tb

configure wave -signalnamewidth 1
configure wave -namecolwidth 180
configure wave -valuecolwidth 100

add wave -divider "RELOJ Y CONTROL"
add wave -label "clk"       -color White  /divisor_tb/clk_tb
add wave -label "reset"     -color Red    /divisor_tb/reset_tb
add wave -label "start"     -color Cyan   /divisor_tb/start_tb
add wave -label "ready"     -color Green  /divisor_tb/ready_tb
add wave -label "done_tick" -color Gold   /divisor_tb/done_tick_tb

add wave -divider "ENTRADAS (UNSIGNED)"
add wave -label "dvnd" -radix unsigned -color Yellow /divisor_tb/dvnd_tb
add wave -label "dvsr" -radix unsigned -color Orange /divisor_tb/dvsr_tb

add wave -divider "ESTADOS Y REGISTROS INTERNOS"
add wave -label "state_reg" -color Magenta /divisor_tb/dut/state_reg
add wave -label "n_reg"     -radix unsigned /divisor_tb/dut/n_reg

add wave -divider "SALIDAS (UNSIGNED)"
add wave -label "quo" -radix unsigned -color Green /divisor_tb/quo_tb
add wave -label "rmd" -radix unsigned -color Cyan  /divisor_tb/rmd_tb

run -all
wave zoom full
