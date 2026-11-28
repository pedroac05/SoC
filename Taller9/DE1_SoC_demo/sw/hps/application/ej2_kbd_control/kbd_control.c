#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>
#include <termios.h>
#include <sys/select.h>
#include <sys/mman.h>

#include "hps_soc_system.h"
#include "drivers/gpio.h"
#include "drivers/timer_driver.h"

/* Bridge Lightweight HPS-to-FPGA (Cyclone V SoC) */
#define HW_REGS_BASE    (0xFF200000)
#define HW_REGS_SPAN    (0x00200000)

#define DEFAULT_PRD_MS  500

typedef struct {
    int pause;
    int prd;
} cmd_type;

static volatile sig_atomic_t g_running = 1;
static struct termios g_orig_termios;
static int g_termios_saved = 0;

static void restore_terminal(void) {
    if (g_termios_saved) {
        tcsetattr(STDIN_FILENO, TCSANOW, &g_orig_termios);
        g_termios_saved = 0;
    }
}

static void enable_raw_nonblocking_terminal(void) {
    struct termios raw;

    if (tcgetattr(STDIN_FILENO, &g_orig_termios) == 0) {
        g_termios_saved = 1;
        atexit(restore_terminal);

        raw = g_orig_termios;
        /* Desactivar modo canonico y eco para leer teclas al instante */
        raw.c_lflag &= ~(ICANON | ECHO);
        raw.c_cc[VMIN]  = 0;
        raw.c_cc[VTIME] = 0;
        tcsetattr(STDIN_FILENO, TCSANOW, &raw);
    }
}

static void handle_sigint(int sig) {
    (void)sig;
    g_running = 0;
}

/* Retorna 1 si hay un caracter disponible en stdin (sin bloquear) y lo guarda en *ch */
static int kbd_poll_char(char *ch) {
    fd_set readfds;
    struct timeval tv;

    FD_ZERO(&readfds);
    FD_SET(STDIN_FILENO, &readfds);
    tv.tv_sec  = 0;
    tv.tv_usec = 0;

    if (select(STDIN_FILENO + 1, &readfds, NULL, NULL, &tv) > 0) {
        if (read(STDIN_FILENO, ch, 1) == 1) {
            return 1;
        }
    }
    return 0;
}

/* ============================================================================
 * Nivel 2 — Rutinas de Tareas (Seccion 6.2: Control Total por Teclado)
 * ========================================================================== */

void flashsys_init(volatile int *btn_base, volatile int *timer_base) {
    btn_clear(btn_base);
    timer_wr_prd(timer_base, TIMER_1MS_CYCLES);
}

/*
 * Procesa comandos del teclado del PC (reemplazando los pulsadores fisicos):
 *   'C' -> clear (detiene intermitencia, apaga LEDs y reinicia periodo a 0)
 *   'S' -> start (inicia/reanuda intermitencia; si prd==0 carga SW[9:0] o 500 ms)
 *   'P' -> pause (pausa la intermitencia y muestra 'P' en HEX3)
 *   Cualquier otro caracter es ignorado.
 */
void kbd_get_command(volatile int *sw_base, volatile int *led_base, cmd_type *cmd) {
    char ch;

    while (kbd_poll_char(&ch)) {
        switch (ch) {
            case 'C':
                cmd->pause = 1;
                cmd->prd   = 0;
                pio_write(led_base, 0x00);
                printf("[KBD 'C'] CLEAR -> LEDs apagados, periodo = 0 ms, sistema pausado\n");
                fflush(stdout);
                break;

            case 'S':
                if (cmd->prd <= 0) {
                    int sw_val = pio_read(sw_base) & 0x3FF;
                    cmd->prd = (sw_val > 0) ? sw_val : DEFAULT_PRD_MS;
                }
                cmd->pause = 0;
                printf("[KBD 'S'] START -> intermitencia activa (periodo = %d ms)\n", cmd->prd);
                fflush(stdout);
                break;

            case 'P':
                cmd->pause = 1;
                printf("[KBD 'P'] PAUSE -> sistema pausado\n");
                fflush(stdout);
                break;

            default:
                /* Cualquier otro caracter es ignorado */
                break;
        }
    }
}

void display_msg(cmd_type cmd) {
    static int current = -1;

    if (cmd.prd != current) {
        printf("New Interval: %d ms\n", cmd.prd);
        fflush(stdout);
        current = cmd.prd;
    }
}

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

/*
 * Alterna LEDR[1:0] y espera cmd->prd ticks de 1 ms consultando el teclado en
 * cada tick para responder de inmediato a 'P', 'C' o 'S'.
 */
void led_flash_kbd(volatile int *led_base, volatile int *sw_base,
                   volatile int *timer_base, cmd_type *cmd) {
    static unsigned char led_ptn = 0x01;
    int ticks;

    if (cmd->pause || cmd->prd <= 0) {
        /* Esperar 1 tick de 1 ms para evitar saturar la CPU en pausa */
        while (timer_read_tick(timer_base) == 0 && g_running) {
        }
        timer_clear_tick(timer_base);
        return;
    }

    led_ptn ^= 0x03;
    pio_write(led_base, led_ptn);

    for (ticks = 0; ticks < cmd->prd && g_running && !cmd->pause; ticks++) {
        while (timer_read_tick(timer_base) == 0 && g_running) {
        }
        timer_clear_tick(timer_base);

        /* Revisar teclado en cada milisegundo para respuesta inmediata */
        kbd_get_command(sw_base, led_base, cmd);
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

    cmd_type kbd_cmd = {1, DEFAULT_PRD_MS}; /* Inicia en pausa esperando 'S' */

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

    printf("=== Taller 9 - Ejercicio 2: Control Total por Teclado ===\n");
    printf("  'S' : Start  (iniciar / reanudar intermitencia)\n");
    printf("  'P' : Pause  (pausar intermitencia, muestra 'P' en HEX3)\n");
    printf("  'C' : Clear  (detener, apagar LEDs y reiniciar periodo a 0)\n");
    printf("  (Cualquier otro caracter sera ignorado. Ctrl+C para salir.)\n\n");
    fflush(stdout);

    enable_raw_nonblocking_terminal();
    flashsys_init(btn_base, usr_timer_base);
    pio_write(led_base, 0x00);
    sseg_disp_ptn(hex4_base, SSEG_BLANK_PTN);
    sseg_disp_ptn(hex5_base, SSEG_BLANK_PTN);

    while (g_running) {
        kbd_get_command(sw_base, led_base, &kbd_cmd);
        display_msg(kbd_cmd);
        sseg_display_msg(hex0_base, hex1_base, hex2_base, hex3_base, kbd_cmd);
        led_flash_kbd(led_base, sw_base, usr_timer_base, &kbd_cmd);
    }

    restore_terminal();
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
