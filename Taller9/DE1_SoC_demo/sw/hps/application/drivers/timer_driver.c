#include "timer_driver.h"

/*
 * Configura el periodo de conteo de 32 bits del Interval Timer y lo inicia
 * en modo continuo (control = 0x0007 -> ito=1, cont=1, start=1).
 */
void timer_wr_prd(volatile int *timer_base, int prd) {
    int low  = prd & 0xFFFF;
    int high = (prd >> 16) & 0xFFFF;

    /* Detener y limpiar bandera previa antes de cargar el nuevo periodo */
    iowr(timer_base, TIMER_CTRL_REG_OFT, 0x0008); /* stop = 1 */
    timer_clear_tick(timer_base);

    /* Escribir parte baja y parte alta del periodo de 32 bits */
    iowr(timer_base, TIMER_PRDL_REG_OFT, low);
    iowr(timer_base, TIMER_PRDH_REG_OFT, high);

    /* Iniciar en modo continuo con ito=1, cont=1, start=1 (0x0007) */
    iowr(timer_base, TIMER_CTRL_REG_OFT, 0x0007);
}
