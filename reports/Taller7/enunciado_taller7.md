# Pontificia Universidad Javeriana
## Departamento de Electrónica
### System on Chip (SoC)

---

# Taller 7: DE1-SoC — Programación SoC en ARM-Linux

> **Nota:** Este documento recopila exclusivamente las **órdenes directas de desarrollo** del tutorial *07 - Tutorial DE1-SoC.pdf* (Secciones 4 a 8), omitiendo el marco teórico introductorio.

---

## Objetivo y Requerimientos del Proyecto (Sección 4)

Desarrollar un proyecto híbrido SoC (`DE1_SoC_demo`) en la tarjeta **Terasic DE1-SoC** (**Cyclone V `5CSEMA5F31C6`**) que integre el procesador **HPS (ARM Cortex-A9)** corriendo **Ubuntu Linux** con periféricos implementados en la **FPGA**, cumpliendo:

- El HPS debe utilizar el puerto **microSD** para arrancar, configurar la FPGA automáticamente y ejecutar el sistema operativo Linux.
- El HPS debe utilizar el puerto **Ethernet** para establecer comunicación **SSH** con un *host PC*.
- El HPS debe controlar y leer los periféricos conectados a la FPGA: **4 botones**, **6 displays 7-segmentos**, **10 interruptores** y **10 LEDs** (además del botón `HPS_KEY_N` y LED `HPS_LED` propios del HPS).

### Prerrequisitos de entorno (Sección 1.1)
- Sistema operativo **Ubuntu** con permisos de administrador (`root`) y paquetes `git`, `qemu-user-static` y `minicom`.
- **Quartus Prime** y **SoC Embedded Design Suite (SoC EDS)** instalados en la misma ruta base (`<intelFPGA_lite_install_directory>/<version>`).
- Ejecutar todas las instrucciones de línea de comandos desde el **Altera Embedded Command Shell**:
  ```bash
  sudo <intelFPGA_lite_install_directory>/<version>/embedded/embedded_command_shell.sh
  ```

---

## 1. Estructura del Proyecto (Sección 4.1)

Crear y respetar estrictamente la estructura de carpetas bajo la raíz `DE1_SoC_demo/` (nombres de carpetas, archivos y puertos):

```text
DE1_SoC_demo/
├── hw/
│   ├── hdl/
│   ├── modelsim/
│   └── quartus/
├── sw/
│   └── hps/
│       ├── application/
│       ├── linux/
│       │   ├── rootfs/
│       │   └── source/
│       ├── preloader/
│       └── u-boot/
└── sdcard/
    ├── a2/
    └── fat32/
```

*(Nota: la Figura 11 del tutorial omite el nivel intermedio `hps/`, pero todos los comandos de las secciones 6 y 7 utilizan las rutas `DE1_SoC_demo/sw/hps/...`).*

---

## 2. Diseño de Hardware (Sección 5)

### 2.1 Configuración General de Quartus Prime (Pasos 1–3)
1. Abrir Quartus desde `embedded_command_shell.sh` y crear el proyecto **`DE1_SoC_demo`** en `DE1_SoC_demo/hw/quartus/` seleccionando el dispositivo **`5CSEMA5F31C6`** (tarjeta **DE1-SoC Board**).
2. Guardar el archivo provisto `DE1_SoC_top_level.vhd` en `DE1_SoC_demo/hw/hdl/`, agregarlo al proyecto y configurarlo como **top-level entity**.
3. Guardar `pin_assignment_DE1_SoC.tcl` en `DE1_SoC_demo/hw/quartus/` y ejecutarlo desde `Tools >> Tcl Scripts...`.

### 2.2 Diseño del Sistema HPS en Platform Designer (Pasos 4–21)
Crear un nuevo sistema en **Platform Designer** y guardarlo como **`soc_system.qsys`** en `DE1_SoC_demo/hw/quartus/`.

#### A. PLL (`pll_0`) — Paso 4
- Agregar **`PLL Intel FPGA IP`**:
  - *Reference Clock Frequency*: `50 MHz`, *Operation Mode*: `normal`, desmarcar *Enable locked output port*.
  - `outclk0`: **`50 MHz`** (reloj para la FPGA).
  - `outclk1`: **`100 MHz`**, desfase **`-3758 ps`** (reloj para SDRAM externa).
- Exportar `pll_0.outclk1` con el nombre **`pll_0_sdram`**.

