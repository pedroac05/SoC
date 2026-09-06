# Crear librería de trabajo
vlib work
vmap work work

# Compilar módulos Verilog y testbench
vlog -work work ../verilog/src/dec2to4.v
vlog -work work ../verilog/src/dec3to8.v
vlog -work work ../verilog/tb/dec3to8_tb.v

# Cargar simulación
vsim work.dec3to8_tb

# Agregar señales
add wave -divider "CONTROL"
add wave /dec3to8_tb/en
add wave -divider "ENTRADA 3 BITS"
add wave -radix unsigned /dec3to8_tb/in_v
add wave -divider "SEÑALES HABILITACION INTERNAS"
add wave /dec3to8_tb/dut/en_low
add wave /dec3to8_tb/dut/en_high
add wave -divider "SALIDA ONE-HOT 8 BITS"
add wave -radix binary /dec3to8_tb/bcode

# Ejecutar simulación completa (16 vectores * 20ns = 320ns)
run -all
wave zoom full
