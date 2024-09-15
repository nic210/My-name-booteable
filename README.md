# My Name Bootable

Este repositorio contiene un proyecto de código en ensamblador que se puede compilar y ejecutar en un entorno DOS. A continuación, se describen los pasos para compilar y ejecutar el código.

## Requisitos

- [NASM](https://www.nasm.us/) (Assembler Netwide)
- [DOSBox](https://www.dosbox.com/) (Emulador DOS)

## Instrucciones

### 1. Clona el repositorio

git clone https://github.com/tu_usuario/My-name-booteable.git
cd My-name-booteable


Para el .coom usa nombres acortado como game, move, run para que dosbox los encuentre facilmente
### 2. Crear el archivo .com
nasm -f bin -o game.com move_names.asm

### 3. Ejecutar codigo
dosbox game.com