#### B. HPS (`hps_0`) — Pasos 5–14
Agregar **`Arria V/Cyclone V Hard Processor System`** y configurar sus pestañas:

- **FPGA Interfaces (Paso 7):**
  - `FPGA-to-HPS interface width`: **Unused**.
  - `HPS-to-FPGA interface width`: **Unused**.
  - `Lightweight HPS-to-FPGA interface width`: **32-bit**.
  - Desmarcar *Enable MPU standby and event signals*.
  - Eliminar el puerto por defecto en *FPGA-to-HPS SDRAM Interface* (botón `-`).
- **Peripheral Pins (Pasos 8–12):**
  - Habilitar `GPIO53` (`HPS_LED`, pin A24) y `GPIO54` (`HPS_KEY_N`, pin G21).
  - Habilitar **`EMAC1`**: `HPS I/O Set 0`, modo **`RGMII`**, y activar `GPIO35` (`HPS_ENET_INT_N`, pin C19).
  - Habilitar **`SDIO`**: `HPS I/O Set 0`, modo **`4-bit Data`**.
  - Habilitar **`UART0`**: `HPS I/O Set 0`, modo **`No Flow Control`**.
  - *(Opcional recomendado para usos futuros)*: habilitar `QSPI` (`HPS I/O Set 0`, `1 SS`), `USB1` (`HPS I/O Set 0`, `SDR with PHY clock output mode`), `SPIM1` (`HPS I/O Set 0`, `Single Slave Select`), `I2C0` e `I2C1` (`HPS I/O Set 0`, `I2C`), y los pines `GPIO09`, `GPIO40`, `GPIO48` y `GPIO61`.
  - Exportar `hps_0.hps_io` con el nombre **`hps_0_io`**.
- **HPS Clocks:** mantener la configuración predeterminada.
- **SDRAM (Pasos 13–14):**
  - Configurar el controlador para la memoria **DDR3 ISSI (`43TR16256A-85120AL`)** con protocolo `DDR3`, reloj de memoria `400.0 MHz`, PLL ref `25.0 MHz`, `1.5V DDR3`, ancho total `32`, *speed grade* `800.0 MHz`, `Row = 15`, `Col = 10`, `Bank = 3`, `DM` y `DQS#` habilitados, y todos los parámetros de inicialización, *Memory Timing* y *Board Skews* especificados en el Paso 13 del tutorial.
  - Exportar `hps_0.memory` con el nombre **`hps_0_ddr`**.

#### C. Periféricos FPGA en el Lightweight AXI Bridge (Pasos 15–21)
Instanciar los siguientes componentes **`PIO (Parallel I/O) Intel FPGA IP`**:

| Componente | Ancho | Dirección | Reset Value | Exportación |
| :--- | :---: | :---: | :---: | :--- |
| `leds_0` | 10 bits | Output | `0x00` | `leds_0.external_connection` |
| `switches_0` | 10 bits | Input | — | `switches_0.external_connection` |
| `buttons_0` | 4 bits | Input | — | `buttons_0.external_connection` |
| `hex_0` .. `hex_5` (×6) | 7 bits | Output | `0x7f` | `hex_0..5.external_connection` |

Para **todos** los periféricos anteriores:
- Conectar `clk` $\to$ `pll_0.outclk0` (y conectar también `hps_0.h2f_lw_axi_clock` $\to$ `pll_0.outclk0`).
- Conectar `reset` $\to$ `hps_0.h2f_reset`.
- Conectar el esclavo Avalon `s1` $\to$ `hps_0.h2f_lw_axi_master`.
- Ejecutar **`System >> Assign Base Addresses`** para resolver superposiciones de direcciones.

### 2.3 Generación, Instanciación, Pines DDR3 y Compilación (Pasos 22–32)
1. Hacer clic en **`Generate HDL`** seleccionando **VHDL** para síntesis, generar y guardar `soc_system.qsys`.
2. Agregar `DE1_SoC_demo/hw/quartus/soc_system/synthesis/soc_system.qip` al proyecto de Quartus Prime.
3. Declarar el componente (desde `soc_system.cmp`) e instanciarlo en `DE1_SoC_top_level.vhd`, verificando correspondencia exacta de nombres y puertos.
4. Ejecutar **`Processing >> Start >> Analysis and Synthesis`**.
5. Ir a **`Tools >> Tcl Scripts...`** y ejecutar **`hps_sdram_p0_pin_assignments.tcl`** (reiniciar Quartus si no aparece listado).
6. Realizar una **compilación completa** del proyecto.
7. Convertir el bitstream `.sof` a `.rbf` en `sdcard/fat32/`:
   ```bash
   quartus_cpf -c DE1_SoC_demo/hw/quartus/output_files/DE1_SoC_demo.sof DE1_SoC_demo/sdcard/fat32/socfpga.rbf
   ```

