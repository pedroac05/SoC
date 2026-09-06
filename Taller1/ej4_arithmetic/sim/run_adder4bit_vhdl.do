# ==============================================================================
# Script ModelSim para simulación en VHDL - Ejercicio 4: Sumador 4-bit MUX
# ==============================================================================

# Crear y mapear librería de trabajo
vlib work
vmap work work

# Compilar archivos fuente en orden jerárquico
vcom -93 -work work ../vhdl/src/mux4to1.vhd
vcom -93 -work work ../vhdl/src/full_adder_mux.vhd
vcom -93 -work work ../vhdl/src/adder4bit.vhd
vcom -93 -work work ../vhdl/tb/adder4bit_tb.vhd

# Cargar simulación
vsim work.adder4bit_tb

# Configurar visualización de señales en el visor de ondas
add wave -divider "ENTRADAS"
add wave -color "Yellow" -radix unsigned /adder4bit_tb/a_tb
add wave -color "Yellow" -radix unsigned /adder4bit_tb/b_tb
add wave -color "Yellow" /adder4bit_tb/cin_tb

add wave -divider "ACARREOS INTERNOS (RIPPLE)"
add wave -color "Orange" /adder4bit_tb/DUT/c

add wave -divider "SALIDAS"
add wave -color "Cyan"  -radix unsigned /adder4bit_tb/s_tb
add wave -color "Red"   /adder4bit_tb/cout_tb

# Ejecución
run -all
wave zoom full
