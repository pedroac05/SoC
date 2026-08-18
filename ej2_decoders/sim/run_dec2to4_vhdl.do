# Crear librería de trabajo
vlib work
vmap work work

# Compilar diseño VHDL y testbench
vcom -93 -work work ../vhdl/src/dec2to4.vhd
vcom -93 -work work ../vhdl/tb/dec2to4_tb.vhd

# Cargar simulación
vsim work.dec2to4_tb

# Agregar señales
add wave -divider "CONTROL"
add wave /dec2to4_tb/en_tb
add wave -divider "ENTRADA"
add wave -radix unsigned /dec2to4_tb/in_v_tb
add wave -divider "SALIDA ONE-HOT"
add wave -radix binary /dec2to4_tb/bcode_tb

# Ejecutar simulación completa (8 vectores * 20ns = 160ns)
run -all
wave zoom full
