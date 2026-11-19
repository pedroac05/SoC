`timescale 1ns / 1ps

// ============================================================================
// Módulo: add_subs (Verilog)
// Descripción: Sumador-Restador parametrizable asincrónico (equivalente a VHDL)
//   - add_subsn = 1 -> Suma (a + b)
//   - add_subsn = 0 -> Resta (a - b) mediante complemento a 2 en N+1 bits
// ============================================================================

module add_subs #(
    parameter EXTENDED_RANGE = 4
)(
    input  wire [EXTENDED_RANGE-1:0] a,
    input  wire [EXTENDED_RANGE-1:0] b,
    input  wire                      add_subsn, // 1 = Suma, 0 = Resta
    output wire                      cout,
    output wire [EXTENDED_RANGE-1:0] sum
);

    wire [EXTENDED_RANGE:0] a_ext;
    wire [EXTENDED_RANGE:0] b_mask;
    wire [EXTENDED_RANGE:0] b_xor;
    wire                    c_in;
    wire [EXTENDED_RANGE:0] sum_ext;

    assign a_ext  = {1'b0, a};
    assign b_mask = add_subsn ? {(EXTENDED_RANGE+1){1'b0}} : {(EXTENDED_RANGE+1){1'b1}};
    assign c_in   = add_subsn ? 1'b0 : 1'b1;

    // Compuerta XOR bit a bit + acarreo de entrada para complemento a 2
    assign b_xor   = {1'b0, b} ^ b_mask;
    assign sum_ext = a_ext + b_xor + c_in;

    assign sum  = sum_ext[EXTENDED_RANGE-1:0];
    assign cout = sum_ext[EXTENDED_RANGE];

endmodule
