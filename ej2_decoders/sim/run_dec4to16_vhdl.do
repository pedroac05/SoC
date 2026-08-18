# Crear librería de trabajo
vlib work
vmap work work

# Compilar diseño base 2-to-4, diseño 4-to-16 y testbench
vcom -93 -work work ../vhdl/src/dec2to4.vhd
vcom -93 -work work ../vhdl/src/dec4to16.vhd
vcom -93 -work work ../vhdl/tb/dec4to16_tb.vhd

# Cargar simulación
vsim work.dec4to16_tb

# Agregar señales
add wave -divider "CONTROL"
add wave /dec4to16_tb/en_tb
add wave -divider "ENTRADA 4 BITS"
add wave -radix unsigned /dec4to16_tb/in_v_tb
add wave -divider "ENABLES INTERNOS"
add wave -radix binary /dec4to16_tb/DUT/en_bus
add wave -divider "SALIDA ONE-HOT 16 BITS"
add wave -radix binary /dec4to16_tb/bcode_tb

# Ejecutar simulación completa (32 vectores * 20ns = 640ns)
run -all
wave zoom full
