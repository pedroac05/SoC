# Guía de Requisitos y Paso a Paso — Taller 7 (DE1-SoC ARM-Linux)

**Pontificia Universidad Javeriana — Departamento de Electrónica — System on Chip (SoC)**

Este documento consolida la lista completa de **elementos requeridos** (hardware, software y archivos base del curso) y el **procedimiento paso a paso ejecutable** para completar el Taller 7 de principio a fin, incluyendo todos los parámetros críticos del tutorial *07 - Tutorial DE1-SoC.pdf*.

---

## Parte I: Elementos Requeridos (Checklist Previo)

### 1. Hardware Físico
- [ ] **Tarjeta de desarrollo Terasic DE1-SoC** (Cyclone V SoC `5CSEMA5F31C6`) con su fuente de alimentación de **12 V DC**.
- [ ] **Tarjeta microSD** + adaptador/lector en el PC host.
  - *Nota:* El script automatizado `create_linux_system.sh` asume **64 GB**; si usas una microSD de menor capacidad (p. ej. 8 GB, 16 GB o 32 GB), deberás ajustar los tamaños de las particiones FAT32 y EXT3 en `partition_sdcard()` o en `fdisk`.
- [ ] **Cable Mini-USB a USB-A** (puerto *UART-to-USB* de la DE1-SoC, usado para la consola serial `/dev/ttyUSB0`).
- [ ] **Cable Ethernet RJ-45** conectado al mismo router/red local que el PC host (necesario para conexión SSH y transferencia de programas con `scp`).
- [ ] **PC Host con Linux (Ubuntu)** y permisos de administrador (`root` / `sudo`).
  - *Nota:* El tutorial fue probado en Ubuntu 16.04; si trabajas desde Windows, necesitarás un entorno Linux nativo o máquina virtual con passthrough USB para el lector microSD y el puerto USB-UART.
- [ ] *(Opcional)* **Cable USB-B** (USB Blaster II / JTAG): solo necesario para depuración o programación manual; en este taller la FPGA se configura automáticamente desde U-Boot al encender la tarjeta.
- [ ] *(Opcional)* **Módulo USB-WiFi Realtek RTL8188EU** si deseas probar conectividad inalámbrica.

### 2. Software en el PC Host (Linux)
- [ ] **Intel Quartus Prime Lite Edition** (con soporte para la familia **Cyclone V**).
- [ ] **Intel SoC Embedded Design Suite (SoC EDS)** de la **misma versión** que Quartus Prime.
  - **Importante:** Al instalar SoC EDS, asegúrate de colocarlo exactamente en la misma ruta raíz de Quartus (`<intelFPGA_lite_install_directory>/<version>`), ya que el instalador suele proponer otra carpeta por defecto.
- [ ] **Paquetes de Ubuntu:**
  ```bash
  sudo apt-get update
  sudo apt-get install -y git qemu-user-static minicom
  ```
  *(Si vas a compilar U-Boot y el Kernel de forma manual, verifica también tener `u-boot-tools`, `build-essential`, `libncurses5-dev` y `bc`).*
- [ ] **Altera Embedded Command Shell** disponible en:
  ```bash
  sudo <intelFPGA_lite_install_directory>/<version>/embedded/embedded_command_shell.sh
  ```
  > Todos los comandos de Quartus, BSP Editor y compilación del taller deben ejecutarse **dentro de este shell**.

### 3. Archivos Base del Curso (descargar de MS Teams)
Antes de iniciar, descarga la carpeta `DE1_SoC_Demo` / archivos del repositorio del curso y ubícalos en las carpetas ya creadas en `Taller7/DE1_SoC_demo/`:

