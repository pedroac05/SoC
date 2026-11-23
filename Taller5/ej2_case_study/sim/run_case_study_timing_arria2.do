# ==============================================================================
# Script ModelSim-Altera: Simulacion de Tiempos (SDF) - Familia 40 nm (Arria II GX)
# Ejercicio 2 (Puntos 4 y 5): Comparacion de retardos en tecnologia de 40 nm
# ==============================================================================

quit -sim

if {[file exists "../../simulation/modelsim/case_study_arria2gx.vho"]} {
    cd ../../simulation/modelsim
} elseif {[file exists "simulation/modelsim/case_study_arria2gx.vho"]} {
    cd simulation/modelsim
}

vlib work
vmap work work
vcom -93 -work work case_study_arria2gx.vho

vsim -t 1ps -sdftyp /=case_study_arria2gx_vhd.sdo work.case_study

configure wave -signalnamewidth 1
configure wave -namecolwidth 170
configure wave -valuecolwidth 50
configure wave -timelineunits ns

add wave -divider "ENTRADAS Y RELOJ (50 MHz - Arria II GX / 40 nm)"
add wave -color White  /case_study/clk
add wave -color Yellow /case_study/A
add wave -color Cyan   /case_study/B

add wave -divider "INVERSORES (1 NIVEL vs 3 NIVELES - 40 nm)"
add wave -color Green  /case_study/Aneg_1L
add wave -color Green  /case_study/Aneg_1L_reg
add wave -color Orange /case_study/Bneg_3L
add wave -color Orange /case_study/Bneg_3L_reg

add wave -divider "CASCADA DE COMPUERTAS AND (1 A 5 NIVELES - 40 nm)"
add wave -color Green  /case_study/and_1L
add wave -color Green  /case_study/and_2L
add wave -color Green  /case_study/and_3L
add wave -color Green  /case_study/and_4L
add wave -color Green  /case_study/and_5L

add wave -divider "SALIDAS REGISTRADAS DE COMPUERTAS AND (40 nm)"
add wave -color Cyan   /case_study/and_1L_reg
add wave -color Cyan   /case_study/and_2L_reg
add wave -color Cyan   /case_study/and_3L_reg
add wave -color Cyan   /case_study/and_4L_reg
add wave -color Cyan   /case_study/and_5L_reg

# Reloj de 50 MHz (periodo = 20000 ps = 20 ns)
force -freeze sim:/case_study/clk 0 0, 1 {10000 ps} -r 20000

# Estimulos de entrada A y B identicos
force A 0 0, 1 40000, 0 340000
force B 0 0, 1 100000, 0 180000, 1 260000

run 300ns
wave zoom full
WaveRestoreZoom {0 ps} {300000 ps}
