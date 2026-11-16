`timescale 1ns / 1ps

// ============================================================================
// Testbench en Verilog para Codificador Binario a Gray de 4 bits
// Verifica las 16 combinaciones posibles y valida la distancia de Hamming
// ============================================================================

module gray_encoder_tb;

    reg  [3:0] b;
    wire [3:0] g;

    integer i;
    integer errors = 0;
    reg [3:0] prev_g;
    reg [3:0] expected_lut [0:15];
    integer diff_bits;

    gray_encoder dut (
        .b(b),
        .g(g)
    );

    initial begin
        // Inicializar tabla de valores esperados
        expected_lut[0]  = 4'b0000;
        expected_lut[1]  = 4'b0001;
        expected_lut[2]  = 4'b0011;
        expected_lut[3]  = 4'b0010;
        expected_lut[4]  = 4'b0110;
        expected_lut[5]  = 4'b0111;
        expected_lut[6]  = 4'b0101;
        expected_lut[7]  = 4'b0100;
        expected_lut[8]  = 4'b1100;
        expected_lut[9]  = 4'b1101;
        expected_lut[10] = 4'b1111;
        expected_lut[11] = 4'b1110;
        expected_lut[12] = 4'b1010;
        expected_lut[13] = 4'b1011;
        expected_lut[14] = 4'b1001;
        expected_lut[15] = 4'b1000;

        $display("==========================================================");
        $display(">>> INICIO DE SIMULACION: gray_encoder_tb (Verilog) <<<");
        $display("==========================================================");

        prev_g = 4'b0000;

        for (i = 0; i < 16; i = i + 1) begin
            b = i;
            #20;

            // 1. Verificación del valor esperado
            if (g !== expected_lut[i]) begin
                $display("ERROR en b=%0d: Esperado=%b, Obtenido=%b", i, expected_lut[i], g);
                errors = errors + 1;
            end

            // 2. Verificación de la propiedad Gray (distancia de Hamming = 1)
            if (i > 0) begin
                diff_bits = (g[0] ^ prev_g[0]) +
                            (g[1] ^ prev_g[1]) +
                            (g[2] ^ prev_g[2]) +
                            (g[3] ^ prev_g[3]);
                if (diff_bits !== 1) begin
                    $display("ERROR: Entre b=%0d y b=%0d cambiaron %0d bits (debe ser 1)", i-1, i, diff_bits);
                    errors = errors + 1;
                end
            end

            prev_g = g;
        end

        if (errors == 0) begin
            $display("==========================================================");
            $display(">>> SIMULACION EXITOSA: 0 errores encontrados. <<<");
            $display("==========================================================");
        end else begin
            $display(">>> Simulacion finalizada con %0d errores. <<<", errors);
        end

        $stop;
    end

endmodule

