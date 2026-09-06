`timescale 1ns / 1ps

module dec2to4_tb;
    reg        en;
    reg  [1:0] in_v;
    wire [3:0] bcode;

    integer i;
    integer errors = 0;
    reg [3:0] expected_val;

    dec2to4 dut (
        .en(en),
        .in_v(in_v),
        .bcode(bcode)
    );

    initial begin
        en   = 1'b0;
        in_v = 2'b00;

        // Caso 1: Enable desactivado (en = 0) -> Salida esperada 0000
        en = 1'b0;
        for (i = 0; i < 4; i = i + 1) begin
            in_v = i;
            #20;
            if (bcode !== 4'b0000) begin
                $display("ERROR en en=0, in_v=%0d => Esperado=0000, Obtenido=%b", i, bcode);
                errors = errors + 1;
            end
        end

        // Caso 2: Enable activado (en = 1) -> Decodificación One-Hot
        en = 1'b1;
        for (i = 0; i < 4; i = i + 1) begin
            in_v = i;
            expected_val = 4'b0001 << i;
            #20;
            if (bcode !== expected_val) begin
                $display("ERROR en en=1, in_v=%0d => Esperado=%b, Obtenido=%b", i, expected_val, bcode);
                errors = errors + 1;
            end
        end

        if (errors == 0) begin
            $display("===============================================================");
            $display(">>> Simulacion de dec2to4_tb exitosa: 0 errores encontrados. <<<");
            $display("===============================================================");
        end else begin
            $display(">>> Simulacion finalizada con %0d errores. <<<", errors);
        end

        $stop;
    end
endmodule
