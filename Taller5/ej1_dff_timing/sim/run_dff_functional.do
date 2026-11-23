# ==============================================================================
# Script ModelSim-Altera para Simulacion Funcional (RTL) - Ejercicio 1 (Taller 5)
# Entidad de prueba: dff_timing_tb (500 ns, reloj de 50 MHz / 20 ns, rst 150 ns)
# ==============================================================================

quit -sim

# Crear y mapear libreria de trabajo
vlib work
vmap work work

# Compilar archivos fuente VHDL y Testbench en orden jerarquico
vcom -93 -work work ../vhdl/src/my_dff.vhd
vcom -93 -work work ../vhdl/src/test_signal_generator.vhd
vcom -93 -work work ../vhdl/src/dff_timing.vhd
vcom -93 -work work ../vhdl/tb/dff_timing_tb.vhd

# Iniciar simulacion funcional
vsim work.dff_timing_tb

# Configurar formato de la ventana Wave
configure wave -signalnamewidth 0
configure wave -namecolwidth 200
configure wave -valuecolwidth 60
configure wave -timelineunits ns

# Agregar exactamente las senales solicitadas en el Paso 4 de la guia
add wave -color Green  /dff_timing_tb/clk_tb
add wave -color Green  /dff_timing_tb/rst_tb
add wave -color Green  /dff_timing_tb/en_tb
add wave -color Green  /dff_timing_tb/d_tb
add wave -color Green  /dff_timing_tb/q_tb

# Ejecutar simulacion por 500 ns
run 500 ns
wave zoom full
WaveRestoreZoom {0 ns} {520 ns}
