section .data
    ; Definir el nombre a mostrar (terminado con '$' para la función de DOS)
    nombre db 'Hola, Mundo!', 0x0D, 0x0A, '$'
    msg db 'Presione la flecha derecha para mover el texto', 0x0D, 0x0A, '$'

section .bss
    x_pos resb 1  ; Posición X del cursor, inicializada en 20

section .text
    org 0x100  ; Punto de inicio para un programa .COM en modo real de DOS

start:
    ; Configurar modo de video 03h (texto, 80x25, 16 colores)
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Mostrar mensaje inicial
    mov ah, 0x09
    mov dx, msg
    int 0x21

    ; Inicializar posición del cursor
    mov byte [x_pos], 20

main_loop:
    ; Mover el cursor a la posición deseada
    mov ah, 0x02        ; Función de BIOS para mover el cursor
    mov bh, 0x00        ; Página de pantalla (0 para modo de texto)
    mov dh, 10          ; Fila (0-24)
    mov dl, [x_pos]     ; Columna (0-79)
    int 0x10            ; Llamada a la interrupción del BIOS

    ; Mostrar el nombre en pantalla
    mov ah, 0x09
    mov dx, nombre
    int 0x21

    ; Esperar a que el usuario presione una tecla
    mov ah, 0x00
    int 0x16            ; Llamada a la interrupción del BIOS para esperar una tecla

    ; Leer la tecla presionada
    mov ah, 0x01        ; Función de BIOS para leer la tecla
    int 0x16            ; Llamada a la interrupción del BIOS para leer la tecla

    ; Comprobar si la tecla es la flecha derecha
    cmp al, 0x4D        ; Código de escaneo para la flecha derecha
    jne main_loop       ; Si no es la flecha derecha, regresar al bucle principal

    ; Mover el texto a la derecha
    inc byte [x_pos]    ; Incrementar la posición X

    ; Asegurarse de que la posición X no se pase del límite
    cmp byte [x_pos], 79
    jg set_pos_max      ; Si excede el límite, ajusta a 79

    ; Limpiar la pantalla y volver a mostrar el mensaje
    mov ah, 0x06        ; Función de DOS para desplazar la pantalla
    mov al, 0x00        ; Desplazamiento hacia arriba
    mov bh, 0x07        ; Atributo de color de fondo (gris oscuro sobre negro)
    mov ch, 0x00        ; Fila superior
    mov cl, 0x00        ; Columna izquierda
    mov dh, 0x18        ; Fila inferior
    mov dl, 0x4F        ; Columna derecha
    int 0x10            ; Llamada a la interrupción del BIOS

    jmp main_loop       ; Regresar al bucle principal

set_pos_max:
    mov byte [x_pos], 79 ; Ajustar posición X a 79 si excede el límite
    jmp main_loop       ; Regresar al bucle principal

    ; Salir del programa
    mov ax, 0x4C00
    int 0x21            ; Llamada a la interrupción de DOS para salir


