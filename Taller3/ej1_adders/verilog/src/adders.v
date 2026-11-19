`timescale 1ns / 1ps

// ============================================================================
// Módulo: adders (Verilog)
// Instancia dos sumadores parametrizables add_w_carry en paralelo
// con anchos SMALL y LARGE (equivalente a adders.vhd)
// ============================================================================

module adders #(
    parameter LARGE = 16,
    parameter SMALL = 8
)(
    input  wire [SMALL-1:0] a,
    input  wire [SMALL-1:0] b,
    input  wire [LARGE-1:0] c,
    input  wire [LARGE-1:0] d,
    output wire             cout8,
    output wire [SMALL-1:0] sum8,
    output wire             cout16,
    output wire [LARGE-1:0] sum16
);

    add_w_carry #(
        .EXTENDED_RANGE(SMALL)
    ) adder_8bits (
        .a    (a),
        .b    (b),
        .cout (cout8),
        .sum  (sum8)
    );

    add_w_carry #(
        .EXTENDED_RANGE(LARGE)
    ) adder_16bits (
        .a    (c),
        .b    (d),
        .cout (cout16),
        .sum  (sum16)
    );

endmodule
