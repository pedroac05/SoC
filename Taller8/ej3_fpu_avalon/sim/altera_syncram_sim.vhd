-- ==============================================================================
-- Wrapper de simulacion VHDL puro: altera_syncram -> altera_mf.altsyncram
-- Permite simular los IP cores FP32 generados en Quartus Prime 20.1.1 dentro
-- de ModelSim-Altera Starter Edition (single-language VHDL) sin requerir
-- licencia mixta SystemVerilog/VHDL para altera_lnsim.sv.
-- ==============================================================================
library ieee;
use ieee.std_logic_1164.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity altera_syncram is
    generic (
        operation_mode                      : string  := "BIDIR_DUAL_PORT";
        width_a                             : integer := 1;
        widthad_a                           : integer := 1;
        widthad2_a                          : integer := 1;
        numwords_a                          : integer := 0;
        outdata_reg_a                       : string  := "UNREGISTERED";
        address_aclr_a                      : string  := "NONE";
        outdata_aclr_a                      : string  := "NONE";
        width_byteena_a                     : integer := 1;
        width_b                             : integer := 1;
        widthad_b                           : integer := 1;
        widthad2_b                          : integer := 1;
        numwords_b                          : integer := 0;
        rdcontrol_reg_b                     : string  := "CLOCK1";
        address_reg_b                       : string  := "CLOCK1";
        outdata_reg_b                       : string  := "UNREGISTERED";
        outdata_aclr_b                      : string  := "NONE";
        indata_reg_b                        : string  := "CLOCK1";
        byteena_reg_b                       : string  := "CLOCK1";
        address_aclr_b                      : string  := "NONE";
        clock_enable_input_a                : string  := "NORMAL";
        clock_enable_output_a               : string  := "NORMAL";
        clock_enable_input_b                : string  := "NORMAL";
        clock_enable_output_b               : string  := "NORMAL";
        width_byteena_b                     : integer := 1;
        clock_enable_core_a                 : string  := "USE_INPUT_CLKEN";
        clock_enable_core_b                 : string  := "USE_INPUT_CLKEN";
        read_during_write_mode_port_a       : string  := "NEW_DATA_NO_NBE_READ";
        read_during_write_mode_port_b       : string  := "NEW_DATA_NO_NBE_READ";
        enable_ecc                          : string  := "FALSE";
        ecc_pipeline_stage_enabled          : string  := "FALSE";
        width_eccstatus                     : integer := 2;
        byte_size                           : integer := 0;
        read_during_write_mode_mixed_ports  : string  := "DONT_CARE";
        ram_block_type                      : string  := "AUTO";
        implement_in_les                    : string  := "OFF";
        power_up_uninitialized              : string  := "FALSE";
        sim_show_memory_data_in_port_b_layout : string := "OFF";
        outdata_sclr_a                      : string  := "NONE";
        outdata_sclr_b                      : string  := "NONE";
        enable_ecc_encoder_bypass           : string  := "FALSE";
        enable_coherent_read                : string  := "FALSE";
        enable_force_to_zero                : string  := "FALSE";
        width_eccencparity                  : integer := 8;
        init_file                           : string  := "UNUSED";
        init_file_layout                    : string  := "UNUSED";
        maximum_depth                       : integer := 0;
        intended_device_family              : string  := "Cyclone V";
        lpm_hint                            : string  := "UNUSED";
        lpm_type                            : string  := "altsyncram"
    );
    port (
        wren_a          : in  std_logic := '0';
        wren_b          : in  std_logic := '0';
        rden_a          : in  std_logic := '1';
        rden_b          : in  std_logic := '1';
        data_a          : in  std_logic_vector(width_a - 1 downto 0) := (others => '1');
        data_b          : in  std_logic_vector(width_b - 1 downto 0) := (others => '1');
        address_a       : in  std_logic_vector(widthad_a - 1 downto 0);
        address_b       : in  std_logic_vector(widthad_b - 1 downto 0) := (others => '1');
        clock0          : in  std_logic := '1';
        clock1          : in  std_logic := 'Z';
        clocken0        : in  std_logic := '1';
        clocken1        : in  std_logic := '1';
        clocken2        : in  std_logic := '1';
        clocken3        : in  std_logic := '1';
        aclr0           : in  std_logic := '0';
        aclr1           : in  std_logic := '0';
        byteena_a       : in  std_logic_vector(width_byteena_a - 1 downto 0) := (others => '1');
        byteena_b       : in  std_logic_vector(width_byteena_b - 1 downto 0) := (others => 'Z');
        eccencbypass    : in  std_logic := '0';
        eccencparity    : in  std_logic_vector(width_eccencparity - 1 downto 0) := (others => '1');
        sclr            : in  std_logic := '0';
        address2_a      : in  std_logic_vector(widthad2_a - 1 downto 0) := (others => '1');
        address2_b      : in  std_logic_vector(widthad2_b - 1 downto 0) := (others => '1');
        addressstall_a  : in  std_logic := '0';
        addressstall_b  : in  std_logic := '0';
        q_a             : out std_logic_vector(width_a - 1 downto 0);
        q_b             : out std_logic_vector(width_b - 1 downto 0);
        eccstatus       : out std_logic_vector(width_eccstatus - 1 downto 0) := (others => '0')
    );
