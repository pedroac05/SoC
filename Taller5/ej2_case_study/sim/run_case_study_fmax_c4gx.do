# ==============================================================================
# Script ModelSim-Altera: Simulacion Superando Fmax (555.5 MHz, T_clk = 1800 ps)
# Ejercicio 2 (Punto 3): Impacto de superar Fmax (430.29 MHz en TimeQuest)
# - and_1L_reg, and_2L_reg y and_3L_reg cumplen setup y conmutan a '1' a tiempo.
# - and_4L_reg entra en METAESTABILIDAD ('X' en rojo) por violacion de t_su.
# - and_5L_reg pierde el flanco de reloj y conmuta 1 ciclo completo tarde.
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

add wave -divider "RELOJ SOBRE FMAX (555.5 MHz, T=1.80 ns > Fmax 430.29 MHz)"
add wave -color White  /case_study/clk
add wave -color Yellow /case_study/A
add wave -color Cyan   /case_study/B

add wave -divider "CASCADA COMBINACIONAL (1L a 5L)"
add wave -color Green  /case_study/and_1L
add wave -color Green  /case_study/and_2L
add wave -color Green  /case_study/and_3L
add wave -color Green  /case_study/and_4L
add wave -color Green  /case_study/and_5L

add wave -divider "REGISTROS DE SALIDA (METAESTABILIDAD EN 4L Y RETARDO EN 5L)"
add wave -color Cyan    /case_study/and_1L_reg
add wave -color Cyan    /case_study/and_2L_reg
add wave -color Cyan    /case_study/and_3L_reg
add wave -color Orange  /case_study/and_4L_reg
add wave -color Magenta /case_study/and_5L_reg

# Reloj a 555.5 MHz (periodo = 1800 ps = 1.80 ns, superando Fmax = 430.29 MHz)
force -freeze sim:/case_study/clk 0 0, 1 {900 ps} -r 1800

# Activar A = 1 desde el inicio y conmutar B = 1 en 10 ns y B = 0 en 30 ns
force A 1 0
force B 0 0, 1 10000, 0 30000

run 45ns
wave zoom full
WaveRestoreZoom {0 ps} {45000 ps}
