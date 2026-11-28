package require -exact qsys 16.1

load_system soc_system.qsys

# ==============================================================================
# Taller 9: Uso de Perifericos y Diseno de Manejadores (Drivers)
# Modificaciones sobre soc_system.qsys (base Taller 7):
#   1. Configurar Edge Capture Register (FALLING) en buttons_0
#   2. Agregar dos Interval Timer de 32 bits: sys_timer y usr_timer
#   3. Conectar reloj (pll_0.outclk0), reset (hps_0.h2f_reset) y bus Avalon LW
#   4. Asignar direcciones base segun Figura 7 del enunciado
# ==============================================================================

# 1. Reconfigurar buttons_0 (PIO 4b Input, Edge Capture FALLING)
set_instance_parameter_value buttons_0 {captureEdge} {true}
set_instance_parameter_value buttons_0 {edgeType} {FALLING}
set_instance_parameter_value buttons_0 {bitClearingEdgeCapReg} {false}
set_instance_parameter_value buttons_0 {generateIRQ} {false}

# 2. Agregar temporizadores Interval Timer (32-bit, Full-featured, 1 ms)
add_instance usr_timer altera_avalon_timer
set_instance_parameter_value usr_timer {alwaysRun} {false}
set_instance_parameter_value usr_timer {counterSize} {32}
set_instance_parameter_value usr_timer {fixedPeriod} {false}
set_instance_parameter_value usr_timer {period} {1}
set_instance_parameter_value usr_timer {periodUnits} {MSEC}
set_instance_parameter_value usr_timer {resetOutput} {false}
set_instance_parameter_value usr_timer {snapshot} {true}
set_instance_parameter_value usr_timer {timeoutPulseOutput} {false}

add_instance sys_timer altera_avalon_timer
set_instance_parameter_value sys_timer {alwaysRun} {false}
set_instance_parameter_value sys_timer {counterSize} {32}
set_instance_parameter_value sys_timer {fixedPeriod} {false}
set_instance_parameter_value sys_timer {period} {1}
set_instance_parameter_value sys_timer {periodUnits} {MSEC}
set_instance_parameter_value sys_timer {resetOutput} {false}
set_instance_parameter_value sys_timer {snapshot} {true}
set_instance_parameter_value sys_timer {timeoutPulseOutput} {false}

# 3. Conexiones de reloj, reset y bus Lightweight AXI para ambos temporizadores
add_connection pll_0.outclk0 usr_timer.clk clock
add_connection hps_0.h2f_reset usr_timer.reset reset
add_connection hps_0.h2f_lw_axi_master usr_timer.s1 avalon

add_connection pll_0.outclk0 sys_timer.clk clock
add_connection hps_0.h2f_reset sys_timer.reset reset
add_connection hps_0.h2f_lw_axi_master sys_timer.s1 avalon

# 4. Asignar direcciones base (referencia Figura 7)
set_connection_parameter_value hps_0.h2f_lw_axi_master/usr_timer.s1 arbitrationPriority {1}
set_connection_parameter_value hps_0.h2f_lw_axi_master/usr_timer.s1 baseAddress {0x0000}
set_connection_parameter_value hps_0.h2f_lw_axi_master/usr_timer.s1 defaultConnection {0}

set_connection_parameter_value hps_0.h2f_lw_axi_master/sys_timer.s1 arbitrationPriority {1}
set_connection_parameter_value hps_0.h2f_lw_axi_master/sys_timer.s1 baseAddress {0x0020}
set_connection_parameter_value hps_0.h2f_lw_axi_master/sys_timer.s1 defaultConnection {0}

set_connection_parameter_value hps_0.h2f_lw_axi_master/hex_5.s1 baseAddress {0x0040}
set_connection_parameter_value hps_0.h2f_lw_axi_master/hex_4.s1 baseAddress {0x0050}
set_connection_parameter_value hps_0.h2f_lw_axi_master/hex_3.s1 baseAddress {0x0060}
set_connection_parameter_value hps_0.h2f_lw_axi_master/hex_2.s1 baseAddress {0x0070}
set_connection_parameter_value hps_0.h2f_lw_axi_master/hex_1.s1 baseAddress {0x0080}
set_connection_parameter_value hps_0.h2f_lw_axi_master/hex_0.s1 baseAddress {0x0090}
set_connection_parameter_value hps_0.h2f_lw_axi_master/buttons_0.s1 baseAddress {0x00A0}
set_connection_parameter_value hps_0.h2f_lw_axi_master/switches_0.s1 baseAddress {0x00B0}
set_connection_parameter_value hps_0.h2f_lw_axi_master/leds_0.s1 baseAddress {0x00C0}

save_system soc_system.qsys
