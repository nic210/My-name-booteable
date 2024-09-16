# Target por defecto
all: myname.bin

# Combina el bootloader y el juego en un archivo binario
myname.bin: bootloader.bin myname.com
	cat bootloader.bin myname.com > myname.bin

# Compila el bootloader
bootloader.bin: bootloader.asm
	nasm -f bin -o bootloader.bin bootloader.asm

# Compila el juego
myname.com: myname.asm
	nasm -f bin -o myname.com myname.asm

# Limpia los archivos generados
clean:
	rm -f *.bin *.com
