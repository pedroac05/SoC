`timescale 1ns / 1ps

module mux_logic_top (
    input  wire x1,
    input  wire x2,
    input  wire x3,
    input  wire x4,
    output wire f_gate,
    output wire f_mux,
    output wire match_out
);

    // Instancia del módulo a nivel compuertas
    mux_logic_gate u_gate (
        .x1(x1),
        .x2(x2),
        .x3(x3),
        .x4(x4),
        .f(f_gate)
    );

    // Instancia del módulo basado en Multiplexor
    mux_logic_mux u_mux_impl (
        .x1(x1),
        .x2(x2),
        .x3(x3),
        .x4(x4),
        .f(f_mux)
    );

    // Verificación de coincidencia
    assign match_out = ~(f_gate ^ f_mux);

endmodule
