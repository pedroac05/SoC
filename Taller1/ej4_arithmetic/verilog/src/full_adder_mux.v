`timescale 1ns / 1ps

module full_adder_mux (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire s,
    output wire cout
);

    wire [1:0] sel_ab;
    wire [3:0] d_sum;
    wire [3:0] d_cout;
    wire       not_cin;

    assign sel_ab  = {a, b};
    assign not_cin = ~cin;

    // Entradas de datos para la SUMA (S):
    // AB = 00 -> S = cin
    // AB = 01 -> S = ~cin
    // AB = 10 -> S = ~cin
    // AB = 11 -> S = cin
    assign d_sum[0] = cin;
    assign d_sum[1] = not_cin;
    assign d_sum[2] = not_cin;
    assign d_sum[3] = cin;

    // Entradas de datos para el ACARREO (Cout):
    // AB = 00 -> Cout = 1'b0
    // AB = 01 -> Cout = cin
    // AB = 10 -> Cout = cin
    // AB = 11 -> Cout = 1'b1
    assign d_cout[0] = 1'b0;
    assign d_cout[1] = cin;
    assign d_cout[2] = cin;
    assign d_cout[3] = 1'b1;

    // Instancia MUX para Suma (S)
    mux4to1 u_mux_sum (
        .d(d_sum),
        .sel(sel_ab),
        .y(s)
    );

    // Instancia MUX para Acarreo (Cout)
    mux4to1 u_mux_cout (
        .d(d_cout),
        .sel(sel_ab),
        .y(cout)
    );

endmodule
