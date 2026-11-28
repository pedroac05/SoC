package require -exact qsys 16.1

load_system soc_system.qsys

# Agregar componente divisor_avalon (instancia 'div')
add_instance div divisor_avalon 1.0
set_instance_parameter_value div {W} {32}
set_instance_parameter_value div {CBIT} {6}

add_connection pll_0.outclk0 div.clock clock
add_connection hps_0.h2f_reset div.reset reset
add_connection hps_0.h2f_lw_axi_master div.div_cpu avalon
set_connection_parameter_value hps_0.h2f_lw_axi_master/div.div_cpu arbitrationPriority {1}
set_connection_parameter_value hps_0.h2f_lw_axi_master/div.div_cpu baseAddress {0x00A0}
set_connection_parameter_value hps_0.h2f_lw_axi_master/div.div_cpu defaultConnection {0}

add_interface div_led_external_connection conduit end
set_interface_property div_led_external_connection EXPORT_OF div.div_led

# Agregar componente fpu_avalon (instancia 'fpu')
add_instance fpu fpu_avalon 1.0

add_connection pll_0.outclk0 fpu.clock clock
add_connection hps_0.h2f_reset fpu.reset reset
add_connection hps_0.h2f_lw_axi_master fpu.fpu_cpu avalon
set_connection_parameter_value hps_0.h2f_lw_axi_master/fpu.fpu_cpu arbitrationPriority {1}
set_connection_parameter_value hps_0.h2f_lw_axi_master/fpu.fpu_cpu baseAddress {0x00C0}
set_connection_parameter_value hps_0.h2f_lw_axi_master/fpu.fpu_cpu defaultConnection {0}

save_system soc_system.qsys
