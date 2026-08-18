# Crear librería de trabajo
vlib work
vmap work work

# Compilar dependencias y diseño estructural VHDL
vcom -93 -work work ../vhdl/src/gt2.vhd
vcom -93 -work work ../vhdl/src/eq2.vhd
vcom -93 -work work ../vhdl/src/gt4.vhd
vcom -93 -work work ../vhdl/tb/gt4_tb.vhd

# Cargar simulación
vsim work.gt4_tb

# Agregar señales principales y subseñales
add wave -divider "ENTRADAS 4 BITS"
add wave -radix unsigned /gt4_tb/a_tb
add wave -radix unsigned /gt4_tb/b_tb
add wave -divider "SEÑALES INTERNAS ESTRUCTURALES"
add wave /gt4_tb/DUT/gt_high
add wave /gt4_tb/DUT/eq_high
add wave /gt4_tb/DUT/gt_low
add wave -divider "SALIDA FINAL"
add wave /gt4_tb/gt_tb

# Ejecutar simulación completa (256 * 20ns = 5120 ns)
run -all
wave zoom full
