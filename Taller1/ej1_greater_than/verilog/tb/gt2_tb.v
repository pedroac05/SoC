`timescale 1ns / 1ps

module gt2_tb;
    reg  [1:0] a;
    reg  [1:0] b;
    wire       gt;

    integer i, j;

    gt2 dut (
        .a(a),
        .b(b),
        .gt(gt)
    );

    initial begin
        a = 2'b00;
        b = 2'b00;

        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                a = i[1:0];
                b = j[1:0];
                #20;
                if (i > j) begin
                    if (gt !== 1'b1)
                        $display("ERROR: Esperaba gt=1 en a=%0d, b=%0d", i, j);
                end else begin
                    if (gt !== 1'b0)
                        $display("ERROR: Esperaba gt=0 en a=%0d, b=%0d", i, j);
                end
            end
        end

        $display(">>> Simulación Verilog finalizada exitosamente <<<");
        $stop;
    end

endmodule
