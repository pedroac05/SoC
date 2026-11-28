# TCL File Generated for Taller 8 - divisor_avalon
# Platform Designer (Qsys) 18.1

package require -exact qsys 16.1

# 
# module divisor_avalon
# 
set_module_property DESCRIPTION "Parametrizable integer divisor"
set_module_property NAME divisor_avalon
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP Others
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME divisor_avalon
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false

# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL divisor_avalon
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file divisor.vhd VHDL PATH ../hdl/divisor/divisor.vhd
add_fileset_file divisor_avalon.vhd VHDL PATH ../hdl/divisor/divisor_avalon.vhd TOP_LEVEL_FILE

# 
# parameters
# 
add_parameter W INTEGER 32
set_parameter_property W DEFAULT_VALUE 32
set_parameter_property W DISPLAY_NAME W
set_parameter_property W TYPE INTEGER
set_parameter_property W UNITS None
set_parameter_property W ALLOWED_RANGES -2147483648:2147483647
set_parameter_property W HDL_PARAMETER true
set_parameter_property W AFFECTS_ELABORATION true

add_parameter CBIT INTEGER 6
set_parameter_property CBIT DEFAULT_VALUE 6
set_parameter_property CBIT DISPLAY_NAME CBIT
set_parameter_property CBIT TYPE INTEGER
set_parameter_property CBIT UNITS None
set_parameter_property CBIT ALLOWED_RANGES -2147483648:2147483647
set_parameter_property CBIT HDL_PARAMETER true
set_parameter_property CBIT AFFECTS_ELABORATION true

# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1

# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset reset Input 1

# 
# connection point div_cpu
# 
add_interface div_cpu avalon end
set_interface_property div_cpu addressUnits WORDS
set_interface_property div_cpu associatedClock clock
set_interface_property div_cpu associatedReset reset
set_interface_property div_cpu bitsPerSymbol 8
set_interface_property div_cpu burstOnBurstBoundariesOnly false
set_interface_property div_cpu burstcountUnits WORDS
set_interface_property div_cpu explicitAddressSpan 0
set_interface_property div_cpu holdTime 0
set_interface_property div_cpu linewrapBursts false
set_interface_property div_cpu maximumPendingReadTransactions 0
set_interface_property div_cpu maximumPendingWriteTransactions 0
set_interface_property div_cpu readLatency 0
set_interface_property div_cpu readWaitStates 0
set_interface_property div_cpu readWaitTime 0
set_interface_property div_cpu setupTime 0
set_interface_property div_cpu timingUnits Cycles
set_interface_property div_cpu writeWaitTime 0
set_interface_property div_cpu ENABLED true
set_interface_property div_cpu EXPORT_OF ""
set_interface_property div_cpu PORT_NAME_MAP ""
set_interface_property div_cpu CMSIS_SVD_VARIABLES ""
set_interface_property div_cpu SVD_ADDRESS_GROUP ""

add_interface_port div_cpu div_address address Input 3
add_interface_port div_cpu div_chipselect chipselect Input 1
add_interface_port div_cpu div_write write Input 1
add_interface_port div_cpu div_writedata writedata Input W
add_interface_port div_cpu div_readdata readdata Output W
set_interface_assignment div_cpu embeddedsw.configuration.isFlash 0
set_interface_assignment div_cpu embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment div_cpu embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment div_cpu embeddedsw.configuration.isPrintableDevice 0

# 
# connection point div_intr
# 
add_interface div_intr interrupt end
set_interface_property div_intr associatedAddressablePoint div_cpu
set_interface_property div_intr associatedClock clock
set_interface_property div_intr associatedReset reset
set_interface_property div_intr bridgedReceiverOffset ""
set_interface_property div_intr bridgesToReceiver ""
set_interface_property div_intr ENABLED true
set_interface_property div_intr EXPORT_OF ""
set_interface_property div_intr PORT_NAME_MAP ""
set_interface_property div_intr CMSIS_SVD_VARIABLES ""
set_interface_property div_intr SVD_ADDRESS_GROUP ""

add_interface_port div_intr div_irq irq Output 1

# 
# connection point div_led
# 
add_interface div_led conduit end
set_interface_property div_led associatedClock clock
set_interface_property div_led associatedReset reset
set_interface_property div_led ENABLED true
set_interface_property div_led EXPORT_OF ""
set_interface_property div_led PORT_NAME_MAP ""
set_interface_property div_led CMSIS_SVD_VARIABLES ""
set_interface_property div_led SVD_ADDRESS_GROUP ""

add_interface_port div_led DIV_LED export Output 8
