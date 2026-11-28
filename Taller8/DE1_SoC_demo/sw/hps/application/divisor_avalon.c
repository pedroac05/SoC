#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <sys/mman.h>

// Incluir hps_soc_system.h cuando ya esté generado por create_linux_changehw.sh
// #include "hps_soc_system.h"

// === Configuración del puente Lightweight HPS-to-FPGA ===
#define HW_REGS_BASE (0xFF200000)
#define HW_REGS_SPAN (0x00200000)
#define HW_REGS_MASK (HW_REGS_SPAN - 1)

// Dirección base del componente 'div' en Platform Designer (verificar en hps_soc_system.h)
#ifndef DIV_BASE
#define DIV_BASE     (0x000000A0)
#endif

// === Mapa de offsets de registros del divisor_avalon ===
#define DVND_REG_OFT 0  // Escritura: dividendo
#define DVSR_REG_OFT 1  // Escritura: divisor
#define STRT_REG_OFT 2  // Escritura (dummy): pulso start
#define QUOT_REG_OFT 3  // Lectura: cociente
#define REMN_REG_OFT 4  // Lectura: residuo
#define RDY_REG_OFT  5  // Lectura: bit 0 = ready
#define DONE_REG_OFT 6  // Lectura: bit 0 = done_tick; Escritura (dummy): limpia bandera

// Funciones auxiliares de acceso a registros de 32 bits
static inline void iowr(volatile uint32_t *base, unsigned int offset, uint32_t data)
{
    base[offset] = data;
}

static inline uint32_t iord(volatile uint32_t *base, unsigned int offset)
{
    return base[offset];
}

int main(void)
{
    int fd;
    void *virtual_base = NULL;
    volatile uint32_t *div_base = NULL;

    uint32_t a, b;
    uint32_t quo_hw, rmd_hw;
    uint32_t quo_sw, rmd_sw;
    char continuar = 's';

    printf("============================================================\n");
    printf(" Taller 8 - Verificacion Acelerador Divisor Entero (Avalon)\n");
    printf("============================================================\n");

    // 1. Abrir /dev/mem
    fd = open("/dev/mem", (O_RDWR | O_SYNC));
    if (fd == -1) {
        printf("ERROR: no se pudo abrir /dev/mem: %s\n", strerror(errno));
        return EXIT_FAILURE;
    }

    // 2. Mapear el puente Lightweight HPS-to-FPGA
    virtual_base = mmap(NULL, HW_REGS_SPAN, (PROT_READ | PROT_WRITE),
                        MAP_SHARED, fd, HW_REGS_BASE);
    if (virtual_base == MAP_FAILED) {
        printf("ERROR: mmap() fallo: %s\n", strerror(errno));
        close(fd);
        return EXIT_FAILURE;
    }

    div_base = (volatile uint32_t *)((uint8_t *)virtual_base + (DIV_BASE & HW_REGS_MASK));

    while (continuar == 's' || continuar == 'S') {
        printf("\nIngrese dividendo (entero sin signo a): ");
        if (scanf("%u", &a) != 1) break;

        printf("Ingrese divisor   (entero sin signo b > 0): ");
        if (scanf("%u", &b) != 1) break;

        if (b == 0) {
            printf("ERROR: El divisor no puede ser 0.\n");
            continue;
        }

        // 3. Escribir dividendo y divisor
        iowr(div_base, DVND_REG_OFT, a);
        iowr(div_base, DVSR_REG_OFT, b);

        // 4. Esperar a que el acelerador esté listo (ready == 1)
        while ((iord(div_base, RDY_REG_OFT) & 0x1U) == 0U) {
            // polling
        }

        // 5. Generar pulso de inicio (escritura dummy en offset 2)
        iowr(div_base, STRT_REG_OFT, 1U);

        // 6. Esperar a que finalice la operación (done_tick == 1)
        while ((iord(div_base, DONE_REG_OFT) & 0x1U) == 0U) {
            // polling
        }

        // 7. Limpiar bandera done_tick (escritura dummy en offset 6)
        iowr(div_base, DONE_REG_OFT, 1U);

        // 8. Leer resultados desde hardware
        quo_hw = iord(div_base, QUOT_REG_OFT);
        rmd_hw = iord(div_base, REMN_REG_OFT);

        // 9. Calcular referencia en software (ARM)
        quo_sw = a / b;
        rmd_sw = a % b;

        printf("\n--- Resultados para %u / %u ---\n", a, b);
        printf("  Hardware (FPGA): cociente = %u, residuo = %u (LEDR[7:0] = 0x%02X)\n",
               quo_hw, rmd_hw, rmd_hw & 0xFFU);
        printf("  Software (ARM) : cociente = %u, residuo = %u\n", quo_sw, rmd_sw);
        printf("  Verificacion   : %s\n",
               (quo_hw == quo_sw && rmd_hw == rmd_sw) ? "COINCIDE [OK]" : "DIFIERE [ERROR]");

        printf("\nDesea realizar otra division? (s/n): ");
        scanf(" %c", &continuar);
    }

    if (munmap(virtual_base, HW_REGS_SPAN) != 0) {
        printf("ERROR: munmap() fallo.\n");
    }
    close(fd);
    return EXIT_SUCCESS;
}