| Archivo / Carpeta del curso | Ruta destino en este repositorio | Uso |
| :--- | :--- | :--- |
| `DE1_SoC_top_level.vhd` | `Taller7/DE1_SoC_demo/hw/hdl/` | Entidad de nivel superior (pines físicos de la DE1-SoC) |
| `pin_assignment_DE1_SoC.tcl` | `Taller7/DE1_SoC_demo/hw/quartus/` | Asignación de pines y estándares E/S de la FPGA |
| `create_linux_system.sh` | `Taller7/DE1_SoC_demo/` | Script automatizado (Preloader + partición + grabación SD) |
| `ext3_rootfs.tar.gz` (y carpeta `sdcard/`) | `Taller7/DE1_SoC_demo/sdcard/` | Sistema de archivos raíz precompilado (Ubuntu 16.04 Core ARM) |
| `linux_hps.c` | `Taller7/DE1_SoC_demo/sw/hps/application/` | Código fuente de la aplicación base en C-Linux |

---

## Parte II: Paso a Paso para Completar el Taller

---

### Fase 1: Diseño de Hardware en Quartus Prime y Platform Designer

#### 1.1 Creación del proyecto y pines base (Pasos 1–3)
- [ ] Abrir una terminal en Linux, activar el shell embebido e iniciar Quartus Prime:
  ```bash
  sudo <intelFPGA_lite_install_directory>/<version>/embedded/embedded_command_shell.sh
  quartus &
  ```
- [ ] Crear un proyecto nuevo (`File >> New Project Wizard`):
  - **Directorio:** `Taller7/DE1_SoC_demo/hw/quartus/`
  - **Nombre del proyecto:** `DE1_SoC_demo`
  - **Dispositivo:** Cyclone V `5CSEMA5F31C6` (o pestaña *Board* $\to$ **DE1-SoC Board**).
- [ ] Agregar `DE1_SoC_demo/hw/hdl/DE1_SoC_top_level.vhd` mediante `Project >> Add/Remove Files in Project...` y marcarlo como **Set as Top-Level Entity**.
- [ ] Ejecutar `DE1_SoC_demo/hw/quartus/pin_assignment_DE1_SoC.tcl` desde `Tools >> Tcl Scripts...`.

#### 1.2 Creación del sistema en Platform Designer (Pasos 4–21)
- [ ] Abrir `Tools >> Platform Designer`, verificar `Device Family: Cyclone V / 5CSEMA5F31C6` y guardar el sistema como **`DE1_SoC_demo/hw/quartus/soc_system.qsys`**.

##### A. Instanciar el PLL (`pll_0`) — Paso 4
- [ ] Agregar **`PLL Intel FPGA IP`** (*Basic Functions >> Clocks; PLLs and Resets >> PLL*):
  - *Reference Clock Frequency:* `50 MHz`
  - *Operation Mode:* `normal`
  - Desmarcar *Enable locked output port*
  - *Number of Clocks:* `2`
    - `outclk0`: **`50 MHz`** (reloj interno FPGA)
    - `outclk1`: **`100 MHz`**, *Phase Shift:* **`-3758 ps`** (reloj SDRAM externa)
- [ ] En *System Contents*, conectar `pll_0.refclk` $\to$ `clk_0.clk` y `pll_0.reset` $\to$ `clk_0.clk_reset`, y exportar `pll_0.outclk1` como **`pll_0_sdram`**.

##### B. Instanciar y configurar el HPS (`hps_0`) — Pasos 5–14
- [ ] Agregar **`Arria V/Cyclone V Hard Processor System`** (*Processors and Peripherals >> Hard Processor Systems*).
- [ ] **Pestaña `FPGA Interfaces` (Paso 7):**
  - `FPGA-to-HPS interface width`: **`Unused`**
  - `HPS-to-FPGA interface width`: **`Unused`**
  - `Lightweight HPS-to-FPGA interface width`: **`32-bit`**
  - Desmarcar *Enable MPU standby and event signals*.
  - En *FPGA-to-HPS SDRAM Interface*, eliminar el puerto listado usando el botón **`-`**.
