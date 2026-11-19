`timescale 1ns / 1ps

// ============================================================================
// Testbench: fpu_top_tb (Verilog)
// Reloj de 50 MHz (T_clk = 20 ns)
// ============================================================================

module fpu_top_tb;

    localparam CLK_PERIOD = 20;

    reg         clk_tb = 1'b0;
    reg         areset_tb = 1'b1;
    reg  [31:0] A_tb = 32'h00000000;
    reg  [31:0] B_tb = 32'h00000000;
    reg  [1:0]  selop_tb = 2'b00;
    wire [31:0] result_tb;

    integer errors = 0;

    always #(CLK_PERIOD/2) clk_tb = ~clk_tb;

    fpu_top DUT (
        .clk    (clk_tb),
        .areset (areset_tb),
        .A      (A_tb),
        .B      (B_tb),
        .selop  (selop_tb),
        .result (result_tb)
    );

    initial begin
        areset_tb = 1'b1;
        #(2 * CLK_PERIOD);
        areset_tb = 1'b0;
        @(posedge clk_tb);

        // Prueba 1: A = 6.5 (0x40D00000), B = 2.0 (0x40000000)
        A_tb = 32'h40D00000;
        B_tb = 32'h40000000;

        selop_tb = 2'b00; #(3 * CLK_PERIOD);
        if (result_tb !== 32'h41080000) errors = errors + 1;

        selop_tb = 2'b01; #(2 * CLK_PERIOD);
        if (result_tb !== 32'h40900000) errors = errors + 1;

        selop_tb = 2'b10; #(2 * CLK_PERIOD);
        if (result_tb !== 32'h41500000) errors = errors + 1;

        selop_tb = 2'b11; #(7 * CLK_PERIOD);
        if (result_tb !== 32'h40500000) errors = errors + 1;

        // Prueba 2: A = 10.5 (0x41280000), B = -3.0 (0xC0400000)
        A_tb = 32'h41280000;
        B_tb = 32'hC0400000;

        selop_tb = 2'b00; #(3 * CLK_PERIOD);
        if (result_tb !== 32'h40F00000) errors = errors + 1;

        selop_tb = 2'b01; #(2 * CLK_PERIOD);
        if (result_tb !== 32'h41580000) errors = errors + 1;

        selop_tb = 2'b10; #(2 * CLK_PERIOD);
        if (result_tb !== 32'hC1FC0000) errors = errors + 1;

        selop_tb = 2'b11; #(7 * CLK_PERIOD);
        if (result_tb !== 32'hC0600000) errors = errors + 1;

        if (errors == 0)
            $display(">> VERIFICACION FPU EXITOSA: Todas las operaciones FP32 pasaron sin errores!");
        else
            $display(">> VERIFICACION CON FALLAS: Total errores = %0d", errors);
    end

endmodule
