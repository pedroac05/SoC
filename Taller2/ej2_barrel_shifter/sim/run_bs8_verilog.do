# ==============================================================================
# Script de simulación en ModelSim para barrel_shifter_8bit (Verilog)
# ==============================================================================

vlib work
vmap work work

vlog -work work ../verilog/src/barrel_shifter_8bit.v
vlog -work work ../verilog/tb/barrel_shifter_8bit_tb.v

vsim work.barrel_shifter_8bit_tb

add wave -divider "ENTRADAS"
add wave -radix binary   /barrel_shifter_8bit_tb/inp
add wave -radix unsigned /barrel_shifter_8bit_tb/shift
add wave -radix binary   /barrel_shifter_8bit_tb/shift

add wave -divider "ETAPAS INTERNAS EN CASCADA"
add wave -radix binary   /barrel_shifter_8bit_tb/dut/s0
add wave -radix binary   /barrel_shifter_8bit_tb/dut/s1

add wave -divider "SALIDA FINAL (0..7 BITS)"
add wave -radix binary   /barrel_shifter_8bit_tb/outp
add wave -radix hex      /barrel_shifter_8bit_tb/outp

run 480 ns
wave zoom full

