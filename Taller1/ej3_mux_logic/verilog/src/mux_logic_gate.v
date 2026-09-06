`timescale 1ns / 1ps

module mux_logic_gate (
    input  wire x1,
    input  wire x2,
    input  wire x3,
    input  wire x4,
    output wire f
);

    wire g1;
    wire g2;

    // Implementación directa a nivel compuertas (Figura 1: 3 compuertas XNOR)
    assign g1 = ~(x1 ^ x2);
    assign g2 = ~(x3 ^ x4);
    assign f  = ~(g1 ^ g2);

endmodule
