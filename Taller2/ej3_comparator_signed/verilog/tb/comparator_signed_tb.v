`timescale 1ns / 1ps

module comparator_signed_tb;

    // Estimulos
    reg  [3:0] a;
    reg  [3:0] b;
    reg        sig;

    // Salidas monitoreadas
    wire       lg;
    wire       eq;
    wire       ls;

    // Instancia del DUT
    comparator_signed dut (
        .a(a),
        .b(b),
        .sig(sig),
        .lg(lg),
        .eq(eq),
        .ls(ls)
    );

    integer i, j;
    reg signed [3:0] a_s, b_s;
    reg exp_lg, exp_eq, exp_ls;
    integer total_errors;

    initial begin
        total_errors = 0;
        $display("================ INICIO TESTBENCH VERILOG COMPARADOR SIGNED/UNSIGNED ================");

        // PARTE 1: Modo Unsigned (sig = 0)
        sig = 1'b0;
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                a = i[3:0];
                b = j[3:0];
                #10;

                if (a > b) begin
                    exp_lg = 1'b1; exp_eq = 1'b0; exp_ls = 1'b0;
                end else if (a == b) begin
                    exp_lg = 1'b0; exp_eq = 1'b1; exp_ls = 1'b0;
                end else begin
                    exp_lg = 1'b0; exp_eq = 1'b0; exp_ls = 1'b1;
                end

                if (lg !== exp_lg || eq !== exp_eq || ls !== exp_ls) begin
                    $display("ERROR UNSIGNED: a=%d, b=%d -> Obtenido: lg=%b, eq=%b, ls=%b (Esperado: %b %b %b)",
                             i, j, lg, eq, ls, exp_lg, exp_eq, exp_ls);
                    total_errors = total_errors + 1;
                end
            end
        end

        // PARTE 2: Modo Signed (sig = 1)
        sig = 1'b1;
        for (i = -8; i <= 7; i = i + 1) begin
            for (j = -8; j <= 7; j = j + 1) begin
                a = i[3:0];
                b = j[3:0];
                a_s = i[3:0];
                b_s = j[3:0];
                #10;

                if (a_s > b_s) begin
                    exp_lg = 1'b1; exp_eq = 1'b0; exp_ls = 1'b0;
                end else if (a_s == b_s) begin
                    exp_lg = 1'b0; exp_eq = 1'b1; exp_ls = 1'b0;
                end else begin
                    exp_lg = 1'b0; exp_eq = 1'b0; exp_ls = 1'b1;
                end

                if (lg !== exp_lg || eq !== exp_eq || ls !== exp_ls) begin
                    $display("ERROR SIGNED: a=%d, b=%d -> Obtenido: lg=%b, eq=%b, ls=%b (Esperado: %b %b %b)",
                             i, j, lg, eq, ls, exp_lg, exp_eq, exp_ls);
                    total_errors = total_errors + 1;
                end
            end
        end

        if (total_errors == 0) begin
            $display(">> VERIFICACION VERILOG EXITOSA: 512 vectores correctos sin errores!");
        end else begin
            $display(">> FALLA: Errores encontrados = %d", total_errors);
        end

        #10;
        $finish;
    end

endmodule
