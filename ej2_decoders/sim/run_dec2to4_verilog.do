# Crear librería de trabajo
vlib work
vmap work work

# Compilar diseño Verilog y testbench
vlog -work work ../verilog/src/dec2to4.v
vlog -work work ../verilog/tb/dec2to4_tb.v

# Cargar simulación
vsim work.dec2to4_tb

# Agregar señales
add wave -divider "CONTROL"
add wave /dec2to4_tb/en
add wave -divider "ENTRADA"
add wave -radix unsigned /dec2to4_tb/in_v
add wave -divider "SALIDA ONE-HOT"
add wave -radix binary /dec2to4_tb/bcode

# Ejecutar simulación completa (8 vectores * 20ns = 160ns)
run -all
wave zoom full
