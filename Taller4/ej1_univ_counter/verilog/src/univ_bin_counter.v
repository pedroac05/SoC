// ==============================================================================
// Pontificia Universidad Javeriana - Departamento de Electronica
// System on Chip (SoC) - Taller 4: Circuitos Secuenciales (Contadores)
// Modulo: univ_bin_counter (Contador Binario Universal Parametrizable)
// ==============================================================================
// Caracteristicas:
//   * N         : Ancho del registro contador en bits (default = 4).
//   * MAX_COUNT : Valor maximo de conteo (default = 2^N - 1).
//   * Prioridad de control: rst (asincrono) > syn_clr > load > ena (up/down).
//   * Banderas  : max_tick = 1 cuando counter == MAX_COUNT;
//                 min_tick = 1 cuando counter == 0.
// ==============================================================================

module univ_bin_counter #(
    parameter integer N = 4,
    parameter [N-1:0] MAX_COUNT = {N{1'b1}}
) (
    input  wire         clk,
    input  wire         rst,
    input  wire         ena,
    input  wire         syn_clr,
    input  wire         load,
    input  wire         up,
    input  wire [N-1:0] d,
    output wire         max_tick,
    output wire         min_tick,
    output wire [N-1:0] counter
);

    localparam [N-1:0] ZEROS = {N{1'b0}};

    reg  [N-1:0] count_s;
    reg  [N-1:0] count_next;

    // --------------------------------------------------------------------------
    // 1. Registro de estado secuencial (flanco ascendente de clk, reset asincrono)
    // --------------------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst)
            count_s <= ZEROS;
        else
            count_s <= count_next;
    end

    // --------------------------------------------------------------------------
    // 2. Logica combinacional de estado siguiente
    //    Prioridad: syn_clr > load > (ena & up) > (ena & ~up) > hold
    // --------------------------------------------------------------------------
    always @(*) begin
        if (syn_clr)
            count_next = ZEROS;
        else if (load)
            count_next = d;
        else if (ena && up)
            count_next = (count_s == MAX_COUNT) ? ZEROS : (count_s + 1'b1);
        else if (ena && !up)
            count_next = (count_s == ZEROS) ? MAX_COUNT : (count_s - 1'b1);
        else
            count_next = count_s;
    end

    // --------------------------------------------------------------------------
    // 3. Logica de salida y banderas de fin de conteo
    // --------------------------------------------------------------------------
    assign counter  = count_s;
    assign max_tick = (count_s == MAX_COUNT) ? 1'b1 : 1'b0;
    assign min_tick = (count_s == ZEROS)     ? 1'b1 : 1'b0;

endmodule
