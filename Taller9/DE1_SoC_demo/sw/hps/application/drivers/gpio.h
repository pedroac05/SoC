#ifndef GPIO_H_
#define GPIO_H_

#include <stdint.h>

/*
 * Driver para modulo Parallel I/O (altera_avalon_pio)
 * Convencion de nombres: <device_name>_<action>_<object>
 */

/* Offsets de registros internos del periferico PIO (en palabras de 32 bits) */
#define PIO_DATA_REG_OFT    0   /* Registro de datos E/S */
#define PIO_DIRT_REG_OFT    1   /* Registro de direccion (bidireccional) */
#define PIO_INTM_REG_OFT    2   /* Mascara de interrupciones IRQ */
#define PIO_EDGE_REG_OFT    3   /* Registro de captura de flanco (edgecapture) */
#define PIO_OSET_REG_OFT    4   /* Outset */
#define PIO_OCLR_REG_OFT    5   /* Outclear */

/* Patrones especiales para displays 7-segmentos (logica activa en bajo) */
#define SSEG_BLANK_PTN      0xFF
#define SSEG_CHAR_P_PTN     0x0C

/* Macros de acceso de bajo nivel a registros mapeados en memoria */
#define iord(base, offset)          (*((volatile int *)(base) + (offset)))
#define iowr(base, offset, data)    (*((volatile int *)(base) + (offset)) = (data))

/* Macros de abstraccion para PIO generico */
#define pio_read(base)              iord((base), PIO_DATA_REG_OFT)
#define pio_write(base, data)       iowr((base), PIO_DATA_REG_OFT, (data))

/* Macros de abstraccion para pulsadores (con Edge Capture Register habilitado) */
#define btn_read(base)              (iord((base), PIO_EDGE_REG_OFT) & 0x0F)
#define btn_clear(base)             iowr((base), PIO_EDGE_REG_OFT, 0x0F)
#define btn_is_pressed(base)        (btn_read(base) != 0)

/* Prototipos de funciones para displays 7-segmentos */
unsigned char sseg_conv_hex(int hex);
void sseg_disp_ptn(volatile int *hex_base, unsigned char ptn);

#endif /* GPIO_H_ */
