# ==============================================================================
# Script ModelSim / QuestaSim para simulación Verilog de add_subs (4 bits)
# ==============================================================================

vlib work
vmap work work

vlog -work work ../verilog/src/add_subs.v
vlog -work work ../verilog/tb/add_subs_tb.v

vsim work.add_subs_tb

add wave -divider "ENTRADAS (UNSIGNED 4 BITS) Y OPERACION"
add wave -radix unsigned /add_subs_tb/a_tb
add wave -radix unsigned /add_subs_tb/b_tb
add wave -color Yellow   /add_subs_tb/add_subsn_tb

add wave -divider "SALIDAS INDIVIDUALES"
add wave -radix binary   /add_subs_tb/cout_tb
add wave -radix binary   /add_subs_tb/sum_tb

add wave -divider "RESULTADO COMBINADO 5 BITS (cout & sum)"
add wave -radix binary -color Green /add_subs_tb/res5_tb
add wave -radix unsigned -color Cyan /add_subs_tb/res5_tb
add wave -radix decimal -color Orange /add_subs_tb/res5_tb

# 10 vectores * 20 ns = 200 ns
run 200 ns
wave zoom full
