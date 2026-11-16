`timescale 1ns / 1ps

// ============================================================================
// Testbench en Verilog para Barrel Shifter Multietapa de 0 a 7 bits
// ============================================================================

module barrel_shifter_8bit_tb;
    reg  [7:0] inp;
    reg  [2:0] shift;
    wire [7:0] outp;

    integer s;
    integer errors = 0;
    reg [7:0] expected;

    barrel_shifter_8bit dut (
        .inp(inp),
        .shift(shift),
        .outp(outp)
    );

    initial begin
        $display("==========================================================");
        $display(">>> INICIO DE SIMULACION: barrel_shifter_8bit_tb (Verilog)");
        $display("==========================================================");

        // Prueba 1: Vector 0000_0001
        inp = 8'b0000_0001;
        for (s = 0; s < 8; s = s + 1) begin
            shift = s[2:0];
            expected = inp << s;
            #20;
            if (outp !== expected) begin
                $display("ERROR en inp=%b, shift=%0d: Esperado=%b, Obtenido=%b", inp, s, expected, outp);
                errors = errors + 1;
            end
        end

        // Prueba 2: Vector 1011_0101 (0xB5)
        inp = 8'b1011_0101;
        for (s = 0; s < 8; s = s + 1) begin
            shift = s[2:0];
            expected = inp << s;
            #20;
            if (outp !== expected) begin
                $display("ERROR en inp=%b, shift=%0d: Esperado=%b, Obtenido=%b", inp, s, expected, outp);
                errors = errors + 1;
            end
        end

        // Prueba 3: Vector 1111_1111 (0xFF)
        inp = 8'b1111_1111;
        for (s = 0; s < 8; s = s + 1) begin
            shift = s[2:0];
            expected = inp << s;
            #20;
            if (outp !== expected) begin
                $display("ERROR en inp=%b, shift=%0d: Esperado=%b, Obtenido=%b", inp, s, expected, outp);
                errors = errors + 1;
            end
        end

        if (errors == 0)
            $display(">>> SIMULACION EXITOSA: 0 errores encontrados. <<<");
        else
            $display(">>> Simulacion finalizada con %0d errores. <<<", errors);

        $stop;
    end
endmodule

