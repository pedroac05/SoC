#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include "hps_soc_system.h"

// Lightweight HPS-to-FPGA bridge
#define HW_REGS_BASE (0xFF200000)
#define HW_REGS_SPAN (0x00200000)

// Active-low 7-segment lookup table (0..9, A..F)
static const unsigned int HEX_LUT[16] = {
    0x40, 0x79, 0x24, 0x30, 0x19, 0x12, 0x02, 0x78, 0x00, 0x10, // 0-9
    0x08, 0x03, 0x46, 0x21, 0x06, 0x0E                          // A-F
};

#define HEX_BLANK 0x7F

// Routine required by Section 8 of the tutorial (active-low pushbuttons)
bool is_fpga_button_pressed(int button_number, volatile unsigned int *base) {
    // buttons are active-low
    return !((*base) & (1 << button_number));
}

static void update_displays(volatile unsigned int *hex_addr[6], int value, bool hex_mode) {
    int d;
    if (!hex_mode) {
        // Decimal mode: 000000 .. 001023
        for (d = 0; d < 6; d++) {
            *hex_addr[d] = HEX_LUT[value % 10];
            value /= 10;
        }
    } else {
        // Hexadecimal mode: show 'H' (0x09) on HEX5, blank HEX4..HEX3, and 3 hex digits on HEX2..HEX0
        *hex_addr[0] = HEX_LUT[value & 0xF];
        *hex_addr[1] = HEX_LUT[(value >> 4) & 0xF];
        *hex_addr[2] = HEX_LUT[(value >> 8) & 0xF];
        *hex_addr[3] = HEX_BLANK;
        *hex_addr[4] = HEX_BLANK;
        *hex_addr[5] = 0x09; // 'H' indicator on leftmost display
    }
}

int main(void) {
    int fd;
    void *h2p_hw_virtual_base = NULL;
    volatile unsigned int *hex_addr[6];
    volatile unsigned int *h2p_hw_leds_addr   = NULL;
    volatile unsigned int *h2p_hw_button_addr = NULL;
    volatile unsigned int *h2p_hw_switch_addr = NULL;

    bool prev_btn[4] = {false, false, false, false};
    bool curr_btn[4];
    int value = 0;
    bool hex_mode = false;
    int b;

    printf("=== Taller 7: Control de Perifericos con 4 Botones (KEY0..KEY3) ===\n");
    printf("  KEY0: Incrementar valor (+1)\n");
    printf("  KEY1: Decrementar valor (-1)\n");
    printf("  KEY2: Cargar valor desde los 10 switches (SW9..SW0)\n");
    printf("  KEY3: Alternar visualizacion Decimal / Hexadecimal (y limpiar con SW=0 + KEY2)\n");
    printf("Presione Ctrl+C para salir.\n\n");

    fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd == -1) {
        printf("ERROR: could not open \"/dev/mem\" (errno = %s)\n", strerror(errno));
        return EXIT_FAILURE;
    }

    h2p_hw_virtual_base = mmap(NULL, HW_REGS_SPAN, PROT_READ | PROT_WRITE, MAP_SHARED, fd, HW_REGS_BASE);
    if (h2p_hw_virtual_base == MAP_FAILED) {
        printf("ERROR: mmap() failed (errno = %s)\n", strerror(errno));
        close(fd);
        return EXIT_FAILURE;
    }

    hex_addr[0] = (volatile unsigned int *)(h2p_hw_virtual_base + HEX_0_BASE);
    hex_addr[1] = (volatile unsigned int *)(h2p_hw_virtual_base + HEX_1_BASE);
    hex_addr[2] = (volatile unsigned int *)(h2p_hw_virtual_base + HEX_2_BASE);
    hex_addr[3] = (volatile unsigned int *)(h2p_hw_virtual_base + HEX_3_BASE);
    hex_addr[4] = (volatile unsigned int *)(h2p_hw_virtual_base + HEX_4_BASE);
    hex_addr[5] = (volatile unsigned int *)(h2p_hw_virtual_base + HEX_5_BASE);

    h2p_hw_leds_addr   = (volatile unsigned int *)(h2p_hw_virtual_base + LEDS_0_BASE);
    h2p_hw_button_addr = (volatile unsigned int *)(h2p_hw_virtual_base + BUTTONS_0_BASE);
    h2p_hw_switch_addr = (volatile unsigned int *)(h2p_hw_virtual_base + SWITCHES_0_BASE);

    // Initialize outputs
    *h2p_hw_leds_addr = value;
    update_displays(hex_addr, value, hex_mode);

    while (1) {
        bool changed = false;

        for (b = 0; b < 4; b++) {
            curr_btn[b] = is_fpga_button_pressed(b, h2p_hw_button_addr);
        }

        // Rising-edge detection on button press (false -> true)
        if (curr_btn[0] && !prev_btn[0]) {
            value = (value + 1) & 0x3FF;
            printf("[KEY0] Incremento -> valor = %d (0x%03X)\n", value, value);
            changed = true;
        }
        if (curr_btn[1] && !prev_btn[1]) {
            value = (value - 1) & 0x3FF;
            printf("[KEY1] Decremento -> valor = %d (0x%03X)\n", value, value);
            changed = true;
        }
        if (curr_btn[2] && !prev_btn[2]) {
            value = (*h2p_hw_switch_addr) & 0x3FF;
            printf("[KEY2] Cargado desde SW[9:0] -> valor = %d (0x%03X)\n", value, value);
            changed = true;
        }
        if (curr_btn[3] && !prev_btn[3]) {
            hex_mode = !hex_mode;
            printf("[KEY3] Modo 7-seg -> %s (valor = %d / 0x%03X)\n",
                   hex_mode ? "HEXADECIMAL" : "DECIMAL", value, value);
            changed = true;
        }

        if (changed) {
            *h2p_hw_leds_addr = value;
            update_displays(hex_addr, value, hex_mode);
        }

        for (b = 0; b < 4; b++) {
            prev_btn[b] = curr_btn[b];
        }

        // 20 ms software debounce / polling interval
        usleep(20000);
    }

    munmap(h2p_hw_virtual_base, HW_REGS_SPAN);
    close(fd);
    return 0;
}