- [ ] **Pestaña `Peripheral Pins` (Pasos 8–12):**
  - Activar `GPIO53` (`HPS_LED`, pin A24) y `GPIO54` (`HPS_KEY_N`, pin G21).
  - **EMAC1:** Pin = `HPS I/O Set 0`, Mode = `RGMII`, y activar `GPIO35` (`HPS_ENET_INT_N`, pin C19).
  - **SDIO:** Pin = `HPS I/O Set 0`, Mode = `4-bit Data`.
  - **UART0:** Pin = `HPS I/O Set 0`, Mode = `No Flow Control`.
  - *(Opcional recomendado para talleres futuros — no consume lógica FPGA)*:
    - **QSPI:** `HPS I/O Set 0` / `1 SS`
    - **USB1:** `HPS I/O Set 0` / `SDR with PHY clock output mode`
    - **SPIM1:** `HPS I/O Set 0` / `Single Slave Select`
    - **I2C0** e **I2C1:** `HPS I/O Set 0` / `I2C`
    - Botones GPIO: `GPIO09`, `GPIO40`, `GPIO48`, `GPIO61`.
  - En *System Contents*, exportar `hps_0.hps_io` con el nombre **`hps_0_io`**.
- [ ] **Pestaña `HPS Clocks`:** dejar todos los valores predeterminados.
- [ ] **Pestaña `SDRAM` (Paso 13 — crítico para arranque estable):** configurar exactamente según la memoria DDR3 ISSI `43TR16256A-85120AL`:

  | Sección | Parámetro | Valor |
  | :--- | :--- | :--- |
  | **Protocolo** | SDRAM Protocol | `DDR3` |
  | **PHY Settings** | Memory clock frequency / PLL ref clock / Voltage | `400.0 MHz` / `25.0 MHz` / `1.5V DDR3` |
  | **Memory Parameters** | Vendor / Speed grade / Interface width | `Other` / `800.0 MHz` / `32` |
  | | Chip select / Clocks / Row / Col / Bank | `1` / `1` / `15` / `10` / `3` |
  | | Enable DM pins / DQS# Enable / Mirror Addressing | Marcados / `0` |
  | **Mode Register 0** | Burst Length / Read Burst / DLL / CAS latency | `Burst chop 4 or 8 (on the fly)` / `Sequential` / `DLL off` / `11` |
  | **Mode Register 1** | Output drive strength / ODT Rtt nominal | `RZQ/7` / `RZQ/4` |
  | **Mode Register 2** | Auto selfrefresh / Temp / Write CAS / Dynamic ODT | `Manual` / `Normal` / `8` / `RZQ/4` |
  | **Memory Timing** | `tIS` / `tIH` / `tDS` / `tDH` | `180 ps` / `140 ps` / `30 ps` / `65 ps` |
  | | `tDQSQ` / `tQH` / `tDQSCK` / `tDQSS` | `125 ps` / `0.38 cycles` / `255 ps` / `0.25 cycles` |
  | | `tQSH` / `tDSH` / `tDSS` / `tINIT` | `0.4 cycles` / `0.2 cycles` / `0.2 cycles` / `500 us` |
  | | `tMRD` / `tRAS` / `tRCD` / `tRP` | `4 cycles` / `35.0 ns` / `13.75 ns` / `13.75 ns` |
  | | `tREFI` / `tRFC` / `tWR` / `tWTR` | `7.8 us` / `260.0 ns` / `15.0 ns` / `4 cycles` |
  | | `tFAW` / `tRRD` / `tRTP` | `30.0 ns` / `7.5 ns` / `7.5 ns` |
  | **Board Settings** | Setup & Hold Derating / Channel Signal Integrity | `Use Altera's default settings` |
  | **Board Skews** | Max CK delay / Max DQS delay | `0.03 ns` / `0.02 ns` |
  | | Min / Max delay diff between CK and DQS | `0.06 ns` / `0.12 ns` |
  | | Max skew within / between DQS groups | `0.01 ns` / `0.06 ns` |
  | | Avg delay diff DQ–DQS / Max skew addr&cmd / Avg diff addr&cmd–CK | `0.05 ns` / `0.02 ns` / `0.01 ns` |

