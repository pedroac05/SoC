# ==============================================================================
# Script ModelSim para simulación en Verilog - Ejercicio 3: MUX Logic
# ==============================================================================

# Crear y mapear librería de trabajo
vlib work
vmap work work

# Compilar archivos fuente en Verilog
vlog -work work ../verilog/src/mux_logic_gate.v
vlog -work work ../verilog/src/mux4to1.v
vlog -work work ../verilog/src/mux_logic_mux.v
vlog -work work ../verilog/src/mux_logic_top.v
vlog -work work ../verilog/tb/mux_logic_tb.v

# Cargar el testbench
vsim work.mux_logic_tb

# Configurar visualización de señales en el visor de ondas
add wave -divider "ENTRADAS"
add wave -color "Yellow" /mux_logic_tb/x1
add wave -color "Yellow" /mux_logic_tb/x2
add wave -color "Yellow" /mux_logic_tb/x3
add wave -color "Yellow" /mux_logic_tb/x4

add wave -divider "INTERNAS MUX"
add wave -color "Orange" -radix binary /mux_logic_tb/dut/u_mux_impl/sel_bus
add wave -color "Orange" -radix binary /mux_logic_tb/dut/u_mux_impl/d_bus

add wave -divider "SALIDAS COMPARATIVAS"
add wave -color "Cyan"  /mux_logic_tb/f_gate
add wave -color "Green" /mux_logic_tb/f_mux
add wave -color "White" /mux_logic_tb/match_out

# Ejecutar simulación completa (16 vectores * 20ns = 320ns)
run -all
wave zoom full
