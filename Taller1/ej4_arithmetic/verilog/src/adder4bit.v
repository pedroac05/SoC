`timescale 1ns / 1ps

module adder4bit (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       cin,
    output wire [3:0] s,
    output wire       cout
);

    wire [3:1] c;

    // Etapa 0: LSB
    full_adder_mux fa0 (
        .a(a[0]),
        .b(b[0]),
        .cin(cin),
        .s(s[0]),
        .cout(c[1])
    );

    // Etapa 1
    full_adder_mux fa1 (
        .a(a[1]),
        .b(b[1]),
        .cin(c[1]),
        .s(s[1]),
        .cout(c[2])
    );

    // Etapa 2
    full_adder_mux fa2 (
        .a(a[2]),
        .b(b[2]),
        .cin(c[2]),
        .s(s[2]),
        .cout(c[3])
    );

    // Etapa 3: MSB
    full_adder_mux fa3 (
        .a(a[3]),
        .b(b[3]),
        .cin(c[3]),
        .s(s[3]),
        .cout(cout)
    );

endmodule
