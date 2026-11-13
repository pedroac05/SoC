# ==============================================================================
# Script ModelSim / QuestaSim para simulación VHDL de comparator_signed
# ==============================================================================

# Crear librería de trabajo
vlib work
vmap work work

# Compilar diseño y testbench VHDL
vcom -93 -work work ../vhdl/src/comparator_signed.vhd
vcom -93 -work work ../vhdl/tb/comparator_signed_tb.vhd

# Cargar simulación
vsim work.comparator_signed_tb

# Configurar panel de ondas
add wave -divider "MODO DE OPERACION"
add wave -color Yellow /comparator_signed_tb/sig_tb

add wave -divider "ENTRADAS"
add wave -radix decimal /comparator_signed_tb/a_tb
add wave -radix decimal /comparator_signed_tb/b_tb

add wave -divider "SEÑALES INTERNAS PARALELAS"
add wave /comparator_signed_tb/DUT/eq_bits
add wave /comparator_signed_tb/DUT/gt_bits
add wave /comparator_signed_tb/DUT/lt_bits

add wave -divider "SALIDAS"
add wave -color Green /comparator_signed_tb/lg_tb
add wave -color Cyan  /comparator_signed_tb/eq_tb
add wave -color Red   /comparator_signed_tb/ls_tb

# Ejecutar los 512 casos (512 * 10 ns = 5120 ns)
run 5200 ns
wave zoom full

