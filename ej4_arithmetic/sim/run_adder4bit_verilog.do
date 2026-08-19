# ==============================================================================
# Script ModelSim para simulación en Verilog - Ejercicio 4: Sumador 4-bit MUX
# ==============================================================================

# Crear y mapear librería de trabajo
vlib work
vmap work work

# Compilar módulos Verilog y testbench
vlog -work work ../verilog/src/mux4to1.v
vlog -work work ../verilog/src/full_adder_mux.v
vlog -work work ../verilog/src/adder4bit.v
vlog -work work ../verilog/tb/adder4bit_tb.v

# Cargar simulación
vsim work.adder4bit_tb

# Configurar visualización de señales en el visor de ondas
add wave -divider "ENTRADAS"
add wave -color "Yellow" -radix unsigned /adder4bit_tb/a
add wave -color "Yellow" -radix unsigned /adder4bit_tb/b
add wave -color "Yellow" /adder4bit_tb/cin

add wave -divider "ACARREOS INTERNOS (RIPPLE)"
add wave -color "Orange" /adder4bit_tb/dut/c

add wave -divider "SALIDAS"
add wave -color "Cyan"  -radix unsigned /adder4bit_tb/s
add wave -color "Red"   /adder4bit_tb/cout

# Ejecución
run -all
wave zoom full
