# ==============================================================================
# Script de simulación en ModelSim para barrel_shifter_8bit (VHDL)
# ==============================================================================

vlib work
vmap work work

vcom -93 -work work ../vhdl/src/barrel_shifter_8bit.vhd
vcom -93 -work work ../vhdl/tb/barrel_shifter_8bit_tb.vhd

vsim work.barrel_shifter_8bit_tb

add wave -divider "ENTRADAS"
add wave -radix binary   /barrel_shifter_8bit_tb/inp_tb
add wave -radix unsigned /barrel_shifter_8bit_tb/shift_tb
add wave -radix binary   /barrel_shifter_8bit_tb/shift_tb

add wave -divider "ETAPAS INTERNAS EN CASCADA"
add wave -radix binary   /barrel_shifter_8bit_tb/DUT/s0
add wave -radix binary   /barrel_shifter_8bit_tb/DUT/s1

add wave -divider "SALIDA FINAL (0..7 BITS)"
add wave -radix binary   /barrel_shifter_8bit_tb/outp_tb
add wave -radix hex      /barrel_shifter_8bit_tb/outp_tb

run 480 ns
wave zoom full

