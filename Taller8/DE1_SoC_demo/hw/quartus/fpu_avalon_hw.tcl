# TCL File Generated for Taller 8 - fpu_avalon
# Platform Designer (Qsys) 18.1

package require -exact qsys 16.1

# 
# module fpu_avalon
# 
set_module_property DESCRIPTION "IEEE 754 FP32 ALU"
set_module_property NAME fpu_avalon
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP Others
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME fpu_avalon
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false

# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL fpu_avalon
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file dspba_library_package.vhd VHDL PATH ../hdl/fpu_avalon/fp_add/dspba_library_package.vhd
add_fileset_file dspba_library.vhd VHDL PATH ../hdl/fpu_avalon/fp_add/dspba_library.vhd
add_fileset_file fp_add.vhd VHDL PATH ../hdl/fpu_avalon/fp_add/fp_add.vhd
add_fileset_file fp_sub.vhd VHDL PATH ../hdl/fpu_avalon/fp_sub/fp_sub.vhd
add_fileset_file fp_mul.vhd VHDL PATH ../hdl/fpu_avalon/fp_mul/fp_mul.vhd
add_fileset_file fp_div.vhd VHDL PATH ../hdl/fpu_avalon/fp_div/fp_div.vhd
add_fileset_file fp_div_memoryC0_uid146_invTables_lutmem.hex HEX PATH ../hdl/fpu_avalon/fp_div/fp_div_memoryC0_uid146_invTables_lutmem.hex
add_fileset_file fp_div_memoryC0_uid147_invTables_lutmem.hex HEX PATH ../hdl/fpu_avalon/fp_div/fp_div_memoryC0_uid147_invTables_lutmem.hex
add_fileset_file fp_div_memoryC1_uid150_invTables_lutmem.hex HEX PATH ../hdl/fpu_avalon/fp_div/fp_div_memoryC1_uid150_invTables_lutmem.hex
add_fileset_file fp_div_memoryC1_uid151_invTables_lutmem.hex HEX PATH ../hdl/fpu_avalon/fp_div/fp_div_memoryC1_uid151_invTables_lutmem.hex
add_fileset_file fp_div_memoryC2_uid154_invTables_lutmem.hex HEX PATH ../hdl/fpu_avalon/fp_div/fp_div_memoryC2_uid154_invTables_lutmem.hex
add_fileset_file fpu_alu.vhd VHDL PATH ../hdl/fpu_avalon/fpu_alu.vhd
add_fileset_file fpu_avalon.vhd VHDL PATH ../hdl/fpu_avalon/fpu_avalon.vhd TOP_LEVEL_FILE

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
# connection point fpu_cpu
# 
add_interface fpu_cpu avalon end
set_interface_property fpu_cpu addressUnits WORDS
set_interface_property fpu_cpu associatedClock clock
set_interface_property fpu_cpu associatedReset reset
set_interface_property fpu_cpu bitsPerSymbol 8
set_interface_property fpu_cpu burstOnBurstBoundariesOnly false
set_interface_property fpu_cpu burstcountUnits WORDS
set_interface_property fpu_cpu explicitAddressSpan 0
set_interface_property fpu_cpu holdTime 0
set_interface_property fpu_cpu linewrapBursts false
set_interface_property fpu_cpu maximumPendingReadTransactions 0
set_interface_property fpu_cpu maximumPendingWriteTransactions 0
set_interface_property fpu_cpu readLatency 0
set_interface_property fpu_cpu readWaitStates 0
set_interface_property fpu_cpu readWaitTime 0
set_interface_property fpu_cpu setupTime 0
set_interface_property fpu_cpu timingUnits Cycles
set_interface_property fpu_cpu writeWaitTime 0
set_interface_property fpu_cpu ENABLED true
set_interface_property fpu_cpu EXPORT_OF ""
set_interface_property fpu_cpu PORT_NAME_MAP ""
set_interface_property fpu_cpu CMSIS_SVD_VARIABLES ""
set_interface_property fpu_cpu SVD_ADDRESS_GROUP ""

add_interface_port fpu_cpu fpu_address address Input 3
add_interface_port fpu_cpu fpu_chipselect chipselect Input 1
add_interface_port fpu_cpu fpu_write write Input 1
add_interface_port fpu_cpu fpu_writedata writedata Input 32
add_interface_port fpu_cpu fpu_readdata readdata Output 32
set_interface_assignment fpu_cpu embeddedsw.configuration.isFlash 0
set_interface_assignment fpu_cpu embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment fpu_cpu embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment fpu_cpu embeddedsw.configuration.isPrintableDevice 0

# 
# connection point fpu_intr
# 
add_interface fpu_intr interrupt end
set_interface_property fpu_intr associatedAddressablePoint fpu_cpu
set_interface_property fpu_intr associatedClock clock
set_interface_property fpu_intr associatedReset reset
set_interface_property fpu_intr bridgedReceiverOffset ""
set_interface_property fpu_intr bridgesToReceiver ""
set_interface_property fpu_intr ENABLED true
set_interface_property fpu_intr EXPORT_OF ""
set_interface_property fpu_intr PORT_NAME_MAP ""
set_interface_property fpu_intr CMSIS_SVD_VARIABLES ""
set_interface_property fpu_intr SVD_ADDRESS_GROUP ""

add_interface_port fpu_intr fpu_irq irq Output 1