---

## 3. Construcción del Sistema ARM-HPS-Linux y Tarjeta SD (Sección 6)

### Opción A — Proceso Automatizado (Sección 6.1, Pasos 33–35)
1. Descargar la carpeta `sdcard` del repositorio del curso y colocar `create_linux_system.sh` en la raíz `DE1_SoC_demo/`.
2. Si la microSD no es de 64 GB, ajustar los tamaños de partición en la función `partition_sdcard()` del script.
3. Insertar la microSD y ejecutar:
   ```bash
   sudo ./create_linux_system.sh
   ```
   *(Al finalizar, continuar directamente en la Sección 3.1: Prueba del sistema).*

### Opción B — Proceso Manual Paso a Paso (Secciones 6.2–6.6, Pasos 36–86)
1. **Preloader (Pasos 36–43):**
   - Desde `embedded_command_shell.sh`, lanzar `bsp-editor` $\to$ `File > New HPS BSP...`.
   - *Preloader Settings Directory*: `DE1_SoC_demo/hw/quartus/hps_isw_handoff/soc_system_hps_0`.
   - Desmarcar *Use default locations* y establecer *BSP target directory*: `DE1_SoC_demo/sw/hps/preloader`.
   - Activar `spl.boot` $\to$ **`FAT_SUPPORT`**, generar, compilar con `make` en `sw/hps/preloader/` y copiar `preloader-mkpimage.bin` a `DE1_SoC_demo/sdcard/a2/`.
2. **U-Boot y Script de Arranque (Pasos 44–58):**
   - Clonar `https://github.com/altera-opensource/u-boot-socfpga.git` en `DE1_SoC_demo/sw/hps/u-boot`.
   - Exportar `ARCH=arm` y `CROSS_COMPILE=arm-linux-gnueabihf-`, ejecutar `make distclean`, `git checkout b104b3dc1dd90cdbf67ccf3c51b06e4f1592fe91` y `make socfpga_cyclone5_config`.
   - Editar `include/configs/socfpga_cyclone5_socdk.h` definiendo `CONFIG_BOOTCOMMAND` (`"run callscript"`) y `CONFIG_EXTRA_ENV_SETTINGS` para cargar y ejecutar `u-boot.scr` desde la partición FAT32, y compilar con `make`.
   - Crear `DE1_SoC_demo/sw/hps/u-boot/u-boot.script` (carga `socfpga.rbf`, programa FPGA, habilita puentes `bridge enable`, carga `zImage` y `socfpga.dtb`, y arranca Linux).
   - Compilar el script a binario con `mkimage -A arm -O Linux -T script -C none -a 0 -e 0 -n DE1_SoC_demo -d u-boot.script u-boot.scr`.
   - Copiar `u-boot.img` y `u-boot.scr` a `DE1_SoC_demo/sdcard/fat32/`.
3. **Kernel de Linux (Pasos 59–73):**
   - Clonar `https://github.com/altera-opensource/linux-socfpga.git` en `DE1_SoC_demo/sw/hps/linux/source`.
   - Exportar `ARCH=arm` y `CROSS_COMPILE=arm-linux-gnueabihf-`, ejecutar `make distclean`, `git checkout 9735a22799b9214d17d3c231fe377fc852f042e9` y `make socfpga_defconfig`.
   - Ejecutar `make menuconfig` y habilitar módulos WiFi (*Wireless*, *RF switch subsystem support*, *Realtek Wireless LAN*, *Staging drivers RTL8188EU*) y soporte *USB Serial Converter* (FTDI).
   - Compilar `make socfpga_cyclone5_socdk.dtb` y `make zImage`.
   - Copiar `zImage` y `socfpga_cyclone5_socdk.dtb` (renombrado a `socfpga.dtb`) a `DE1_SoC_demo/sdcard/fat32/`.
4. **Root Filesystem (Paso 74):**
   - Guardar `ext3_rootfs.tar.gz` del repositorio del curso en `DE1_SoC_demo/sdcard/`.