- [ ] En *System Contents*, exportar `hps_0.memory` como **`hps_0_ddr`** y conectar `hps_0.h2f_lw_axi_clock` $\to$ `pll_0.outclk0`.

##### C. Instanciar los periféricos PIO en la FPGA (Pasos 15–21)
- [ ] Agregar 9 instancias de **`PIO (Parallel I/O) Intel FPGA IP`** con los siguientes parámetros:

  | Nombre | Width | Direction | Reset Value | Exportación | Offset esperado (ref. Fig. 30) |
  | :--- | :---: | :---: | :---: | :--- | :---: |
  | `leds_0` | 10 | Output | `0x00` | `leds_0_external_connection` | `0x0000_0080` |
  | `switches_0` | 10 | Input | — | `switches_0_external_connection` | `0x0000_0070` |
  | `buttons_0` | 4 | Input | — | `buttons_0_external_connection` | `0x0000_0060` |
  | `hex_0` | 7 | Output | `0x7f` | `hex_0_external_connection` | `0x0000_0050` |
  | `hex_1` | 7 | Output | `0x7f` | `hex_1_external_connection` | `0x0000_0040` |
  | `hex_2` | 7 | Output | `0x7f` | `hex_2_external_connection` | `0x0000_0030` |
  | `hex_3` | 7 | Output | `0x7f` | `hex_3_external_connection` | `0x0000_0020` |
  | `hex_4` | 7 | Output | `0x7f` | `hex_4_external_connection` | `0x0000_0010` |
  | `hex_5` | 7 | Output | `0x7f` | `hex_5_external_connection` | `0x0000_0000` |

- [ ] Para cada uno de los 9 PIOs, conectar:
  - `clk` $\to$ `pll_0.outclk0`
  - `reset` $\to$ `hps_0.h2f_reset`
  - `s1` $\to$ `hps_0.h2f_lw_axi_master`
- [ ] Ejecutar **`System >> Assign Base Addresses`** y anotar las direcciones base asignadas (deben verificarse luego en `hps_soc_system.h` / `linux_hps.c`).
- [ ] Verificar que no existan errores en el panel *Messages*.

#### 1.3 Generación HDL, instanciación, pines DDR3 y `.rbf` (Pasos 22–32)
- [ ] Hacer clic en **`Generate HDL...`**, elegir **VHDL** en *Create HDL design files for synthesis*, generar, guardar el `.qsys` y cerrar Platform Designer (responder *No* si pregunta por volver a generar).
- [ ] En Quartus Prime, agregar `DE1_SoC_demo/hw/quartus/soc_system/synthesis/soc_system.qip` (`Project >> Add/Remove Files in Project...`).
- [ ] Abrir `DE1_SoC_demo/hw/quartus/soc_system/soc_system.cmp` y verificar que la declaración del `component soc_system` y su instanciación en `DE1_SoC_top_level.vhd` coincidan exactamente en nombres de puertos y anchos.
- [ ] Ejecutar **`Processing >> Start >> Analysis and Synthesis`**.
- [ ] Abrir **`Tools >> Tcl Scripts...`** y ejecutar **`soc_system/synthesis/submodules/hps_sdram_p0_pin_assignments.tcl`**.
  - *Tip:* Si no aparece el script en la lista, cierra y vuelve a abrir Quartus Prime.
- [ ] Ejecutar la **compilación completa** (`Processing >> Start Compilation`).
- [ ] Convertir el `.sof` generado a `.rbf` (desde la carpeta padre de `DE1_SoC_demo`):
  ```bash
  quartus_cpf -c DE1_SoC_demo/hw/quartus/output_files/DE1_SoC_demo.sof DE1_SoC_demo/sdcard/fat32/socfpga.rbf
  ```

---

