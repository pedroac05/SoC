# ==============================================================================
# Script ModelSim / QuestaSim para simulación Verilog de comparator_signed
# ==============================================================================

# Crear librería de trabajo
vlib work
vmap work work

# Compilar diseño y testbench Verilog
vlog -work work ../verilog/src/comparator_signed.v
vlog -work work ../verilog/tb/comparator_signed_tb.v

# Cargar simulación
vsim work.comparator_signed_tb

# Configurar panel de ondas
add wave -divider "MODO DE OPERACION"
add wave -color Yellow /comparator_signed_tb/sig

add wave -divider "ENTRADAS"
add wave -radix decimal /comparator_signed_tb/a
add wave -radix decimal /comparator_signed_tb/b

add wave -divider "SEÑALES INTERNAS PARALELAS"
add wave /comparator_signed_tb/dut/eq_bits
add wave /comparator_signed_tb/dut/gt_bits
add wave /comparator_signed_tb/dut/lt_bits

add wave -divider "SALIDAS"
add wave -color Green /comparator_signed_tb/lg
add wave -color Cyan  /comparator_signed_tb/eq
add wave -color Red   /comparator_signed_tb/ls

# Ejecutar la simulación
run 5200 ns
wave zoom full

