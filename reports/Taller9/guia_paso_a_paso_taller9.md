# Guía Paso a Paso en Linux y DE1-SoC — Taller 9

Esta guía resume los comandos exactos a ejecutar en el PC con **Linux (Quartus Prime 18.1 + Intel SoC EDS)** y en la tarjeta **DE1-SoC** una vez hecho `git pull`.

---

## 1. Actualizar el Hardware en Platform Designer (`soc_system.qsys`)

Desde una terminal en Linux (con Quartus Prime 18.1 en `PATH` o desde el *Embedded Command Shell*):

```bash
cd Taller9/DE1_SoC_demo/hw/quartus

# Aplicar modificaciones automaticamente (buttons_0 FALLING + usr_timer + sys_timer + direcciones Fig. 7)
qsys-script --script=modify_taller9_qsys.tcl

# (Opcional) Abrir Platform Designer para inspeccionar visualmente y tomar captura de la Figura 7
qsys-edit soc_system.qsys &

# Generar HDL en VHDL
qsys-generate soc_system.qsys --synthesis=VHDL
```

> **Verificación recomendada:** Abrir `soc_system.qsys` en Platform Designer y confirmar:
> - `buttons_0`: `Synchronously capture = ON`, `Edge Type = FALLING`, sin *bit-clearing* ni *IRQ*.
> - `usr_timer` (`0x0000`..`0x001F`) y `sys_timer` (`0x0020`..`0x003F`), 32-bit, *Full-featured*, `1 ms`.
> - `hex_5..hex_0` (`0x0040`..`0x009F`), `buttons_0` (`0x00A0`), `switches_0` (`0x00B0`), `leds_0` (`0x00C0`).
> - Tomar capturas para `reports/Taller9/images/`.

---

## 2. Compilar en Quartus Prime 18.1

```bash
cd Taller9/DE1_SoC_demo/hw/quartus
quartus_sh --flow compile DE1_SoC_demo
```

*(O abrir `DE1_SoC_demo.qpf` en Quartus Prime GUI y ejecutar **Start Compilation**.)*

Confirmar que se generaron:
- `output_files/DE1_SoC_demo.sof`
- `soc_system.sopcinfo`
- `hps_isw_handoff/soc_system_hps_0/`

---

## 3. Regenerar Preloader, `.rbf` y `hps_soc_system.h`

Abrir el **Intel SoC EDS Embedded Command Shell** y ejecutar:

```bash
cd Taller9/DE1_SoC_demo
chmod +x create_linux_changehw.sh
./create_linux_changehw.sh
```

Esto generará y actualizará automáticamente:
- `sdcard/fat32/socfpga.rbf`
- `sdcard/a2/preloader-mkpimage.bin`
- `sw/hps/application/hps_soc_system.h`

---

## 4. Actualizar la Tarjeta microSD

Con la microSD insertada en el PC Linux (verificar dispositivo con `lsblk`, ej. `/dev/sdb` o `/dev/mmcblk0`):

```bash
# Reemplazar /dev/sdX1 (FAT32) y /dev/sdX3 (particion a2) segun lsblk
sudo mkdir -p /mnt/de1_fat32
sudo mount /dev/sdX1 /mnt/de1_fat32
sudo cp Taller9/DE1_SoC_demo/sdcard/fat32/socfpga.rbf /mnt/de1_fat32/
sudo sync
sudo umount /mnt/de1_fat32

# Actualizar preloader en la particion a2
sudo dd if=Taller9/DE1_SoC_demo/sdcard/a2/preloader-mkpimage.bin of=/dev/sdX3 bs=64K seek=0
sudo sync
```

Insertar la microSD en la **DE1-SoC** (verificar `MSEL = 000000`), encender y conectarse por **SSH**.

---

## 5. Compilar y Ejecutar las Aplicaciones en C

### Opción A: Copiar fuentes a la DE1-SoC y compilar nativamente con `gcc`
```bash
# Desde el PC Linux:
scp -r Taller9/DE1_SoC_demo/sw/hps/application root@<IP_DE1_SOC>:/home/root/taller9_app

# Dentro de la DE1-SoC por SSH:
cd /home/root/taller9_app
make
```

### Opción B: Cross-compilar en el PC Linux y copiar binarios
```bash
cd Taller9/DE1_SoC_demo/sw/hps/application
make CC=arm-linux-gnueabihf-gcc
```

### Ejecución de las 3 pruebas en la DE1-SoC:
1. **Aplicación base (`flashing_led`)**:
   ```bash
   ./flashing_led/driver_design
   ```
   - Ajustar `SW[9:0]`, presionar `KEY1` → verificar nuevo periodo en `HEX2..HEX0`, consola SSH y velocidad de `LEDR[1:0]`.
   - Presionar `KEY0` → verificar `'P'` en `HEX3` y pausa/reanudación de `LEDR[1:0]`.

2. **Ejercicio 1 (`ej1_kbd_interval`)**:
   ```bash
   ./ej1_kbd_interval/kbd_interval
   ```
   - Presionar `KEY2` → aparece `"Type new interval: "`.
   - Probar entrada inválida (ej. `abc`, `12`, `1234`) y verificar rechazo.
   - Probar entrada válida de 3 dígitos (ej. `250`, `080`) y verificar actualización en consola, `HEX2..HEX0` y `LEDR[1:0]`.

3. **Ejercicio 2 (`ej2_kbd_control`)**:
   ```bash
   ./ej2_kbd_control/kbd_control
   ```
   - Presionar `'S'` (*start*), `'P'` (*pause*), `'C'` (*clear*) y teclas aleatorias (`'a'`, `'x'`, `'1'`, `'s'`, `'p'`) verificando que las no válidas se ignoran.
