# Nombre de los archivos
BOOTLOADER = boot.asm
HELLO = main.asm
BOOTLOADER_BIN = boot.bin
HELLO_BIN = main.bin
DISK_IMG = disk.img

# Ensamblador
NASM = nasm

# Opciones de NASM
NASMFLAGS = -f bin

# QEMU
QEMU = qemu-system-x86_64

# Reglas
all: run

# Compilar el bootloader
$(BOOTLOADER_BIN): $(BOOTLOADER)
	$(NASM) $(NASMFLAGS) -o $@ $<

# Compilar el programa hello
$(HELLO_BIN): $(HELLO)
	$(NASM) $(NASMFLAGS) -o $@ $<

# Crear la imagen de disco y escribir los binarios en ella
$(DISK_IMG): $(BOOTLOADER_BIN) $(HELLO_BIN)
	dd if=/dev/zero of=$(DISK_IMG) bs=512 count=2880
	dd if=$(BOOTLOADER_BIN) of=$(DISK_IMG) bs=512 count=1 conv=notrunc
	dd if=$(HELLO_BIN) of=$(DISK_IMG) bs=512 seek=1 count=1 conv=notrunc

# Ejecutar con QEMU
run: $(DISK_IMG)
	$(QEMU) -fda $(DISK_IMG)

# Limpiar archivos generados
clean:
	rm -f $(BOOTLOADER_BIN) $(HELLO_BIN) $(DISK_IMG)

.PHONY: all run clean