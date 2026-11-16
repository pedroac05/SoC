`timescale 1ns / 1ps

// ============================================================================
// Ejercicio 2.1: Barrel Shifter de 1 bit de desplazamiento (8 bits de datos)
// Implementación concurrente con operador ternario y concatenación
// ============================================================================

module barrel_shifter_1bit (
    input  wire [7:0] inp,   // Vector de entrada (8 bits)
    input  wire       shift, // Control: 0 = sin cambio, 1 = << 1
    output wire [7:0] outp   // Vector de salida desplazado
);

    assign outp = shift ? {inp[6:0], 1'b0} : inp;

endmodule

