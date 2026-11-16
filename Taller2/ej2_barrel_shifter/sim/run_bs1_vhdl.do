# ==============================================================================
# Script de simulación en ModelSim para barrel_shifter_1bit (VHDL)
# ==============================================================================

vlib work
vmap work work

vcom -93 -work work ../vhdl/src/barrel_shifter_1bit.vhd
vcom -93 -work work ../vhdl/tb/barrel_shifter_1bit_tb.vhd

vsim work.barrel_shifter_1bit_tb

add wave -divider "ENTRADAS"
add wave -radix binary /barrel_shifter_1bit_tb/inp_tb
add wave -radix hex    /barrel_shifter_1bit_tb/inp_tb
add wave -radix binary /barrel_shifter_1bit_tb/shift_tb

add wave -divider "SALIDA DESPLAZADA (1 BIT)"
add wave -radix binary /barrel_shifter_1bit_tb/outp_tb
add wave -radix hex    /barrel_shifter_1bit_tb/outp_tb

run 240 ns
wave zoom full

