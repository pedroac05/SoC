`timescale 1ns / 1ps

// ============================================================================
// Módulo Top-Level DE1-SoC: add_subs_de1soc (Verilog)
// ============================================================================

module add_subs_de1soc (
    input  wire [9:0] SW,
    output wire [9:0] LEDR,
    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2,
    output wire [6:0] HEX3,
    output wire [6:0] HEX4,
    output wire [6:0] HEX5
);

    wire [3:0] a_in      = SW[7:4];
    wire [3:0] b_in      = SW[3:0];
    wire       add_subsn = SW[9];
    wire       cout_s;
    wire [3:0] sum_s;
    wire [4:0] res5;
    wire       is_neg;
    wire [4:0] mag;
    wire [3:0] tens_u;
    wire [3:0] units_u;
    wire [3:0] code_hex0;
    wire [3:0] code_hex1;
    wire [3:0] code_hex2;

    assign LEDR = SW;

    add_subs #(.EXTENDED_RANGE(4)) U_ADD_SUBS (
        .a(a_in), .b(b_in), .add_subsn(add_subsn),
        .cout(cout_s), .sum(sum_s)
    );

    assign res5   = {cout_s, sum_s};
    assign is_neg = (~add_subsn) & cout_s;
    assign mag    = is_neg ? (~res5 + 5'd1) : res5;

    assign tens_u = (mag >= 5'd30) ? 4'd3 :
                    (mag >= 5'd20) ? 4'd2 :
                    (mag >= 5'd10) ? 4'd1 : 4'd0;

    assign units_u = (mag >= 5'd30) ? (mag - 5'd30) :
                     (mag >= 5'd20) ? (mag - 5'd20) :
                     (mag >= 5'd10) ? (mag - 5'd10) : mag[3:0];

    assign code_hex0 = units_u;
    assign code_hex1 = (tens_u == 4'd0) ? 4'b1111 : tens_u;
    assign code_hex2 = is_neg ? 4'b1010 : 4'b1111;

    sevenSegmentDecoder U_HEX0 (.code(code_hex0), .seg(HEX0));
    sevenSegmentDecoder U_HEX1 (.code(code_hex1), .seg(HEX1));
    sevenSegmentDecoder U_HEX2 (.code(code_hex2), .seg(HEX2));

    assign HEX3 = 7'b1111111;
    assign HEX4 = 7'b1111111;
    assign HEX5 = 7'b1111111;

endmodule
