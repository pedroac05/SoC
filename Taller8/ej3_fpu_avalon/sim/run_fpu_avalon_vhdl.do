# ==============================================================================
# Script ModelSim / QuestaSim para simulacion VHDL de fpu_avalon (Ej. Propuesto)
# Nota: Los IP cores de Intel usan las librerias precompiladas altera_mf,
#       altera_lnsim y lpm incluidas en ModelSim-Intel FPGA Edition.
# ==============================================================================

vlib work
vmap work work

# Compilar libreria DSPBA (compartida por los 4 IP cores)
vcom -93 -work work ../ip/fp_add/dspba_library_package.vhd
vcom -93 -work work ../ip/fp_add/dspba_library.vhd

# Compilar IP cores FP32
vcom -93 -work work ../ip/fp_add/fp_add.vhd
vcom -93 -work work ../ip/fp_sub/fp_sub.vhd
vcom -93 -work work ../ip/fp_mul/fp_mul.vhd
vcom -93 -work work ../ip/fp_div/fp_div.vhd

# Compilar ALU FPU, envolvente Avalon y testbench
vcom -93 -work work ../vhdl/src/fpu_alu.vhd
vcom -93 -work work ../vhdl/src/fpu_avalon.vhd
vcom -93 -work work ../vhdl/tb/fpu_avalon_tb.vhd

# Cargar simulacion enlazando librerias Intel FPGA
vsim -L altera_mf -L altera_lnsim -L lpm work.fpu_avalon_tb

configure wave -signalnamewidth 1
configure wave -namecolwidth 200
configure wave -valuecolwidth 120

add wave -divider "RELOJ Y RESET"
add wave -label "clk"   -color White /fpu_avalon_tb/clk_tb
add wave -label "reset" -color Red   /fpu_avalon_tb/reset_tb

add wave -divider "BUS AVALON MM-SLAVE (fpu_cpu)"
add wave -label "fpu_address"    -radix unsigned -color Yellow /fpu_avalon_tb/fpu_address_tb
add wave -label "fpu_chipselect" -color Cyan     /fpu_avalon_tb/fpu_chipselect_tb
add wave -label "fpu_write"      -color Orange   /fpu_avalon_tb/fpu_write_tb
add wave -label "fpu_writedata"  -radix hex      -color Yellow /fpu_avalon_tb/fpu_writedata_tb
add wave -label "fpu_readdata"   -radix hex      -color Green  /fpu_avalon_tb/fpu_readdata_tb

add wave -divider "REGISTROS INTERNOS FPU (IEEE 754 HEX)"
add wave -label "op_a_reg"      -radix hex    /fpu_avalon_tb/dut/op_a_reg
add wave -label "op_b_reg"      -radix hex    /fpu_avalon_tb/dut/op_b_reg
add wave -label "selop_reg"     -radix binary /fpu_avalon_tb/dut/selop_reg
add wave -label "fpu_result"    -radix hex    -color Green /fpu_avalon_tb/dut/fpu_result
add wave -label "fpu_ready"     -color Green  /fpu_avalon_tb/dut/fpu_ready
add wave -label "done_tick_reg" -color Gold   /fpu_avalon_tb/dut/done_tick_reg
add wave -label "fpu_irq"       -color Magenta /fpu_avalon_tb/fpu_irq_tb

run -all
wave zoom full
