# ==============================================================================
# Script ModelSim-Altera: Simulacion de Tiempos (SDF) - Ejercicio 2 (Cyclone IV GX)
# Reloj: 50 MHz (20000 ps = 20 ns), Duracion: 300 ns
# ==============================================================================

quit -sim

if {[file exists "../../simulation/modelsim/case_study_c4gx.vho"]} {
    cd ../../simulation/modelsim
} elseif {[file exists "simulation/modelsim/case_study_c4gx.vho"]} {
    cd simulation/modelsim
}

vlib work
vmap work work
vcom -93 -work work case_study_c4gx.vho

vsim -t 1ps -sdftyp /=case_study_c4gx_vhd.sdo work.case_study

configure wave -signalnamewidth 1
configure wave -namecolwidth 170
configure wave -valuecolwidth 50
configure wave -timelineunits ns

add wave -divider "ENTRADAS Y RELOJ (50 MHz - Cyclone IV GX)"
add wave -color White  /case_study/clk
add wave -color Yellow /case_study/A
add wave -color Cyan   /case_study/B

add wave -divider "INVERSORES (1 NIVEL vs 3 NIVELES)"
add wave -color Green  /case_study/Aneg_1L
add wave -color Green  /case_study/Aneg_1L_reg
add wave -color Orange /case_study/Bneg_3L
add wave -color Orange /case_study/Bneg_3L_reg

add wave -divider "CASCADA DE COMPUERTAS AND (1 A 5 NIVELES)"
add wave -color Green  /case_study/and_1L
add wave -color Green  /case_study/and_2L
add wave -color Green  /case_study/and_3L
add wave -color Green  /case_study/and_4L
add wave -color Green  /case_study/and_5L

add wave -divider "SALIDAS REGISTRADAS DE COMPUERTAS AND"
add wave -color Cyan   /case_study/and_1L_reg
add wave -color Cyan   /case_study/and_2L_reg
add wave -color Cyan   /case_study/and_3L_reg
add wave -color Cyan   /case_study/and_4L_reg
add wave -color Cyan   /case_study/and_5L_reg

# Reloj de 50 MHz (periodo = 20000 ps = 20 ns, flancos de subida en 10, 30, 50, 70, 90, 110...)
force -freeze sim:/case_study/clk 0 0, 1 {10000 ps} -r 20000

# Estimulos de entrada A y B identicos al testbench funcional
force A 0 0, 1 40000, 0 340000
force B 0 0, 1 100000, 0 180000, 1 260000

run 300ns
wave zoom full
WaveRestoreZoom {0 ps} {300000 ps}
