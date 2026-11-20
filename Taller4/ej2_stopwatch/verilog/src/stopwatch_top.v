`timescale 1ns / 1ps

// ==============================================================================
// Pontificia Universidad Javeriana - Departamento de Electronica
// System on Chip (SoC) - Taller 4: Circuitos Secuenciales (Contadores)
// Modulo: stopwatch_top (Cronometro Digital 00.0 a 99.9 s para DE1-SoC)
// ==============================================================================

module stopwatch_top #(
    // 50 MHz * 0.1 s = 5,000,000 ciclos -> cuenta de 0 a 4,999,999
    parameter integer DIV_MAX = 4999999
) (
    input  wire       CLOCK_50,
    input  wire [1:0] SW,
    input  wire [0:0] KEY,
    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2
);

    localparam [22:0] DIV_MAX_VEC = DIV_MAX[22:0];

    // Senales de control internas
    wire rst_s     = ~SW[0];  // SW[0] = 1 habilita; 0 resetea
    wire go_s      = SW[1];   // SW[1] = 1 cuenta; 0 pausa
    wire syn_clr_s = ~KEY[0]; // KEY[0] activo en bajo

    // Pulsos en cascada
    wire tick_01s;
    wire tick_dec;
    wire tick_uni;

    wire ena_dec = go_s & tick_01s;
    wire ena_uni = ena_dec & tick_dec;
    wire ena_ten = ena_uni & tick_uni;

    // Conteos BCD
    wire [3:0] dec_s;
    wire [3:0] uni_s;
    wire [3:0] ten_s;

    // 1. Divisor de frecuencia (Mod-5,000,000 para 0.1 s @ 50 MHz)
    univ_bin_counter #(
        .N(23),
        .MAX_COUNT(DIV_MAX_VEC)
    ) u_div_01s (
        .clk(CLOCK_50),
        .rst(rst_s),
        .ena(go_s),
        .syn_clr(syn_clr_s),
        .load(1'b0),
        .up(1'b1),
        .d(23'd0),
        .max_tick(tick_01s),
        .min_tick(),
        .counter()
    );

    // 2. Contador BCD de Decimas de segundo (0..9) -> HEX0
    univ_bin_counter #(
        .N(4),
        .MAX_COUNT(4'b1001)
    ) u_cnt_dec (
        .clk(CLOCK_50),
        .rst(rst_s),
        .ena(ena_dec),
        .syn_clr(syn_clr_s),
        .load(1'b0),
        .up(1'b1),
        .d(4'd0),
        .max_tick(tick_dec),
        .min_tick(),
        .counter(dec_s)
    );

    // 3. Contador BCD de Unidades de segundo (0..9) -> HEX1
    univ_bin_counter #(
        .N(4),
        .MAX_COUNT(4'b1001)
    ) u_cnt_uni (
        .clk(CLOCK_50),
        .rst(rst_s),
        .ena(ena_uni),
        .syn_clr(syn_clr_s),
        .load(1'b0),
        .up(1'b1),
        .d(4'd0),
        .max_tick(tick_uni),
        .min_tick(),
        .counter(uni_s)
    );

    // 4. Contador BCD de Decenas de segundo (0..9) -> HEX2
    univ_bin_counter #(
        .N(4),
        .MAX_COUNT(4'b1001)
    ) u_cnt_ten (
        .clk(CLOCK_50),
        .rst(rst_s),
        .ena(ena_ten),
        .syn_clr(syn_clr_s),
        .load(1'b0),
        .up(1'b1),
        .d(4'd0),
        .max_tick(),
        .min_tick(),
        .counter(ten_s)
    );

    // 5. Decodificadores BCD a 7 segmentos (activos en bajo)
    sevenSegmentDecoder u_hex0 (.code(dec_s), .seg(HEX0));
    sevenSegmentDecoder u_hex1 (.code(uni_s), .seg(HEX1));
    sevenSegmentDecoder u_hex2 (.code(ten_s), .seg(HEX2));

endmodule