### Fase 2: Construcción del Sistema ARM-Linux y Grabación de la Tarjeta microSD

Tienes **dos rutas** posibles: la **Ruta A (automatizada con script, recomendada por el tutorial)** o la **Ruta B (manual paso a paso)**.

#### Ruta A — Automatizada con `create_linux_system.sh` (Pasos 33–35)
- [ ] Verificar que `DE1_SoC_demo/sdcard/` (con `ext3_rootfs.tar.gz` y `fat32/socfpga.rbf`) y `DE1_SoC_demo/create_linux_system.sh` estén en su sitio.
- [ ] Abrir `create_linux_system.sh` y revisar las constantes iniciales (rutas, dispositivo de la SD y tamaños en `partition_sdcard()` si tu microSD no es de 64 GB).
- [ ] Insertar la microSD en el PC host y ejecutar desde `DE1_SoC_demo/` (en el *Embedded Command Shell*):
  ```bash
  chmod +x create_linux_system.sh
  sudo ./create_linux_system.sh
  ```
- [ ] Esperar a que termine (puede tardar **~45 minutos**). Al finalizar, pasar directamente a la **Fase 3**.

#### Ruta B — Manual Paso a Paso (Pasos 36–86)
Ejecutar todo desde el *Altera Embedded Command Shell*:

1. **Preloader (Pasos 36–43):**
   - [ ] Ejecutar `bsp-editor` $\to$ `File > New HPS BSP...`.
   - [ ] *Preloader Settings Directory:* `DE1_SoC_demo/hw/quartus/hps_isw_handoff/soc_system_hps_0`.
   - [ ] Desmarcar *Use default locations* y fijar *BSP target directory:* `DE1_SoC_demo/sw/hps/preloader`.
   - [ ] En `spl.boot`, activar **`FAT_SUPPORT`**, hacer clic en **Generate** y cerrar `bsp-editor`.
   - [ ] Compilar y copiar el binario:
     ```bash
     cd DE1_SoC_demo/sw/hps/preloader
     make
     cp preloader-mkpimage.bin ../../../sdcard/a2/preloader-mkpimage.bin
     ```

2. **U-Boot y script de arranque (Pasos 44–58):**
   - [ ] Clonar, configurar y hacer checkout:
     ```bash
     export ARCH=arm
     export CROSS_COMPILE=arm-linux-gnueabihf-
     git clone https://github.com/altera-opensource/u-boot-socfpga.git DE1_SoC_demo/sw/hps/u-boot
     cd DE1_SoC_demo/sw/hps/u-boot
     make distclean
     git checkout b104b3dc1dd90cdbf67ccf3c51b06e4f1592fe91
     make socfpga_cyclone5_config
     ```
   - [ ] Editar `include/configs/socfpga_cyclone5_socdk.h` reemplazando las macros:
     ```c
     #define CONFIG_BOOTCOMMAND "run callscript"
     #define CONFIG_EXTRA_ENV_SETTINGS \
         "scriptfile=u-boot.scr\0" \
         "fpgadata=0x2000000\0" \
         "callscript=fatload mmc 0:1 $fpgadata $scriptfile; source $fpgadata\0"
     ```
   - [ ] Compilar U-Boot con `make`.
   - [ ] Crear `DE1_SoC_demo/sw/hps/u-boot/u-boot.script` con el contenido de la Figura 37:
     ```bash
     echo --- Resetting Env variables ---
     env default -a

     echo --- Setting Env variables ---
     setenv bootimage zImage;
     setenv fdtaddr 0x00000100
     setenv fdtimage socfpga.dtb;
     setenv mmcboot 'setenv bootargs mem=1024M console=ttyS0,115200 root=${mmcroot} rw rootwait; bootz ${loadaddr} - ${fdtaddr}';
     setenv mmcload 'mmc rescan; ${mmcloadcmd} mmc 0:${mmcloadpart} ${loadaddr} ${bootimage}; ${mmcloadcmd} mmc 0:${mmcloadpart} ${fdtaddr} ${fdtimage}'
     setenv mmcloadcmd fatload
     setenv mmcloadpart 1
     setenv mmcroot /dev/mmcblk0p2
     setenv stderr serial
     setenv stdin serial
     setenv stdout serial
     saveenv;

     echo --- Programming FPGA ---
     fatload mmc 0:1 ${fpgadata} socfpga.rbf;
     fpga load 0 ${fpgadata} ${filesize};
     bridge enable;

     echo --- Booting Linux ---
     run mmcload;
     run mmcboot;
     ```
   - [ ] Compilar el script a binario y copiar imágenes a `sdcard/fat32/`:
     ```bash
     mkimage -A arm -O Linux -T script -C none -a 0 -e 0 -n DE1_SoC_demo -d u-boot.script u-boot.scr
     cp u-boot.img u-boot.scr ../../../sdcard/fat32/
     ```

