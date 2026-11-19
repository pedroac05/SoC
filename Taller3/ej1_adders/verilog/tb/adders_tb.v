`timescale 1ns / 1ps

// ============================================================================
// Testbench: adders_tb (Verilog)
// Verifica el módulo adders con SMALL = 4 bits y LARGE = 6 bits,
// aplicando los mismos 8 vectores de prueba cada 20 ns que en VHDL.
// ============================================================================

module adders_tb;

    localparam C_LARGE = 6;
    localparam C_SMALL = 4;

    reg  [C_SMALL-1:0] a_tb;
    reg  [C_SMALL-1:0] b_tb;
    reg  [C_LARGE-1:0] c_tb;
    reg  [C_LARGE-1:0] d_tb;

    wire               cout8_tb;
    wire [C_SMALL-1:0] sum8_tb;
    wire               cout16_tb;
    wire [C_LARGE-1:0] sum16_tb;

    integer idx;
    integer errors = 0;

    reg [C_SMALL-1:0] vec_a [0:7];
    reg [C_SMALL-1:0] vec_b [0:7];
    reg [C_LARGE-1:0] vec_c [0:7];
    reg [C_LARGE-1:0] vec_d [0:7];

    reg [C_SMALL:0] exp_small;
    reg [C_LARGE:0] exp_large;

    // Instanciación del DUT con LARGE = 6 y SMALL = 4
    adders #(
        .LARGE(C_LARGE),
        .SMALL(C_SMALL)
    ) DUT (
        .a      (a_tb),
        .b      (b_tb),
        .c      (c_tb),
        .d      (d_tb),
        .cout8  (cout8_tb),
        .sum8   (sum8_tb),
        .cout16 (cout16_tb),
        .sum16  (sum16_tb)
    );

    initial begin
        // Inicializar vectores de prueba (idénticos a adders_tb.vhd)
        vec_a[0] = 4'd0;  vec_b[0] = 4'd0;  vec_c[0] = 6'd0;  vec_d[0] = 6'd0;
        vec_a[1] = 4'd3;  vec_b[1] = 4'd5;  vec_c[1] = 6'd10; vec_d[1] = 6'd20;
        vec_a[2] = 4'd15; vec_b[2] = 4'd0;  vec_c[2] = 6'd63; vec_d[2] = 6'd0;
        vec_a[3] = 4'd9;  vec_b[3] = 4'd6;  vec_c[3] = 6'd40; vec_d[3] = 6'd23;
        vec_a[4] = 4'd15; vec_b[4] = 4'd1;  vec_c[4] = 6'd63; vec_d[4] = 6'd1;
        vec_a[5] = 4'd10; vec_b[5] = 4'd12; vec_c[5] = 6'd50; vec_d[5] = 6'd30;
        vec_a[6] = 4'd15; vec_b[6] = 4'd15; vec_c[6] = 6'd63; vec_d[6] = 6'd63;
        vec_a[7] = 4'd7;  vec_b[7] = 4'd8;  vec_c[7] = 6'd32; vec_d[7] = 6'd32;

        $display("================ INICIO TESTBENCH ADDERS VERILOG (SMALL=4, LARGE=6) ================");

        for (idx = 0; idx < 8; idx = idx + 1) begin
            a_tb = vec_a[idx];
            b_tb = vec_b[idx];
            c_tb = vec_c[idx];
            d_tb = vec_d[idx];
            #20;

            exp_small = {1'b0, vec_a[idx]} + {1'b0, vec_b[idx]};
            exp_large = {1'b0, vec_c[idx]} + {1'b0, vec_d[idx]};

            if ({cout8_tb, sum8_tb} !== exp_small) begin
                $display("ERROR SUMADOR SMALL (4b): a=%0d, b=%0d => Esperado={%b,%0d}, Obtenido={%b,%0d}",
                         vec_a[idx], vec_b[idx], exp_small[C_SMALL], exp_small[C_SMALL-1:0], cout8_tb, sum8_tb);
                errors = errors + 1;
            end

            if ({cout16_tb, sum16_tb} !== exp_large) begin
                $display("ERROR SUMADOR LARGE (6b): c=%0d, d=%0d => Esperado={%b,%0d}, Obtenido={%b,%0d}",
                         vec_c[idx], vec_d[idx], exp_large[C_LARGE], exp_large[C_LARGE-1:0], cout16_tb, sum16_tb);
                errors = errors + 1;
            end
        end

        if (errors == 0)
            $display(">> VERIFICACION EXITOSA: Todos los vectores (SMALL=4, LARGE=6) pasaron sin errores!");
        else
            $display(">> VERIFICACION CON FALLAS: Total errores = %0d", errors);
    end

endmodule
