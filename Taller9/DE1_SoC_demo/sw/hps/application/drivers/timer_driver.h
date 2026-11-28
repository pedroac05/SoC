#ifndef TIMER_DRIVER_H_
#define TIMER_DRIVER_H_

#include "gpio.h"

/*
 * Driver para modulo Interval Timer (altera_avalon_timer, 32 bits @ 50 MHz)
 * Convencion de nombres: <device_name>_<action>_<object>
 */

/* Offsets de registros internos del periferico Interval Timer (palabras 32b) */
#define TIMER_STAT_REG_OFT  0   /* status:  bit 0 = to, bit 1 = run */
#define TIMER_CTRL_REG_OFT  1   /* control: bit 0 = ito, bit 1 = cont, bit 2 = start, bit 3 = stop */
#define TIMER_PRDL_REG_OFT  2   /* period_L: bits [15:0] del periodo */
#define TIMER_PRDH_REG_OFT  3   /* period_H: bits [31:16] del periodo */
#define TIMER_SNPL_REG_OFT  4   /* snap_L:   bits [15:0] del snapshot */
#define TIMER_SNPH_REG_OFT  5   /* snap_H:   bits [31:16] del snapshot */

/* Constante de ciclos para 1 ms con reloj de 50 MHz (50,000 ciclos) */
#define TIMER_1MS_CYCLES    50000

/* Macros de consulta y limpieza de bandera de timeout (to) */
#define timer_read_tick(base)   (iord((base), TIMER_STAT_REG_OFT) & 0x01)
#define timer_clear_tick(base)  iowr((base), TIMER_STAT_REG_OFT, 0)

/* Prototipo para configurar periodo de 32 bits e iniciar en modo continuo */
void timer_wr_prd(volatile int *timer_base, int prd);

#endif /* TIMER_DRIVER_H_ */
