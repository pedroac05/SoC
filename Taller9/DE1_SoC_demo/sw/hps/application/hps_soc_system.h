#ifndef _ALTERA_HPS_SOC_SYSTEM_H_
#define _ALTERA_HPS_SOC_SYSTEM_H_

/*
 * Plantilla de direcciones base para Taller 9 (referencia Figura 7).
 * NOTA: Al ejecutar ./create_linux_changehw.sh en el Embedded Command Shell
 * de Intel SoC EDS (en Linux), este archivo sera regenerado automaticamente
 * a partir de hw/quartus/soc_system.sopcinfo.
 */

#define USR_TIMER_BASE  0x0000
#define USR_TIMER_SPAN  32
#define USR_TIMER_END   0x001f

#define SYS_TIMER_BASE  0x0020
#define SYS_TIMER_SPAN  32
#define SYS_TIMER_END   0x003f

#define HEX_5_BASE      0x0040
#define HEX_4_BASE      0x0050
#define HEX_3_BASE      0x0060
#define HEX_2_BASE      0x0070
#define HEX_1_BASE      0x0080
#define HEX_0_BASE      0x0090

#define BUTTONS_0_BASE  0x00a0
#define SWITCHES_0_BASE 0x00b0
#define LEDS_0_BASE     0x00c0

#endif /* _ALTERA_HPS_SOC_SYSTEM_H_ */
