`timescale 1ns / 1ps

module adder4bit_tb;
    reg  [3:0] a;
    reg  [3:0] b;
    reg        cin;
    wire [3:0] s;
    wire       cout;

    integer i, j, c_val;
    integer errors = 0;
    reg [4:0] expected_full;

    adder4bit dut (
        .a(a),
        .b(b),
        .cin(cin),
        .s(s),
        .cout(cout)
    );

    initial begin
        a   = 4'b0000;
        b   = 4'b0000;
        cin = 1'b0;

        $display("----------------------------------------------------------------------");
        $display(" INICIO DE SIMULACION: adder4bit_tb (Sumador 4 bits basado en MUX)");
        $display("----------------------------------------------------------------------");

        // FASE 1: 10 VECTORES DE PRUEBA ESPECÍFICOS Y OVERFLOW
        // 1. Cero + Cero
        a = 4'd0; b = 4'd0; cin = 1'b0; #20;
        check_result(1, 0, 0, 0);

        // 2. Suma simple sin acarreo (3 + 4 = 7)
        a = 4'd3; b = 4'd4; cin = 1'b0; #20;
        check_result(2, 3, 4, 0);

        // 3. Suma con Cin (2 + 3 + 1 = 6)
        a = 4'd2; b = 4'd3; cin = 1'b1; #20;
        check_result(3, 2, 3, 1);

        // 4. Acarreo interno (7 + 1 = 8)
        a = 4'd7; b = 4'd1; cin = 1'b0; #20;
        check_result(4, 7, 1, 0);

        // 5. Máximo sin overflow (10 + 5 = 15)
        a = 4'd10; b = 4'd5; cin = 1'b0; #20;
        check_result(5, 10, 5, 0);

        // 6. OVERFLOW básico (15 + 1 = 16 => S=0, Cout=1)
        a = 4'd15; b = 4'd1; cin = 1'b0; #20;
        check_result(6, 15, 1, 0);

        // 7. OVERFLOW valores medios (8 + 9 = 17 => S=1, Cout=1)
        a = 4'd8; b = 4'd9; cin = 1'b0; #20;
        check_result(7, 8, 9, 0);

        // 8. OVERFLOW con Cin (12 + 4 + 1 = 17 => S=1, Cout=1)
        a = 4'd12; b = 4'd4; cin = 1'b1; #20;
        check_result(8, 12, 4, 1);

        // 9. Simétrico (9 + 9 = 18 => S=2, Cout=1)
        a = 4'd9; b = 4'd9; cin = 1'b0; #20;
        check_result(9, 9, 9, 0);

        // 10. Máximo desbordamiento (15 + 15 + 1 = 31 => S=15, Cout=1)
        a = 4'd15; b = 4'd15; cin = 1'b1; #20;
        check_result(10, 15, 15, 1);

        // FASE 2: VERIFICACIÓN EXHAUSTIVA TOTAL (512 COMBINACIONES)
        for (c_val = 0; c_val < 2; c_val = c_val + 1) begin
            for (i = 0; i < 16; i = i + 1) begin
                for (j = 0; j < 16; j = j + 1) begin
                    a   = i[3:0];
                    b   = j[3:0];
                    cin = c_val[0];
                    #20;

                    expected_full = i + j + c_val;
                    if ({cout, s} !== expected_full) begin
                        $display("ERROR en a=%0d, b=%0d, cin=%b => Esperado {Cout,S}=%b, Obtenido=%b",
                                 i, j, cin, expected_full, {cout, s});
                        errors = errors + 1;
                    end
                end
            end
        end

        $display("----------------------------------------------------------------------");
        if (errors == 0) begin
            $display(">>> Simulacion de adder4bit_tb exitosa: 512 casos evaluados sin errores. <<<");
            $display(">>> Se verificaron correctamente condiciones normales y OVERFLOW. <<<");
        end else begin
            $display(">>> Simulacion finalizada con %0d errores detectados. <<<", errors);
        end
        $display("----------------------------------------------------------------------");

        $stop;
    end

    task check_result;
        input integer test_num;
        input integer in_a;
        input integer in_b;
        input integer in_cin;
        reg [4:0] exp;
        begin
            exp = in_a + in_b + in_cin;
            if ({cout, s} !== exp) begin
                $display("ERROR en Test %0d: %0d + %0d + cin(%0d) => Esperado=%b, Obtenido={%b, %b}",
                         test_num, in_a, in_b, in_cin, exp, cout, s);
                errors = errors + 1;
            end else begin
                $display("Test %0d [OK]: %0d + %0d + cin(%0d) = %0d => {Cout, S} = {%b, %b}",
                         test_num, in_a, in_b, in_cin, exp, cout, s);
            end
        end
    endtask

endmodule
