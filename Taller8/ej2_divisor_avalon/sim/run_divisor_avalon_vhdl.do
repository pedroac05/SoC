# ==============================================================================
# Script ModelSim / QuestaSim para simulacion VHDL de divisor_avalon (Act. 2)
# Parametros en testbench: W = 32, CBIT = 6, f_clk = 50 MHz (T = 20 ns)
# ==============================================================================

vlib work
vmap work work

vcom -93 -work work ../vhdl/src/divisor.vhd
vcom -93 -work work ../vhdl/src/divisor_avalon.vhd
vcom -93 -work work ../vhdl/tb/divisor_avalon_tb.vhd

vsim work.divisor_avalon_tb

configure wave -signalnamewidth 1
configure wave -namecolwidth 200
configure wave -valuecolwidth 110

add wave -divider "RELOJ Y RESET"
add wave -label "clk"   -color White /divisor_avalon_tb/clk_tb
add wave -label "reset" -color Red   /divisor_avalon_tb/reset_tb

add wave -divider "BUS AVALON MM-SLAVE (div_cpu)"
add wave -label "div_address"    -radix unsigned -color Yellow /divisor_avalon_tb/div_address_tb
add wave -label "div_chipselect" -color Cyan     /divisor_avalon_tb/div_chipselect_tb
add wave -label "div_write"      -color Orange   /divisor_avalon_tb/div_write_tb
add wave -label "div_writedata"  -radix unsigned -color Yellow /divisor_avalon_tb/div_writedata_tb
add wave -label "div_readdata"   -radix unsigned -color Green  /divisor_avalon_tb/div_readdata_tb

add wave -divider "REGISTROS Y SENALES INTERNAS"
add wave -label "dvnd_reg"      -radix unsigned /divisor_avalon_tb/dut/dvnd_reg
add wave -label "dvsr_reg"      -radix unsigned /divisor_avalon_tb/dut/dvsr_reg
add wave -label "div_start"     -color Cyan     /divisor_avalon_tb/dut/div_start
add wave -label "div_ready"     -color Green    /divisor_avalon_tb/dut/div_ready
add wave -label "div_done_tick" -color Gold     /divisor_avalon_tb/dut/div_done_tick
add wave -label "done_tick_reg" -color Gold     /divisor_avalon_tb/dut/done_tick_reg

add wave -divider "SALIDAS IRQ Y CONDUIT"
add wave -label "div_irq" -color Magenta /divisor_avalon_tb/div_irq_tb
add wave -label "DIV_LED" -radix unsigned -color Green /divisor_avalon_tb/div_led_tb

run -all
wave zoom full
