`timescale 1ns / 1ps

// ============================================================================
// Testbench en Verilog para Barrel Shifter de 1 bit (8 bits de datos)
// ============================================================================

module barrel_shifter_1bit_tb;
    reg  [7:0] inp;
    reg        shift;
    wire [7:0] outp;

    integer i;
    integer errors = 0;
    reg [7:0] patterns [0:5];
    reg [7:0] expected;

    barrel_shifter_1bit dut (
        .inp(inp),
        .shift(shift),
        .outp(outp)
    );

    initial begin
        patterns[0] = 8'b0000_0001;
        patterns[1] = 8'b1000_0000;
        patterns[2] = 8'b1010_1010;
        patterns[3] = 8'b0101_0101;
        patterns[4] = 8'b1100_1011;
        patterns[5] = 8'b1111_1111;

        $display("==========================================================");
        $display(">>> INICIO DE SIMULACION: barrel_shifter_1bit_tb (Verilog)");
        $display("==========================================================");

        for (i = 0; i < 6; i = i + 1) begin
            inp = patterns[i];

            // Caso A: shift = 0
            shift = 1'b0;
            expected = patterns[i];
            #20;
            if (outp !== expected) begin
                $display("ERROR en shift=0, inp=%b: Esperado=%b, Obtenido=%b", inp, expected, outp);
                errors = errors + 1;
            end

            // Caso B: shift = 1
            shift = 1'b1;
            expected = {patterns[i][6:0], 1'b0};
            #20;
            if (outp !== expected) begin
                $display("ERROR en shift=1, inp=%b: Esperado=%b, Obtenido=%b", inp, expected, outp);
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

