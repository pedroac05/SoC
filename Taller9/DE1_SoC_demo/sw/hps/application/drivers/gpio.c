#include "gpio.h"

/*
 * Tabla de busqueda para displays 7-segmentos (logica activa en bajo, DE1-SoC)
 * Bits [6:0] -> segmentos [g, f, e, d, c, b, a]
 */
static const unsigned char HEX_LUT[16] = {
    0x40, /* 0 */
    0x79, /* 1 */
    0x24, /* 2 */
    0x30, /* 3 */
    0x19, /* 4 */
    0x12, /* 5 */
    0x02, /* 6 */
    0x78, /* 7 */
    0x00, /* 8 */
    0x10, /* 9 */
    0x08, /* A */
    0x03, /* b */
    0x46, /* C */
    0x21, /* d */
    0x06, /* E */
    0x0E  /* F */
};

/*
 * Convierte un digito hexadecimal (0..15) en su patron de 7 segmentos
 * (activo en bajo). Retorna display apagado (0xFF) si esta fuera de rango.
 */
unsigned char sseg_conv_hex(int hex) {
    if (hex >= 0 && hex < 16) {
        return HEX_LUT[hex];
    }
    return SSEG_BLANK_PTN;
}

/*
 * Escribe un patron de 7 segmentos directamente en el PIO del display indicado.
 */
void sseg_disp_ptn(volatile int *hex_base, unsigned char ptn) {
    pio_write(hex_base, (int)ptn);
}
