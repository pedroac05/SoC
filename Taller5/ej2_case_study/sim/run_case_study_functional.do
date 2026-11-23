# ==============================================================================
# Script ModelSim-Altera: Simulacion Funcional (RTL) - Ejercicio 2 (Caso de Estudio)
# Reloj: 50 MHz (20 ns), Duracion: 300 ns
# ==============================================================================

quit -sim

vlib work
vmap work work

vcom -93 -work work ../vhdl/src/case_study.vhd
vcom -93 -work work ../vhdl/tb/case_study_tb.vhd

vsim work.case_study_tb

configure wave -signalnamewidth 1
configure wave -namecolwidth 170
configure wave -valuecolwidth 50
configure wave -timelineunits ns

add wave -divider "ENTRADAS Y RELOJ (50 MHz)"
add wave -color White  /case_study_tb/clk_tb
add wave -color Yellow /case_study_tb/A_tb
add wave -color Cyan   /case_study_tb/B_tb

add wave -divider "INVERSORES (1 NIVEL vs 3 NIVELES)"
add wave -color Green  /case_study_tb/Aneg_1L_tb
add wave -color Green  /case_study_tb/Aneg_1L_reg_tb
add wave -color Orange /case_study_tb/Bneg_3L_tb
add wave -color Orange /case_study_tb/Bneg_3L_reg_tb

add wave -divider "CASCADA DE COMPUERTAS AND (1 A 5 NIVELES)"
add wave -color Green  /case_study_tb/and_1L_tb
add wave -color Green  /case_study_tb/and_2L_tb
add wave -color Green  /case_study_tb/and_3L_tb
add wave -color Green  /case_study_tb/and_4L_tb
add wave -color Green  /case_study_tb/and_5L_tb

add wave -divider "SALIDAS REGISTRADAS DE COMPUERTAS AND"
add wave -color Cyan   /case_study_tb/and_1L_reg_tb
add wave -color Cyan   /case_study_tb/and_2L_reg_tb
add wave -color Cyan   /case_study_tb/and_3L_reg_tb
add wave -color Cyan   /case_study_tb/and_4L_reg_tb
add wave -color Cyan   /case_study_tb/and_5L_reg_tb

run 300 ns
wave zoom full
WaveRestoreZoom {0 ns} {300 ns}
