`timescale 1ns / 1ps

// ============================================================================
// Testbench: add_subs_tb (Verilog)
// Verifica los mismos 10 vectores de suma y resta cada 20 ns que en VHDL
// ============================================================================

module add_subs_tb;

    localparam C_RANGE = 4;

    reg  [C_RANGE-1:0] a_tb;
    reg  [C_RANGE-1:0] b_tb;
    reg                add_subsn_tb;
    wire               cout_tb;
    wire [C_RANGE-1:0] sum_tb;
    wire [C_RANGE:0]   res5_tb;

    integer idx;
    integer errors = 0;

    reg [C_RANGE-1:0] vec_a  [0:9];
    reg [C_RANGE-1:0] vec_b  [0:9];
    reg               vec_op [0:9];

    reg        [C_RANGE:0] exp_u;
    reg signed [C_RANGE:0] exp_s;

    add_subs #(
        .EXTENDED_RANGE(C_RANGE)
    ) DUT (
        .a         (a_tb),
        .b         (b_tb),
        .add_subsn (add_subsn_tb),
        .cout      (cout_tb),
        .sum       (sum_tb)
    );

    assign res5_tb = {cout_tb, sum_tb};

    initial begin
        vec_a[0] = 4'd5;  vec_b[0] = 4'd3;  vec_op[0] = 1'b1; //  5 +  3 = +8
        vec_a[1] = 4'd5;  vec_b[1] = 4'd3;  vec_op[1] = 1'b0; //  5 -  3 = +2
        vec_a[2] = 4'd3;  vec_b[2] = 4'd5;  vec_op[2] = 1'b0; //  3 -  5 = -2
        vec_a[3] = 4'd15; vec_b[3] = 4'd15; vec_op[3] = 1'b1; // 15 + 15 = 30
        vec_a[4] = 4'd13; vec_b[4] = 4'd2;  vec_op[4] = 1'b1; // 13 +  2 = 15
        vec_a[5] = 4'd7;  vec_b[5] = 4'd15; vec_op[5] = 1'b0; //  7 - 15 = -8
        vec_a[6] = 4'd1;  vec_b[6] = 4'd15; vec_op[6] = 1'b0; //  1 - 15 = -14
        vec_a[7] = 4'd0;  vec_b[7] = 4'd15; vec_op[7] = 1'b0; //  0 - 15 = -15
        vec_a[8] = 4'd15; vec_b[8] = 4'd0;  vec_op[8] = 1'b0; // 15 -  0 = +15
        vec_a[9] = 4'd9;  vec_b[9] = 4'd9;  vec_op[9] = 1'b0; //  9 -  9 =  0

        $display("================ INICIO TESTBENCH ADD_SUBS (VERILOG) ================");

        for (idx = 0; idx < 10; idx = idx + 1) begin
            a_tb         = vec_a[idx];
            b_tb         = vec_b[idx];
            add_subsn_tb = vec_op[idx];
            #20;

            if (vec_op[idx] == 1'b1) begin
                exp_u = {1'b0, vec_a[idx]} + {1'b0, vec_b[idx]};
                if (res5_tb !== exp_u) begin
                    $display("ERROR SUMA: a=%0d, b=%0d => Esperado=%0d, Obtenido=%0d",
                             vec_a[idx], vec_b[idx], exp_u, res5_tb);
                    errors = errors + 1;
                end
            end else begin
                exp_s = $signed({1'b0, vec_a[idx]}) - $signed({1'b0, vec_b[idx]});
                if ($signed(res5_tb) !== exp_s) begin
                    $display("ERROR RESTA: a=%0d, b=%0d => Esperado=%0d, Obtenido=%0d",
                             vec_a[idx], vec_b[idx], exp_s, $signed(res5_tb));
                    errors = errors + 1;
                end
            end
        end

        if (errors == 0)
            $display(">> VERIFICACION EXITOSA: Todos los casos de suma y resta pasaron sin errores!");
        else
            $display(">> VERIFICACION CON FALLAS: Total errores = %0d", errors);
    end

endmodule
