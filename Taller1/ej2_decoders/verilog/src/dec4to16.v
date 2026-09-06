`timescale 1ns / 1ps

module dec4to16 (
    input  wire        en,
    input  wire [3:0]  in_v,
    output wire [15:0] bcode
);

    // Bus interno de habilitación
    wire [3:0] en_bus;

    // 1. Decodificador de control (Nivel 1): Decodifica in_v[3:2]
    dec2to4 u_dec_ctrl (
        .en(en),
        .in_v(in_v[3:2]),
        .bcode(en_bus)
    );

    // 2. Decodificadores de datos (Nivel 2): Decodifican in_v[1:0]
    dec2to4 u_dec0 (
        .en(en_bus[0]),
        .in_v(in_v[1:0]),
        .bcode(bcode[3:0])
    );

    dec2to4 u_dec1 (
        .en(en_bus[1]),
        .in_v(in_v[1:0]),
        .bcode(bcode[7:4])
    );

    dec2to4 u_dec2 (
        .en(en_bus[2]),
        .in_v(in_v[1:0]),
        .bcode(bcode[11:8])
    );

    dec2to4 u_dec3 (
        .en(en_bus[3]),
        .in_v(in_v[1:0]),
        .bcode(bcode[15:12])
    );

endmodule
