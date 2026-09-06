`timescale 1ns / 1ps

module dec3to8 (
    input  wire       en,
    input  wire [2:0] in_v,
    output wire [7:0] bcode
);

    wire en_low;
    wire en_high;

    // Decodificación del MSB (in_v[2]) para habilitar el bloque inferior o superior
    assign en_low  = en & ~in_v[2];
    assign en_high = en &  in_v[2];

    // Instancia bloque inferior: maneja salidas bcode[3:0] cuando in_v[2] == 0
    dec2to4 u_dec_low (
        .en(en_low),
        .in_v(in_v[1:0]),
        .bcode(bcode[3:0])
    );

    // Instancia bloque superior: maneja salidas bcode[7:4] cuando in_v[2] == 1
    dec2to4 u_dec_high (
        .en(en_high),
        .in_v(in_v[1:0]),
        .bcode(bcode[7:4])
    );

endmodule
