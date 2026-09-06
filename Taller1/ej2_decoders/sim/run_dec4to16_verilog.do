# Crear librería de trabajo
vlib work
vmap work work

# Compilar módulos Verilog y testbench
vlog -work work ../verilog/src/dec2to4.v
vlog -work work ../verilog/src/dec4to16.v
vlog -work work ../verilog/tb/dec4to16_tb.v

# Cargar simulación
vsim work.dec4to16_tb

# Agregar señales
add wave -divider "CONTROL"
add wave /dec4to16_tb/en
add wave -divider "ENTRADA 4 BITS"
add wave -radix unsigned /dec4to16_tb/in_v
add wave -divider "ENABLES INTERNOS"
add wave -radix binary /dec4to16_tb/dut/en_bus
add wave -divider "SALIDA ONE-HOT 16 BITS"
add wave -radix binary /dec4to16_tb/bcode

# Ejecutar simulación completa (32 vectores * 20ns = 640ns)
run -all
wave zoom full
