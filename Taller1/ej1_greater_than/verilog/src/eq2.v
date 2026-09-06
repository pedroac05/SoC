`timescale 1ns / 1ps

module eq2 (
    input  wire [1:0] a,
    input  wire [1:0] b,
    output wire       eq
);

    // Igualdad a nivel compuerta: (a1 ~^ b1) & (a0 ~^ b0)
    assign eq = (a[1] ~^ b[1]) & (a[0] ~^ b[0]);

endmodule
