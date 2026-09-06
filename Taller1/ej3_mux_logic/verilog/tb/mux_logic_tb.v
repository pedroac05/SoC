`timescale 1ns / 1ps

module mux_logic_tb;
    reg  x1;
    reg  x2;
    reg  x3;
    reg  x4;
    wire f_gate;
    wire f_mux;
    wire match_out;

    integer i;
    integer errors = 0;
    reg [3:0] vec_in;
    reg       expected_val;

    mux_logic_top dut (
        .x1(x1),
        .x2(x2),
        .x3(x3),
        .x4(x4),
        .f_gate(f_gate),
        .f_mux(f_mux),
        .match_out(match_out)
    );

    initial begin
        x1 = 1'b0;
        x2 = 1'b0;
        x3 = 1'b0;
        x4 = 1'b0;

        $display("----------------------------------------------------------------------");
        $display(" INICIO DE SIMULACION: mux_logic_tb (Comparacion Gate-Level vs MUX)");
        $display("----------------------------------------------------------------------");

        for (i = 0; i < 16; i = i + 1) begin
            vec_in = i[3:0];
            x1 = vec_in[3];
            x2 = vec_in[2];
            x3 = vec_in[1];
            x4 = vec_in[0];

            // Paridad par: esperado = 1 si cantidad de unos es par, 0 si impar
            expected_val = ~^{x1, x2, x3, x4};

            #20;

            if (f_gate !== expected_val) begin
                $display("ERROR en f_gate: Vector=%b => Esperado=%b, Obtenido=%b", vec_in, expected_val, f_gate);
                errors = errors + 1;
            end

            if (f_mux !== expected_val) begin
                $display("ERROR en f_mux: Vector=%b => Esperado=%b, Obtenido=%b", vec_in, expected_val, f_mux);
                errors = errors + 1;
            end

            if (match_out !== 1'b1) begin
                $display("DESAJUSTE: f_gate (%b) != f_mux (%b) en Vector=%b", f_gate, f_mux, vec_in);
                errors = errors + 1;
            end
        end

        $display("----------------------------------------------------------------------");
        if (errors == 0) begin
            $display(">>> Simulacion de mux_logic_tb exitosa: 16 vectores evaluados sin errores. <<<");
            $display(">>> Se comprobo coincidencia del 100%% entre Gate-Level y MUX-based. <<<");
        end else begin
            $display(">>> Simulacion finalizada con %0d errores detectados. <<<", errors);
        end
        $display("----------------------------------------------------------------------");

        $stop;
    end

endmodule
