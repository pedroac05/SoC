`timescale 1ns / 1ps

module dec2to4 (
    input  wire       en,
    input  wire [1:0] in_v,
    output wire [3:0] bcode
);

    // Derivación en Suma de Productos (SOP) a nivel compuerta
    assign bcode[0] = en & ~in_v[1] & ~in_v[0];
    assign bcode[1] = en & ~in_v[1] &  in_v[0];
    assign bcode[2] = en &  in_v[1] & ~in_v[0];
    assign bcode[3] = en &  in_v[1] &  in_v[0];

endmodule