3. **Kernel de Linux (Pasos 59–73):**
   - [ ] Clonar, configurar y abrir `menuconfig`:
     ```bash
     git clone https://github.com/altera-opensource/linux-socfpga.git DE1_SoC_demo/sw/hps/linux/source
     cd DE1_SoC_demo/sw/hps/linux/source
     export ARCH=arm
     export CROSS_COMPILE=arm-linux-gnueabihf-
     make distclean
     git checkout 9735a22799b9214d17d3c231fe377fc852f042e9
     make socfpga_defconfig
     make menuconfig
     ```
   - [ ] En `menuconfig`, habilitar según Figuras 39–44:
     - `Networking support > Wireless` (`cfg80211`, `mac80211`, `Minstrel`, etc.)
     - `Networking support > RF switch subsystem support`
     - `Device Drivers > Network device support > Wireless LAN` (familia Realtek)
     - `Device Drivers > Staging drivers` (`Realtek RTL8188EU`)
     - `Device Drivers > USB support > USB Serial Converter support` (FTDI y drivers seriales)
     - Guardar (*Save*) y salir (*Exit*).
   - [ ] Compilar Device Tree y Kernel, y copiar a `sdcard/fat32/`:
     ```bash
     make socfpga_cyclone5_socdk.dtb
     make zImage
     cp arch/arm/boot/zImage ../../../../sdcard/fat32/zImage
     cp arch/arm/boot/dts/socfpga_cyclone5_socdk.dtb ../../../../sdcard/fat32/socfpga.dtb
     ```

