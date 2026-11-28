# ==============================================================================
# Makefile — Taller 9: Drivers PIO / Interval Timer y Aplicaciones ARM-Linux
#
# Uso en la DE1-SoC (compilacion nativa):
#     make
#
# Uso en PC Linux (cross-compilation para ARM):
#     make CC=arm-linux-gnueabihf-gcc
#
# Limpieza:
#     make clean
# ==============================================================================

CC      ?= gcc
CFLAGS  := -Wall -Wextra -O2 -I.
DRIVERS := drivers/gpio.c drivers/timer_driver.c

TARGETS := flashing_led/driver_design \
           ej1_kbd_interval/kbd_interval \
           ej2_kbd_control/kbd_control

.PHONY: all clean

all: $(TARGETS)

flashing_led/driver_design: flashing_led/driver_design.c $(DRIVERS) hps_soc_system.h drivers/gpio.h drivers/timer_driver.h
	$(CC) $(CFLAGS) -o $@ flashing_led/driver_design.c $(DRIVERS)

ej1_kbd_interval/kbd_interval: ej1_kbd_interval/kbd_interval.c $(DRIVERS) hps_soc_system.h drivers/gpio.h drivers/timer_driver.h
	$(CC) $(CFLAGS) -o $@ ej1_kbd_interval/kbd_interval.c $(DRIVERS)

ej2_kbd_control/kbd_control: ej2_kbd_control/kbd_control.c $(DRIVERS) hps_soc_system.h drivers/gpio.h drivers/timer_driver.h
	$(CC) $(CFLAGS) -o $@ ej2_kbd_control/kbd_control.c $(DRIVERS)

clean:
	rm -f $(TARGETS)
