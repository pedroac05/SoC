# Crear librería de trabajo
vlib work
vmap work work

# Compilar dependencias y diseño estructural Verilog
vlog -work work ../verilog/src/gt2.v
vlog -work work ../verilog/src/eq2.v
vlog -work work ../verilog/src/gt4.v
vlog -work work ../verilog/tb/gt4_tb.v

# Cargar simulación
vsim work.gt4_tb

# Agregar señales a la ventana de ondas
add wave -divider "ENTRADAS 4 BITS"
add wave -radix unsigned /gt4_tb/a
add wave -radix unsigned /gt4_tb/b
add wave -divider "SEÑALES INTERNAS ESTRUCTURALES"
add wave /gt4_tb/dut/gt_high
add wave /gt4_tb/dut/eq_high
add wave /gt4_tb/dut/gt_low
add wave -divider "SALIDA FINAL"
add wave /gt4_tb/gt

# Ejecutar simulación completa (256 * 20ns = 5120 ns)
run -all
wave zoom full
