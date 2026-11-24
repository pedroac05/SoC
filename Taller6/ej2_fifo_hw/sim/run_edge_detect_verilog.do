# ==============================================================================
# Script ModelSim / QuestaSim para simulacion Verilog de edge_detect (Parte 2.1)
# ==============================================================================

vlib work
vmap work work

vlog -work work ../verilog/src/edge_detect.v
vlog -work work ../verilog/tb/edge_tb.v

vsim work.edge_tb

configure wave -signalnamewidth 1
configure wave -namecolwidth 190
configure wave -valuecolwidth 80

add wave -divider "RELOJ Y SENAL ASINCRONA"
add wave -label "clk (50 MHz)" -color White  /edge_tb/clk
add wave -label "async_sig"    -color Yellow /edge_tb/async

add wave -divider "DUT 1: EDGE_DETECT (SOBRE ASYNC)"
add wave -label "shifter(1..3)"  -color Cyan   /edge_tb/DUT/shifter
add wave -label "rise (1 ciclo)" -color Green  /edge_tb/rise
add wave -label "fall (1 ciclo)" -color Orange /edge_tb/fall

add wave -divider "DUT 2: EDGE_DETECT EN CASCADA (SOBRE RISE)"
add wave -label "rise2" -color Magenta /edge_tb/rise2
add wave -label "fall2" -color Red     /edge_tb/fall2

run 1000 ns
wave zoom full
WaveRestoreZoom {0 ps} {1000 ns}