4. **Particionamiento y escritura en la microSD (Pasos 74–86):**
   - [ ] Confirmar que `DE1_SoC_demo/sdcard/` tenga exactamente:
     - `a2/preloader-mkpimage.bin`
     - `ext3_rootfs.tar.gz`
     - `fat32/{socfpga.dtb, socfpga.rbf, u-boot.img, u-boot.scr, zImage}`
   - [ ] Insertar la microSD e identificar su dispositivo con `lsblk` (p. ej. `/dev/sdb` o `/dev/mmcblk0`). **Verificar dos veces antes de particionar para no borrar el disco del PC.**
   - [ ] Particionar con `sudo fdisk /dev/<DEV>` (ajustando `+5000M` y `+55000M` al tamaño de tu microSD):
     - Partición 3 (Preloader): `n` $\to$ `p` $\to$ `3` $\to$ Enter $\to$ `+4096` (o `4096` sectores) $\to$ `t` $\to$ `3` $\to$ `a2`
     - Partición 1 (FAT32): `n` $\to$ `p` $\to$ `1` $\to$ Enter $\to$ `+5000M` $\to$ `t` $\to$ `1` $\to$ `b`
     - Partición 2 (EXT3): `n` $\to$ `p` $\to$ `2` $\to$ Enter $\to$ `+55000M` (o Enter para resto) $\to$ `t` $\to$ `2` $\to$ `83`
     - Guardar y salir: `w`.
   - [ ] Formatear y copiar archivos (reemplazando `<P1>`, `<P2>`, `<P3>` por las particiones reales, p. ej. `sdb1/2/3` o `mmcblk0p1/2/3`):
     ```bash
     sudo mkfs.vfat /dev/<P1>
     sudo mkfs.ext3 -F /dev/<P2>

     mkdir -p DE1_SoC_demo/sdcard/mount_point_fat32 DE1_SoC_demo/sdcard/mount_point_ext3
     sudo mount /dev/<P1> DE1_SoC_demo/sdcard/mount_point_fat32
     sudo mount /dev/<P2> DE1_SoC_demo/sdcard/mount_point_ext3

     sudo dd if=DE1_SoC_demo/sdcard/a2/preloader-mkpimage.bin of=/dev/<P3> bs=64k seek=0
     sudo cp DE1_SoC_demo/sdcard/fat32/* DE1_SoC_demo/sdcard/mount_point_fat32/
     (cd DE1_SoC_demo/sdcard/mount_point_ext3 && sudo tar -xzf ../ext3_rootfs.tar.gz)

     sudo sync
     sudo umount DE1_SoC_demo/sdcard/mount_point_fat32 DE1_SoC_demo/sdcard/mount_point_ext3
     rm -rf DE1_SoC_demo/sdcard/mount_point_fat32 DE1_SoC_demo/sdcard/mount_point_ext3
     ```
     *(Nota: se corrigió el error tipográfico `mount_point_fat32sudo` presente en el Paso 82 del PDF).*

---

### Fase 3: Arranque de Linux y Conectividad en la DE1-SoC (Pasos 87–97)

- [ ] **Antes de encender la tarjeta:** verificar el DIP switch **`SW10` (`MSEL[4:0]`)** en la cara inferior de la DE1-SoC: todos los interruptores 1 a 5 en posición **`"0"`** (`00000`) para arrancar y cargar la FPGA desde U-Boot/microSD.
- [ ] Insertar la microSD, conectar el cable Ethernet al mismo router del PC y conectar el cable Mini-USB al puerto UART-to-USB.
- [ ] En el PC host, abrir consola serial:
  ```bash
  sudo minicom --device /dev/ttyUSB0
  ```
  - Configurar (`Ctrl+A`, `Z`, `O` $\to$ *Serial Port Setup*): **`115200 8N1`**, *Hardware Flow Control:* **No**, *Software Flow Control:* **No**.
- [ ] Encender la DE1-SoC, esperar la secuencia de arranque de Ubuntu e iniciar sesión (usuario/clave por defecto mostrados en el banner, normalmente `ubuntu` / `temppwd`).
- [ ] Consultar la IP asignada a `eth0` mediante `ifconfig`.
- [ ] Desde otra terminal del PC host, conectarse por SSH:
  ```bash
  ssh ubuntu@<IP_DE1_SoC>
  ```
- [ ] Configurar la contraseña de `root`:
  ```bash
  sudo passwd root
  ```
- [ ] *(Opcional, Pasos 96–97)* Configurar archivo *swap* si se requiere mayor memoria virtual (`swapon --show`, `fallocate` o `dd`, `chmod 600`, `mkswap`, `swapon`, `/etc/fstab`).
- [ ] **Regla de oro:** cada vez que necesites apagar la tarjeta, ejecuta primero `sudo shutdown -h now` antes de accionar el interruptor de encendido para evitar corromper la microSD.

---

### Fase 4: Aplicación Base en C-Linux (`linux_hps.c`, Pasos 98–101)

- [ ] Confirmar que `DE1_SoC_demo/sw/hps/application/hps_soc_system.h` fue generado. Si no existe, generarlo en el PC host desde el *Embedded Command Shell*:
  ```bash
  export PATH=~/intelFPGA_lite/18.1/quartus/sopc_builder/bin:$PATH
  sopc-create-header-files DE1_SoC_demo/hw/quartus/soc_system.sopcinfo \
    --single DE1_SoC_demo/sw/hps/application/hps_soc_system.h --module hps_0
  ```
