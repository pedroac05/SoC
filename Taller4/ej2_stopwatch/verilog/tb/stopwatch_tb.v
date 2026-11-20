`timescale 1ns / 1ps

// ==============================================================================
// Testbench Verilog para stopwatch_top (Cronometro 00.0 a 99.9 s)
// DIV_MAX = 4 (5 ciclos = 100 ns por decima de segundo) para simulacion rapida
// ==============================================================================

module stopwatch_tb;

    localparam integer T_CLK   = 20;
    localparam integer DIV_SIM = 4;

    localparam [6:0] SEG_0 = 7'b1000000;
    localparam [6:0] SEG_1 = 7'b1111001;
    localparam [6:0] SEG_2 = 7'b0100100;

    reg        clk_tb;
    reg  [1:0] sw_tb;
    reg  [0:0] key_tb;
    wire [6:0] hex0_tb;
    wire [6:0] hex1_tb;
    wire [6:0] hex2_tb;

    integer errors = 0;

    stopwatch_top #(
        .DIV_MAX(DIV_SIM)
    ) dut (
        .CLOCK_50(clk_tb),
        .SW(sw_tb),
        .KEY(key_tb),
        .HEX0(hex0_tb),
        .HEX1(hex1_tb),
        .HEX2(hex2_tb)
    );

    // Reloj de 50 MHz
    initial clk_tb = 1'b0;
    always #(T_CLK / 2) clk_tb = ~clk_tb;

    initial begin
        // 1. Sistema deshabilitado inicialmente (SW[0] = 0)
        sw_tb  = 2'b00;
        key_tb = 1'b1;
        #40;
        if (hex2_tb !== SEG_0 || hex1_tb !== SEG_0 || hex0_tb !== SEG_0) begin
            $display("[ERROR] Fase 1: Cronometro debe iniciar en 00.0");
            errors = errors + 1;
        end

        // 2. Habilitar circuito y activar conteo (SW = 2'b11)
        @(negedge clk_tb);
        sw_tb = 2'b11;

        // 10 decimas = 50 ciclos -> 01.0
        repeat (50) @(posedge clk_tb);
        #2;
        if (hex2_tb !== SEG_0 || hex1_tb !== SEG_1 || hex0_tb !== SEG_0) begin
            $display("[ERROR] Fase 2: Se esperaba 01.0");
            errors = errors + 1;
        end

        // +2 decimas = 10 ciclos -> 01.2
        repeat (10) @(posedge clk_tb);
        #2;
        if (hex2_tb !== SEG_0 || hex1_tb !== SEG_1 || hex0_tb !== SEG_2) begin
            $display("[ERROR] Fase 2: Se esperaba 01.2");
            errors = errors + 1;
        end

        // 3. Pausa (go = 0) durante 15 ciclos -> mantener 01.2
        @(negedge clk_tb);
        sw_tb = 2'b01;
        repeat (15) @(posedge clk_tb);
        #2;
        if (hex2_tb !== SEG_0 || hex1_tb !== SEG_1 || hex0_tb !== SEG_2) begin
            $display("[ERROR] Fase 3: No mantuvo pausa en 01.2");
            errors = errors + 1;
        end

        // 4. Reanudar hasta 02.0 (8 decimas = 40 ciclos)
        @(negedge clk_tb);
        sw_tb = 2'b11;
        repeat (40) @(posedge clk_tb);
        #2;
        if (hex2_tb !== SEG_0 || hex1_tb !== SEG_2 || hex0_tb !== SEG_0) begin
            $display("[ERROR] Fase 4: Se esperaba 02.0 al reanudar");
            errors = errors + 1;
        end

        // 5. Reinicio sincrono con KEY[0] = 0
        @(negedge clk_tb);
        key_tb = 1'b0;
        @(posedge clk_tb);
        #2;
        if (hex2_tb !== SEG_0 || hex1_tb !== SEG_0 || hex0_tb !== SEG_0) begin
            $display("[ERROR] Fase 5: KEY[0] no reinicio a 00.0");
            errors = errors + 1;
        end

        @(negedge clk_tb);
        key_tb = 1'b1;

        // 6. Avanzar 100 decimas (500 ciclos) -> 10.0
        repeat (500) @(posedge clk_tb);
        #2;
        if (hex2_tb !== SEG_1 || hex1_tb !== SEG_0 || hex0_tb !== SEG_0) begin
            $display("[ERROR] Fase 6: Se esperaba 10.0 tras 100 decimas");
            errors = errors + 1;
        end

        #40;
        if (errors == 0)
            $display("=== SIMULACION VERILOG CRONOMETRO COMPLETADA (0 ERRORES) ===");
        else
            $display("=== SIMULACION VERILOG FINALIZADA CON %0d ERRORES ===", errors);
    end

endmodule
