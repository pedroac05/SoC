`timescale 1ns / 1ps

module dec4to16_tb;
    reg         en;
    reg  [3:0]  in_v;
    wire [15:0] bcode;

    integer i;
    integer errors = 0;
    reg [15:0] expected_val;

    dec4to16 dut (
        .en(en),
        .in_v(in_v),
        .bcode(bcode)
    );

    initial begin
        en   = 1'b0;
        in_v = 4'b0000;

        // Caso 1: Enable desactivado (en = 0) -> Salida esperada 0000h
        en = 1'b0;
        for (i = 0; i < 16; i = i + 1) begin
            in_v = i;
            #20;
            if (bcode !== 16'h0000) begin
                $display("ERROR en en=0, in_v=%0d => Esperado=0000h, Obtenido=%h", i, bcode);
                errors = errors + 1;
            end
        end

        // Caso 2: Enable activado (en = 1) -> Decodificación One-Hot de 16 bits
        en = 1'b1;
        for (i = 0; i < 16; i = i + 1) begin
            in_v = i;
            expected_val = 16'h0001 << i;
            #20;
            if (bcode !== expected_val) begin
                $display("ERROR en en=1, in_v=%0d => Esperado=%h, Obtenido=%h", i, expected_val, bcode);
                errors = errors + 1;
            end
        end

        if (errors == 0) begin
            $display("================================================================");
            $display(">>> Simulacion de dec4to16_tb exitosa: 0 errores encontrados. <<<");
            $display("================================================================");
        end else begin
            $display(">>> Simulacion finalizada con %0d errores. <<<", errors);
        end

        $stop;
    end
endmodule
