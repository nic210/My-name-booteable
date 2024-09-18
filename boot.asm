[BITS 16]           ; Modo de 16 bits (real mode)

org 0x7C00          ; El bootloader se carga en la dirección 0x7C00

start:
    ; Imprimir un mensaje indicando que el bootloader está cargado
    mov si, boot_msg
    call print_string

    ; Limpiar la pantalla antes de cargar el segundo programa
    call clear_screen

    ; Cargar el segundo sector (hello.asm) en la memoria en 0x1000
    mov ax, 0x0000     ; Segmento de destino
    mov es, ax         ; Configurar segmento extra
    mov bx, 0x1000     ; Dirección de memoria destino
    mov ah, 0x02       ; Función 02h: Leer sectores
    mov al, 1          ; Leer 1 sector
    mov ch, 0          ; Pista 0
    mov cl, 2          ; Sector 2 (después del bootloader)
    mov dh, 0          ; Cabeza 0
    mov dl, 0          ; Disco 0 (primer disco)
    int 0x13           ; Llamada a la BIOS para leer sector
    jc load_failed    ; Si hubo error, saltar a la etiqueta load_failed

    ; Transferir el control al código cargado en 0x1000
    jmp 0x0000:0x1000

load_failed:
    ; Manejo de errores si la carga falla
    mov si, error_msg
    call print_string
    hlt                 ; Detener la CPU

print_string:
    mov ah, 0x0E       ; Función 0Eh: Imprimir carácter en TTY
.next_char:
    lodsb              ; Cargar siguiente carácter de DS:SI en AL
    cmp al, 0          ; ¿Es el carácter nulo?
    je .done           ; Si es nulo, termina
    int 0x10           ; Interrupción de BIOS para imprimir
    jmp .next_char
.done:
    ret

clear_screen:
    mov ax, 0x0600     ; Función 06h: Desplazar hacia arriba la pantalla
    mov bh, 0x07       ; Atributo del color de fondo (gris claro sobre negro)
    mov cx, 0x0000     ; Esquina superior izquierda de la pantalla
    mov dx, 0x184F     ; Esquina inferior derecha (80x25)
    int 0x10           ; Interrupción de BIOS
    ret

boot_msg db 'Bootloader cargado, ejecutando hello.asm...', 0
error_msg db 'Error al cargar el segundo sector.', 0

times 510-($-$$) db 0   ; Rellenar hasta 510 bytes
dw 0xAA55               ; Firma de sector de arranque
