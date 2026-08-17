# Crear librería de trabajo
vlib work
vmap work work

# Compilar diseño Verilog y testbench
vlog -work work ../verilog/src/eq2.v
vlog -work work ../verilog/tb/eq2_tb.v

# Cargar simulación
vsim work.eq2_tb

# Agregar señales a la ventana de ondas
add wave -divider "ENTRADAS"
add wave -radix unsigned /eq2_tb/a
add wave -radix unsigned /eq2_tb/b
add wave -divider "SALIDA"
add wave /eq2_tb/eq

# Ejecutar simulación completa y ajustar vista
run -all
wave zoom full