5. **Particionamiento y Escritura de la Tarjeta SD (Pasos 75–86):**
   - Identificar el dispositivo correcto (`/dev/mmcblkX` o `/dev/sdbX`).
   - Particionar con `fdisk`: partición 3 tipo `a2` (4096 sectores), partición 1 tipo `b` (FAT32), partición 2 tipo `83` (EXT3, ajustando tamaños a la microSD).
   - Formatear p1 con `mkfs.vfat` y p2 con `mkfs.ext3 -F`.
   - Grabar `preloader-mkpimage.bin` en la partición `a2` usando `dd bs=64k seek=0`.
   - Montar p1 y p2, copiar `sdcard/fat32/*` en p1 (`socfpga.dtb`, `socfpga.rbf`, `u-boot.img`, `u-boot.scr`, `zImage`) y descomprimir `ext3_rootfs.tar.gz` en p2.
   - Ejecutar `sudo sync`, desmontar ambas particiones y borrar los directorios temporales de montaje.

### 3.1 Prueba del Sistema en la DE1-SoC (Sección 6.7, Pasos 87–97)
1. Verificar el DIP switch **`SW10` (`MSEL[4:0]`)** en **`00000`** para arranque y configuración de FPGA desde U-Boot/microSD.
2. Conectar cable de red al mismo router del PC, cable USB-UART e insertar la microSD.
3. Abrir consola serial con `sudo minicom --device /dev/ttyUSB0` configurada a **`115200 8N1`** sin control de flujo (*Hardware/Software Flow Control: No*).
4. Encender la tarjeta DE1-SoC e iniciar sesión en Ubuntu con las credenciales indicadas en el arranque.
5. Obtener la IP con `ifconfig` y conectarse desde el PC vía `ssh ubuntu@<IP_DE1_SoC>`.
6. Configurar contraseña de `root` (`sudo passwd root`). Para apagar la tarjeta usar siempre `sudo shutdown -h now`.
7. *(Opcional, Pasos 96–97)*: habilitar archivo de memoria *swap* (`/swapfile`) y agregarlo a `/etc/fstab`.

---

## 4. Programación de la Aplicación Base en C-Linux (Sección 7, Pasos 98–101)

1. Verificar la existencia de `DE1_SoC_demo/sw/hps/application/hps_soc_system.h` (generado por `create_linux_system.sh`). Si no existe, generarlo desde el *host PC* en el *Altera Embedded Command Shell*:
   ```bash
   export PATH=~/intelFPGA_lite/18.1/quartus/sopc_builder/bin/
   sopc-create-header-files DE1_SoC_demo/hw/quartus/soc_system.sopcinfo \
     --single DE1_SoC_demo/sw/hps/application/hps_soc_system.h --module hps_0
   ```
2. En la tarjeta DE1-SoC (por SSH), crear el directorio de aplicaciones:
   ```bash
   mkdir SoC_apps && cd SoC_apps
   ```
3. Crear o transferir vía `scp` el programa **`linux_hps.c`** (almacenado también en `DE1_SoC_demo/sw/hps/application/linux_hps.c`) que:
   - Abra `/dev/mem` y mapee el espacio del *Lightweight HPS-to-FPGA Bridge* (`HW_REGS_BASE = 0xFF200000`, `HW_REGS_SPAN = 0x00200000`) mediante `mmap()`.
   - Calcule los punteros virtuales para los PIO (`leds_0`, `switches_0`, `buttons_0`, `hex_0`..`hex_5`) usando los *offsets* de Platform Designer / `hps_soc_system.h`.
   - En un bucle infinito (*polling*), lea los 10 interruptores, refleje su estado en los 10 LEDs y despliegue su valor convertido a decimal en los 6 displays 7-segmentos.
4. Compilar y ejecutar en la DE1-SoC con permisos de `root`:
   ```bash
   gcc linux_hps.c -o linux_hps
   sudo ./linux_hps
   ```

---

## 5. Ejercicio Propuesto (Sección 8)

1. A partir de la rutina de lectura de botones de la FPGA mostrada en la **Figura 55** (botones activos en bajo):
   ```c
   bool is_fpga_button_pressed(int button_number, volatile unsigned int *base) {
       // buttons are active-low
       return !((*base) & (1 << button_number));
   }
   ```
   **Diseñe e implemente una aplicación de usuario en C-Linux que utilice los 4 botones de la tarjeta DE1-SoC**, definiendo las acciones que debe ejecutar cada botón sobre los periféricos disponibles (LEDs, displays 7-segmentos, interruptores, etc.).
