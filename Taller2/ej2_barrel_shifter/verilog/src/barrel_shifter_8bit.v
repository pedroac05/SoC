`timescale 1ns / 1ps

// ============================================================================
// Ejercicio 2.2: Barrel Shifter Multietapa de 0 a 7 bits (8 bits de datos)
// Implementado mediante 3 etapas combinacionales en cascada
// ============================================================================

module barrel_shifter_8bit (
    input  wire [7:0] inp,   // Vector de entrada (8 bits)
    input  wire [2:0] shift, // Cantidad de desplazamiento (0 a 7)
    output wire [7:0] outp   // Vector de salida desplazado
);

    wire [7:0] s0; // Salida de Etapa 0 (+1 bit)
    wire [7:0] s1; // Salida de Etapa 1 (+2 bits)

    // Etapa 0: desplaza 1 bit si shift[0] == 1
    assign s0   = shift[0] ? {inp[6:0], 1'b0}   : inp;

    // Etapa 1: desplaza 2 bits si shift[1] == 1
    assign s1   = shift[1] ? {s0[5:0],  2'b00}  : s0;

    // Etapa 2: desplaza 4 bits si shift[2] == 1
    assign outp = shift[2] ? {s1[3:0],  4'b0000} : s1;

endmodule

