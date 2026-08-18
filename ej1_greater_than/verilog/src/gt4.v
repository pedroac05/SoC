`timescale 1ns / 1ps

module gt4 (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire       gt
);

    // Señales internas de interconexión
    wire gt_high;
    wire eq_high;
    wire gt_low;

    // Comparación de los bits más significativos (MSBs: bits 3 y 2)
    gt2 u_gt_high (
        .a(a[3:2]),
        .b(b[3:2]),
        .gt(gt_high)
    );

    // Igualdad de los bits más significativos (MSBs: bits 3 y 2)
    eq2 u_eq_high (
        .a(a[3:2]),
        .b(b[3:2]),
        .eq(eq_high)
    );

    // Comparación de los bits menos significativos (LSBs: bits 1 y 0)
    gt2 u_gt_low (
        .a(a[1:0]),
        .b(b[1:0]),
        .gt(gt_low)
    );

    // Lógica combinacional de salida: a > b si (a_high > b_high) o (a_high == b_high y a_low > b_low)
    assign gt = gt_high | (eq_high & gt_low);

endmodule
