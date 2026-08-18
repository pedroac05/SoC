# Crear librería de trabajo
vlib work
vmap work work

# Compilar diseño base 2-to-4, diseño 3-to-8 y testbench
vcom -93 -work work ../vhdl/src/dec2to4.vhd
vcom -93 -work work ../vhdl/src/dec3to8.vhd
vcom -93 -work work ../vhdl/tb/dec3to8_tb.vhd

# Cargar simulación
vsim work.dec3to8_tb

# Agregar señales
add wave -divider "CONTROL"
add wave /dec3to8_tb/en_tb
add wave -divider "ENTRADA 3 BITS"
add wave -radix unsigned /dec3to8_tb/in_v_tb
add wave -divider "SEÑALES HABILITACION INTERNAS"
add wave /dec3to8_tb/DUT/en_low
add wave /dec3to8_tb/DUT/en_high
add wave -divider "SALIDA ONE-HOT 8 BITS"
add wave -radix binary /dec3to8_tb/bcode_tb

# Ejecutar simulación completa (16 vectores * 20ns = 320ns)
run -all
wave zoom full
