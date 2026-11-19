`timescale 1ns / 1ps

// ============================================================================
// Módulo: add_w_carry (Verilog)
// Sumador parametrizable con acarreo de salida (equivalente a add_w_carry.vhd)
// ============================================================================

module add_w_carry #(
    parameter EXTENDED_RANGE = 4
)(
    input  wire [EXTENDED_RANGE-1:0] a,
    input  wire [EXTENDED_RANGE-1:0] b,
    output wire                      cout,
    output wire [EXTENDED_RANGE-1:0] sum
);

    wire [EXTENDED_RANGE:0] a_extended;
    wire [EXTENDED_RANGE:0] b_extended;
    wire [EXTENDED_RANGE:0] sum_extended;

    assign a_extended   = {1'b0, a};
    assign b_extended   = {1'b0, b};
    assign sum_extended = a_extended + b_extended;

    assign sum  = sum_extended[EXTENDED_RANGE-1:0];
    assign cout = sum_extended[EXTENDED_RANGE];

endmodule
