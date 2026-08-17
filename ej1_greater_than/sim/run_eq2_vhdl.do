# Crear librería de trabajo
vlib work
vmap work work

# Compilar diseño VHDL y testbench
vcom -93 -work work ../vhdl/src/eq2.vhd
vcom -93 -work work ../vhdl/tb/eq2_tb.vhd

# Cargar simulación
vsim work.eq2_tb

# Agregar señales a la ventana de ondas
add wave -divider "ENTRADAS"
add wave -radix unsigned /eq2_tb/a_tb
add wave -radix unsigned /eq2_tb/b_tb
add wave -divider "SALIDA"
add wave /eq2_tb/eq_tb

# Ejecutar simulación completa y ajustar vista
run -all
wave zoom full
