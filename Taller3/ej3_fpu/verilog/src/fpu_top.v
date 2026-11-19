`timescale 1ns / 1ps

// ============================================================================
// Módulo Top-Level: fpu_top (Verilog)
// Unidad Aritmética de Punto Flotante FP32 (IEEE 754)
// Integra los 4 bloques IP (fp_add, fp_sub, fp_mul, fp_div) + MUX 4:1
// ============================================================================

module fpu_top (
    input  wire        clk,
    input  wire        areset,
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [1:0]  selop,
    output reg  [31:0] result
);

    wire [31:0] result_add;
    wire [31:0] result_sub;
    wire [31:0] result_mul;
    wire [31:0] result_div;

    fp_add U_FP_ADD (.clk(clk), .areset(areset), .a(A), .b(B), .q(result_add));
    fp_sub U_FP_SUB (.clk(clk), .areset(areset), .a(A), .b(B), .q(result_sub));
    fp_mul U_FP_MUL (.clk(clk), .areset(areset), .a(A), .b(B), .q(result_mul));
    fp_div U_FP_DIV (.clk(clk), .areset(areset), .a(A), .b(B), .q(result_div));

    // MUX 4:1 de 32 bits controlado por selop
    always @(*) begin
        case (selop)
            2'b00:   result = result_add;
            2'b01:   result = result_sub;
            2'b10:   result = result_mul;
            2'b11:   result = result_div;
            default: result = 32'h00000000;
        endcase
    end

endmodule