- [ ] Verificar en `linux_hps.c` que los `#define` de los *offsets* (`HEX_0_BASE`..`HEX_5_BASE`, `BUTTONS_0_BASE`, `SWITCHES_0_BASE`, `LEDS_0_BASE`) coincidan con tu archivo `hps_soc_system.h` (o incluir `#include "hps_soc_system.h"` directamente).
- [ ] En la DE1-SoC (vía SSH), crear la carpeta de trabajo:
  ```bash
  mkdir -p ~/SoC_apps && cd ~/SoC_apps
  ```
- [ ] Copiar `linux_hps.c` desde el PC host a la DE1-SoC:
  ```bash
  scp DE1_SoC_demo/sw/hps/application/linux_hps.c ubuntu@<IP_DE1_SoC>:/home/ubuntu/SoC_apps/
  ```
- [ ] En la DE1-SoC, compilar y ejecutar con permisos de `root` (necesarios para `/dev/mem`):
  ```bash
  gcc linux_hps.c -o linux_hps
  sudo ./linux_hps
  ```
- [ ] **Verificación en hardware:** accionar los 10 switches (`SW[9:0]`) y comprobar que:
  1. Cada LED (`LEDR[9:0]`) sigue el estado de su interruptor correspondiente.
  2. Los 6 displays 7-segmentos (`HEX5..HEX0`) muestran el valor decimal del número binario en los switches (`0` a `1023`).

---

### Fase 5: Ejercicio Propuesto — Aplicación con los 4 Botones de la FPGA (Sección 8)

- [ ] Diseñar una aplicación propia en C-Linux (p. ej. `DE1_SoC_demo/sw/hps/application/linux_hps_buttons.c`) que emplee la rutina de lectura de botones activos en bajo:
  ```c
  bool is_fpga_button_pressed(int button_number, volatile unsigned int *base) {
      // buttons are active-low
      return !((*base) & (1 << button_number));
  }
  ```
  *(Nota: la Figura 55 del PDF omite `!(` al inicio de la expresión; con `!((*base) & (1 << button_number))` se corrige el error de paréntesis y la lógica activa en bajo).*
- [ ] Definir una acción clara para cada uno de los **4 botones** (`KEY0`..`KEY3`) sobre los periféricos de la FPGA (por ejemplo: contador con incremento/decremento, carga de valor desde switches, reinicio a cero, cambio de modo decimal/hexadecimal o desplazamiento en LEDs).
- [ ] Implementar detección de flanco/antirrebote por software en el bucle de *polling* (guardando el estado previo del botón y/o usando `usleep`) para que una pulsación no dispare múltiples veces.
- [ ] Transferir por `scp`, compilar en la DE1-SoC (`gcc linux_hps_buttons.c -o linux_hps_buttons`) y validar físicamente con `sudo ./linux_hps_buttons`.

---

### Fase 6: Recopilación de Evidencias para el Reporte Final

Guardar en `reports/Taller7/images/` las evidencias necesarias para documentar luego `reporte_taller7.md`:
- [ ] Captura del sistema ensamblado en **Platform Designer** (`soc_system.qsys`) y sus direcciones base.
- [ ] Captura del resumen de compilación (**Compilation Report / Fitter Summary**) en **Quartus Prime**.
- [ ] Captura de la terminal serial (`minicom`) con el arranque de Ubuntu en la DE1-SoC y el comando `ifconfig`.
- [ ] Captura de la sesión **SSH** compilando y ejecutando `linux_hps` y la aplicación de botones.
- [ ] Fotografías o enlace a video corto demostrando el funcionamiento físico en la DE1-SoC:
  - Aplicación base (`linux_hps`: switches $\to$ LEDs + valor decimal en 7-segmentos).
  - Ejercicio propuesto (respuesta de los 4 botones sobre LEDs y displays).
