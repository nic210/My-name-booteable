org 0x7C00      ; Establecer el origen a 0x7C00, el inicio del sector de arranque

bits 16         ; Modo real de 16 bits

start:
    ; Configurar el segmento de datos
    mov ax, 0x07C0
    mov ds, ax
    mov es, ax

    ; Mostrar un mensaje de bienvenida
    mov si, welcome_msg
    call print_string

    ; Pedir al usuario que presione una tecla
    mov si, prompt_msg
    call print_string

    ; Leer un carácter del teclado
    call read_char

    ; Mostrar una nueva línea
    mov si, newline
    call print_string

    ; Mostrar el carácter leído
    mov si, echo_msg
    call print_string
    mov al, [char_buffer]  ; Cargar el carácter leído en AL
    call print_char

    ; Bucle infinito para prevenir reinicio
    jmp $

; Imprimir una cadena de texto terminada en null
print_string:
    lodsb               ; Cargar el siguiente carácter desde DS:SI en AL
    or al, al           ; Verificar si AL es nulo (fin de la cadena)
    jz end_print_string ; Si es nulo, saltar al final
    
    call print_char     ; Imprimir el carácter en AL
    jmp print_string    ; Repetir para el siguiente carácter
    
end_print_string:
    ret

; Imprimir un carácter en AL usando la función BIOS 0x0E
print_char:
    mov ah, 0x0E       ; Función teletipo de BIOS
    int 0x10           ; Llamar a la interrupción de BIOS
    ret

; Leer un carácter del teclado usando la función BIOS 0x00
read_char:
    mov ah, 0x00       ; Función de entrada del teclado de BIOS
    int 0x16           ; Llamar a la interrupción de BIOS
    mov [char_buffer], al ; Almacenar el carácter leído en el buffer
    ret

; Sección de datos
welcome_msg db "Welcome to My Bootloader!", 0
prompt_msg db "Press any key: ", 0
echo_msg db "You pressed: ", 0
newline db 0x0D, 0x0A, 0  ; CR LF terminador nulo
char_buffer db 0  ; Buffer para almacenar el carácter leído

times 510 - ($ - $$) db 0 ; Rellenar el bootloader a 510 bytes
dw 0xAA55              ; Firma del bootloader en 511-512 bytes
