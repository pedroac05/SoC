`timescale 1ns / 1ps

module eq2_tb;
    reg  [1:0] a;
    reg  [1:0] b;
    wire       eq;

    integer i, j;
    integer errors = 0;

    eq2 dut (
        .a(a),
        .b(b),
        .eq(eq)
    );

    initial begin
        a = 2'b00;
        b = 2'b00;

        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                a = i;
                b = j;
                #20;
                if (i == j && eq !== 1'b1) begin
                    $display("ERROR: Esperaba eq=1 para a=%0d, b=%0d => obtenido eq=%b", i, j, eq);
                    errors = errors + 1;
                end else if (i != j && eq !== 1'b0) begin
                    $display("ERROR: Esperaba eq=0 para a=%0d, b=%0d => obtenido eq=%b", i, j, eq);
                    errors = errors + 1;
                end
            end
        end

        if (errors == 0) begin
            $display(">>> Simulacion de eq2_tb exitosa: 0 errores encontrados. <<<");
        end else begin
            $display(">>> Simulacion con %0d errores. <<<", errors);
        end

        $stop;
    end
endmodule
