# ==============================================================================
# Script ModelSim-Altera para Simulacion de Tiempos (Gate-Level + SDF)
# Ejercicio 1 (Taller 5): dff_timing.vho + dff_timing_vhd.sdo
# ==============================================================================

quit -sim

# Si se ejecuta desde ej1_dff_timing/sim, cambiar a simulation/modelsim
if {[file exists "../../simulation/modelsim/dff_timing_vhd.sdo"]} {
    cd ../../simulation/modelsim
} elseif {[file exists "simulation/modelsim/dff_timing_vhd.sdo"]} {
    cd simulation/modelsim
}

# Si Quartus Prime 20.1 sobrescribio dff_timing.vho con Cyclone V (que no soporta .sdo),
# restaurar automaticamente la netlist Cyclone IV GX que coincide con dff_timing_vhd.sdo
if {[file exists "dff_timing_c4gx.vho"]} {
    file copy -force dff_timing_c4gx.vho dff_timing.vho
    file copy -force dff_timing_c4gx_vhd.sdo dff_timing_vhd.sdo
}

# Crear libreria work y compilar la netlist post-fitting (.vho)
vlib work
vmap work work
vcom -93 -work work dff_timing.vho

# Iniciar simulacion de tiempos cargando el archivo SDF (dff_timing_vhd.sdo) en la raiz (/)
vsim -t 1ps -sdftyp /=dff_timing_vhd.sdo work.dff_timing

# Configurar ventana Wave
configure wave -signalnamewidth 0
configure wave -namecolwidth 160
configure wave -valuecolwidth 60
configure wave -timelineunits ns

# Paso 11: Agregar las senales clk, rst, en, d y q a la ventana wave
add wave -color Green /dff_timing/clk
add wave -color Green /dff_timing/rst
add wave -color Green /dff_timing/en
add wave -color Green /dff_timing/d
add wave -color Green /dff_timing/q

# Paso 11: Configurar clk con Duty 50%, Period 20000 ps (50 MHz, First Edge Rising)
force -freeze sim:/dff_timing/clk 1 0, 0 {10000 ps} -r 20000

# Paso 11: Forzar la senal de reset (1 en 0 ps, 0 en 50000 ps = 50 ns)
force rst 1 0, 0 50000

# Correr la simulacion por 500 ns
run 500ns
wave zoom full
WaveRestoreZoom {0 ps} {520000 ps}
