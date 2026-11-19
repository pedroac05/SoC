# ==============================================================================
# Script ModelSim / QuestaSim para simulación VHDL de add_subs_de1soc (7-Seg)
# ==============================================================================

vlib work
vmap work work

vcom -93 -work work ../vhdl/src/add_subs.vhd
vcom -93 -work work ../vhdl/src/sevenSegmentDecoder.vhd
vcom -93 -work work ../vhdl/src/add_subs_de1soc.vhd
vcom -93 -work work ../vhdl/tb/add_subs_de1soc_tb.vhd

vsim work.add_subs_de1soc_tb

add wave -divider "SWITCHES DE1-SoC"
add wave -radix binary   /add_subs_de1soc_tb/sw_tb(9)
add wave -radix unsigned /add_subs_de1soc_tb/sw_tb(7 downto 4)
add wave -radix unsigned /add_subs_de1soc_tb/sw_tb(3 downto 0)

add wave -divider "DISPLAYS 7 SEGMENTOS (ACTIVO EN BAJO)"
add wave -radix binary -color Orange /add_subs_de1soc_tb/hex2_tb
add wave -radix binary -color Cyan   /add_subs_de1soc_tb/hex1_tb
add wave -radix binary -color Green  /add_subs_de1soc_tb/hex0_tb

# 7 casos de la Figura 3 * 20 ns = 140 ns
run 140 ns
wave zoom full
