`timescale 1ns / 1ps

module gt4_tb;
    reg  [3:0] a;
    reg  [3:0] b;
    wire       gt;

    integer i, j;
    integer errors = 0;

    gt4 dut (
        .a(a),
        .b(b),
        .gt(gt)
    );

    initial begin
        a = 4'b0000;
        b = 4'b0000;

        // Recorrer las 256 combinaciones de prueba (16 x 16)
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                a = i;
                b = j;
                #20;

                if (i > j && gt !== 1'b1) begin
                    $display("ERROR: Esperaba gt=1 para a=%0d, b=%0d => obtenido gt=%b", i, j, gt);
                    errors = errors + 1;
                end else if (i <= j && gt !== 1'b0) begin
                    $display("ERROR: Esperaba gt=0 para a=%0d, b=%0d => obtenido gt=%b", i, j, gt);
                    errors = errors + 1;
                end
            end
        end

        if (errors == 0) begin
            $display("===============================================================");
            $display(">>> Simulacion de gt4_tb exitosa: 256 casos sin errores. <<<");
            $display("===============================================================");
        end else begin
            $display(">>> Simulacion finalizada con %0d errores. <<<", errors);
        end

        $stop;
    end
endmodule
