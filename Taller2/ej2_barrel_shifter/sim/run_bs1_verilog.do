# ==============================================================================
# Script de simulación en ModelSim para barrel_shifter_1bit (Verilog)
# ==============================================================================

vlib work
vmap work work

vlog -work work ../verilog/src/barrel_shifter_1bit.v
vlog -work work ../verilog/tb/barrel_shifter_1bit_tb.v

vsim work.barrel_shifter_1bit_tb

add wave -divider "ENTRADAS"
add wave -radix binary /barrel_shifter_1bit_tb/inp
add wave -radix hex    /barrel_shifter_1bit_tb/inp
add wave -radix binary /barrel_shifter_1bit_tb/shift

add wave -divider "SALIDA DESPLAZADA (1 BIT)"
add wave -radix binary /barrel_shifter_1bit_tb/outp
add wave -radix hex    /barrel_shifter_1bit_tb/outp

run 240 ns
wave zoom full

