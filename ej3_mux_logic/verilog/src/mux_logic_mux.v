`timescale 1ns / 1ps

module mux_logic_mux (
    input  wire x1,
    input  wire x2,
    input  wire x3,
    input  wire x4,
    output wire f
);

    wire [3:0] d_bus;
    wire [1:0] sel_bus;

    // Selectores: x1 como MSB y x2 como LSB
    assign sel_bus = {x1, x2};

    // Entradas de datos derivadas por partición de Shannon:
    // d(0) [00] = x3 XNOR x4
    // d(1) [01] = x3 XOR x4
    // d(2) [10] = x3 XOR x4
    // d(3) [11] = x3 XNOR x4
    assign d_bus[0] = ~(x3 ^ x4);
    assign d_bus[1] = x3 ^ x4;
    assign d_bus[2] = x3 ^ x4;
    assign d_bus[3] = ~(x3 ^ x4);

    mux4to1 u_mux (
        .d(d_bus),
        .sel(sel_bus),
        .y(f)
    );

endmodule
