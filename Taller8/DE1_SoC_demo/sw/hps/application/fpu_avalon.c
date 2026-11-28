#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <math.h>
#include <sys/mman.h>

// Incluir hps_soc_system.h cuando ya esté generado por create_linux_changehw.sh
// #include "hps_soc_system.h"

// === Configuración del puente Lightweight HPS-to-FPGA ===
#define HW_REGS_BASE (0xFF200000)
#define HW_REGS_SPAN (0x00200000)
#define HW_REGS_MASK (HW_REGS_SPAN - 1)

// Dirección base del componente 'fpu' en Platform Designer (verificar en hps_soc_system.h)
#ifndef FPU_BASE
#define FPU_BASE     (0x000000C0)
#endif

// === Mapa de offsets de registros de fpu_avalon ===
#define FPU_OPA_OFT   0  // Escritura: operando A (IEEE 754 FP32)
#define FPU_OPB_OFT   1  // Escritura: operando B (IEEE 754 FP32)
#define FPU_SELOP_OFT 2  // Escritura: 0=+, 1=-, 2=*, 3=/
#define FPU_STRT_OFT  3  // Escritura (dummy): pulso start
#define FPU_RES_OFT   4  // Lectura: resultado (IEEE 754 FP32)
#define FPU_RDY_OFT   5  // Lectura: bit 0 = ready
#define FPU_DONE_OFT  6  // Lectura: bit 0 = done_tick; Escritura: limpia bandera

typedef union {
    float    f;
    uint32_t u;
} fp32_u;

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
    volatile uint32_t *fpu_base = NULL;

    fp32_u op_a, op_b, res_hw, res_sw;
    char op_char;
    uint32_t selop;
    char continuar = 's';

    printf("============================================================\n");
    printf(" Taller 8 - ALU de Punto Flotante FP32 en Bus Avalon (FPU)\n");
    printf("============================================================\n");

    fd = open("/dev/mem", (O_RDWR | O_SYNC));
    if (fd == -1) {
        printf("ERROR: no se pudo abrir /dev/mem: %s\n", strerror(errno));
        return EXIT_FAILURE;
    }

    virtual_base = mmap(NULL, HW_REGS_SPAN, (PROT_READ | PROT_WRITE),
                        MAP_SHARED, fd, HW_REGS_BASE);
    if (virtual_base == MAP_FAILED) {
        printf("ERROR: mmap() fallo: %s\n", strerror(errno));
        close(fd);
        return EXIT_FAILURE;
    }

    fpu_base = (volatile uint32_t *)((uint8_t *)virtual_base + (FPU_BASE & HW_REGS_MASK));

    while (continuar == 's' || continuar == 'S') {
        printf("\nIngrese operando A (float): ");
        if (scanf("%f", &op_a.f) != 1) break;

        printf("Ingrese operacion (+, -, *, /): ");
        if (scanf(" %c", &op_char) != 1) break;

        printf("Ingrese operando B (float): ");
        if (scanf("%f", &op_b.f) != 1) break;

        switch (op_char) {
            case '+': selop = 0U; res_sw.f = op_a.f + op_b.f; break;
            case '-': selop = 1U; res_sw.f = op_a.f - op_b.f; break;
            case '*': selop = 2U; res_sw.f = op_a.f * op_b.f; break;
            case '/':
                if (op_b.f == 0.0f) {
                    printf("ADVERTENCIA: Division por cero.\n");
                }
                selop = 3U;
                res_sw.f = op_a.f / op_b.f;
                break;
            default:
                printf("Operacion invalida. Use +, -, * o /.\n");
                continue;
        }

        // 1. Escribir operandos IEEE 754 y selector de operación
        iowr(fpu_base, FPU_OPA_OFT,   op_a.u);
        iowr(fpu_base, FPU_OPB_OFT,   op_b.u);
        iowr(fpu_base, FPU_SELOP_OFT, selop);

        // 2. Esperar ready == 1
        while ((iord(fpu_base, FPU_RDY_OFT) & 0x1U) == 0U) {
            // polling
        }

        // 3. Disparar inicio
        iowr(fpu_base, FPU_STRT_OFT, 1U);

        // 4. Esperar done_tick == 1
        while ((iord(fpu_base, FPU_DONE_OFT) & 0x1U) == 0U) {
            // polling
        }

        // 5. Limpiar done_tick
        iowr(fpu_base, FPU_DONE_OFT, 1U);

        // 6. Leer resultado IEEE 754 desde la FPGA
        res_hw.u = iord(fpu_base, FPU_RES_OFT);

        printf("\n--- Resultados para %.6f %c %.6f ---\n", op_a.f, op_char, op_b.f);
        printf("  Hardware (FPGA): %.6f  (IEEE 754: 0x%08X)\n", res_hw.f, res_hw.u);
        printf("  Software (ARM) : %.6f  (IEEE 754: 0x%08X)\n", res_sw.f, res_sw.u);
        printf("  Error absoluto : %.3e\n", fabsf(res_hw.f - res_sw.f));

        printf("\nDesea realizar otra operacion? (s/n): ");
        scanf(" %c", &continuar);
    }

    if (munmap(virtual_base, HW_REGS_SPAN) != 0) {
        printf("ERROR: munmap() fallo.\n");
    }
    close(fd);
    return EXIT_SUCCESS;
}
