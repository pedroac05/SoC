module gt2 (
    input  wire [1:0] a,
    input  wire [1:0] b,
    output wire       gt
);

    // Función SOP obtenida para 2 bits
    assign gt = (a[1] & ~b[1]) |
                (a[1] & a[0] & ~b[0]) |
                (a[0] & ~b[1] & ~b[0]);

endmodule