end entity altera_syncram;

architecture sim_wrap of altera_syncram is
begin
    u_altsyncram : altsyncram
        generic map (
            operation_mode                      => operation_mode,
            width_a                             => width_a,
            widthad_a                           => widthad_a,
            numwords_a                          => numwords_a,
            outdata_reg_a                       => outdata_reg_a,
            address_aclr_a                      => address_aclr_a,
            outdata_aclr_a                      => outdata_aclr_a,
            width_byteena_a                     => width_byteena_a,
            width_b                             => width_b,
            widthad_b                           => widthad_b,
            numwords_b                          => numwords_b,
            rdcontrol_reg_b                     => rdcontrol_reg_b,
            address_reg_b                       => address_reg_b,
            outdata_reg_b                       => outdata_reg_b,
            outdata_aclr_b                      => outdata_aclr_b,
            indata_reg_b                        => indata_reg_b,
            byteena_reg_b                       => byteena_reg_b,
            address_aclr_b                      => address_aclr_b,
            clock_enable_input_a                => clock_enable_input_a,
            clock_enable_output_a               => clock_enable_output_a,
            clock_enable_input_b                => clock_enable_input_b,
            clock_enable_output_b               => clock_enable_output_b,
            width_byteena_b                     => width_byteena_b,
            clock_enable_core_a                 => clock_enable_core_a,
            clock_enable_core_b                 => clock_enable_core_b,
            read_during_write_mode_port_a       => read_during_write_mode_port_a,
            read_during_write_mode_port_b       => read_during_write_mode_port_b,
            enable_ecc                          => enable_ecc,
            width_eccstatus                     => width_eccstatus,
            byte_size                           => byte_size,
            read_during_write_mode_mixed_ports  => read_during_write_mode_mixed_ports,
            ram_block_type                      => ram_block_type,
            implement_in_les                    => implement_in_les,
            power_up_uninitialized              => power_up_uninitialized,
            init_file                           => init_file,
            init_file_layout                    => init_file_layout,
            maximum_depth                       => maximum_depth,
            intended_device_family              => intended_device_family,
            lpm_hint                            => lpm_hint,
            lpm_type                            => "altsyncram"
        )
        port map (
            wren_a          => wren_a,
            wren_b          => wren_b,
            rden_a          => rden_a,
            rden_b          => rden_b,
            data_a          => data_a,
            data_b          => data_b,
            address_a       => address_a,
            address_b       => address_b,
            clock0          => clock0,
            clock1          => clock1,
            clocken0        => clocken0,
            clocken1        => clocken1,
            clocken2        => clocken2,
            clocken3        => clocken3,
            aclr0           => aclr0,
            aclr1           => aclr1,
            byteena_a       => byteena_a,
            byteena_b       => byteena_b,
            addressstall_a  => addressstall_a,
            addressstall_b  => addressstall_b,
            q_a             => q_a,
            q_b             => q_b,
            eccstatus       => eccstatus
        );
end architecture sim_wrap;
