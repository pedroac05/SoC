#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/mman.h>

#include "hps_soc_system.h"
#include "drivers/gpio.h"
#include "drivers/timer_driver.h"

/* Bridge Lightweight HPS-to-FPGA (Cyclone V SoC) */
#define HW_REGS_BASE    (0xFF200000)
#define HW_REGS_SPAN    (0x00200000)

/* Estructura de comando compartida entre las rutinas de tareas */
typedef struct {
    int pause;
    int prd;
} cmd_type;

static volatile sig_atomic_t g_running = 1;

static void handle_sigint(int sig) {
    (void)sig;
    g_running = 0;
}

/* ============================================================================
 * Nivel 2 — Rutinas de Tareas
 * ========================================================================== */

/* Inicializa el sistema: limpia edgecapture de botones y configura usr_timer a 1 ms */
void flashsys_init(volatile int *btn_base, volatile int *timer_base) {
    btn_clear(btn_base);
    timer_wr_prd(timer_base, TIMER_1MS_CYCLES);
}

/* Lee comandos desde los pulsadores (KEY0: pausa/reanuda, KEY1: carga SW[9:0]) */
void sw_get_command(volatile int *btn_base, volatile int *sw_base, cmd_type *cmd) {
    int btn = btn_read(btn_base);

    if (btn != 0) {
        if (btn & 0x01) {
            /* KEY0: alternar estado de pausa */
            cmd->pause = !cmd->pause;
            printf("[KEY0] Sistema %s\n", cmd->pause ? "PAUSADO" : "EN EJECUCION");
        }
        if (btn & 0x02) {
            /* KEY1: cargar nuevo periodo desde SW[9:0] */
            cmd->prd = pio_read(sw_base) & 0x3FF;
        }
        btn_clear(btn_base);
    }
}

/* Imprime por consola SSH cada vez que cambia el periodo de intermitencia */
void display_msg(cmd_type cmd) {
    static int current = -1;

    if (cmd.prd != current) {
        printf("New Interval: %d ms\n", cmd.prd);
        fflush(stdout);
        current = cmd.prd;
    }
}

/* Despliega 'P' (si pausado) en HEX3 y el periodo en ms (0..999) en HEX2..HEX0 */
void sseg_display_msg(volatile int *hex0, volatile int *hex1,
                      volatile int *hex2, volatile int *hex3,
                      cmd_type cmd) {
    int val = cmd.prd;
    int hundreds, tens, units;

    if (val < 0) {
        val = 0;
    } else if (val > 999) {
        val = 999;
    }

    hundreds = (val / 100) % 10;
    tens     = (val / 10) % 10;
    units    = val % 10;

    sseg_disp_ptn(hex3, cmd.pause ? SSEG_CHAR_P_PTN : SSEG_BLANK_PTN);
    sseg_disp_ptn(hex2, sseg_conv_hex(hundreds));
    sseg_disp_ptn(hex1, sseg_conv_hex(tens));
    sseg_disp_ptn(hex0, sseg_conv_hex(units));
}

/* Alterna LEDR[1:0] y espera cmd.prd ticks de 1 ms usando usr_timer */
void led_flash(volatile int *led_base, volatile int *timer_base, cmd_type cmd) {
    static unsigned char led_ptn = 0x01;
    int ticks;

    if (cmd.pause) {
        return;
    }

    led_ptn ^= 0x03;
    pio_write(led_base, led_ptn);

    for (ticks = 0; ticks < cmd.prd && g_running; ticks++) {
        while (timer_read_tick(timer_base) == 0 && g_running) {
            /* Espera activa (busy-waiting) por timeout de 1 ms */
        }
        timer_clear_tick(timer_base);
    }
}

/* ============================================================================
 * Nivel 1 — Aplicacion Principal
 * ========================================================================== */
int main(void) {
    int fd;
    unsigned char *lw_bridge_base = NULL;
    volatile int *usr_timer_base  = NULL;
    volatile int *btn_base        = NULL;
    volatile int *sw_base         = NULL;
    volatile int *led_base        = NULL;
    volatile int *hex0_base       = NULL;
    volatile int *hex1_base       = NULL;
    volatile int *hex2_base       = NULL;
    volatile int *hex3_base       = NULL;
    volatile int *hex4_base       = NULL;
    volatile int *hex5_base       = NULL;

    cmd_type sw_cmd = {0, 500}; /* Estado inicial: activo, periodo = 500 ms */

    signal(SIGINT, handle_sigint);
    signal(SIGTERM, handle_sigint);

    fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd == -1) {
        fprintf(stderr, "ERROR: no se pudo abrir /dev/mem (%s)\n", strerror(errno));
        return EXIT_FAILURE;
    }

    lw_bridge_base = (unsigned char *)mmap(NULL, HW_REGS_SPAN,
                                           PROT_READ | PROT_WRITE,
                                           MAP_SHARED, fd, HW_REGS_BASE);
    if (lw_bridge_base == MAP_FAILED) {
        fprintf(stderr, "ERROR: mmap() fallo (%s)\n", strerror(errno));
        close(fd);
        return EXIT_FAILURE;
    }

    /* Direcciones virtuales de cada periferico segun hps_soc_system.h */
    usr_timer_base = (volatile int *)(lw_bridge_base + USR_TIMER_BASE);
    btn_base       = (volatile int *)(lw_bridge_base + BUTTONS_0_BASE);
    sw_base        = (volatile int *)(lw_bridge_base + SWITCHES_0_BASE);
    led_base       = (volatile int *)(lw_bridge_base + LEDS_0_BASE);
    hex0_base      = (volatile int *)(lw_bridge_base + HEX_0_BASE);
    hex1_base      = (volatile int *)(lw_bridge_base + HEX_1_BASE);
    hex2_base      = (volatile int *)(lw_bridge_base + HEX_2_BASE);
    hex3_base      = (volatile int *)(lw_bridge_base + HEX_3_BASE);
    hex4_base      = (volatile int *)(lw_bridge_base + HEX_4_BASE);
    hex5_base      = (volatile int *)(lw_bridge_base + HEX_5_BASE);

    printf("=== Taller 9: Aplicacion Base flashing_led ===\n");
    printf("  KEY0: Pausar / Reanudar intermitencia (muestra 'P' en HEX3)\n");
    printf("  KEY1: Cargar nuevo periodo en ms desde SW[9:0]\n");
    printf("  Ctrl+C para salir.\n\n");

    flashsys_init(btn_base, usr_timer_base);
    sseg_disp_ptn(hex4_base, SSEG_BLANK_PTN);
    sseg_disp_ptn(hex5_base, SSEG_BLANK_PTN);

    while (g_running) {
        sw_get_command(btn_base, sw_base, &sw_cmd);
        display_msg(sw_cmd);
        sseg_display_msg(hex0_base, hex1_base, hex2_base, hex3_base, sw_cmd);
        led_flash(led_base, usr_timer_base, sw_cmd);
    }

    /* Limpieza al salir */
    pio_write(led_base, 0x00);
    sseg_disp_ptn(hex0_base, SSEG_BLANK_PTN);
    sseg_disp_ptn(hex1_base, SSEG_BLANK_PTN);
    sseg_disp_ptn(hex2_base, SSEG_BLANK_PTN);
    sseg_disp_ptn(hex3_base, SSEG_BLANK_PTN);

    munmap((void *)lw_bridge_base, HW_REGS_SPAN);
    close(fd);
    printf("\nPrograma finalizado.\n");
    return EXIT_SUCCESS;
}
