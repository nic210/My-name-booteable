section .data
    ; Definir los nombres a mostrar (terminados con '$' para la función de DOS)
    nombre1 db 'Kevin$'
    nombre2 db 'Nicol$'
    nombre3 db 'Eder$'

    ; Mensaje inicial
    msg db 'Presione "d" para mover el texto a la derecha, "a" para moverlo a la izquierda, "w" para moverlo arriba, "s" para moverlo abajo', 0x0D, 0x0A, '$'
    change_msg db 'Presione "n" para cambiar el nombre', 0x0D, 0x0A, '$'

section .bss
    x_pos resb 1          ; Posición X del cursor, inicializada en 20
    y_pos resb 1          ; Posición Y del cursor, inicializada en 10
    nombre_sel resb 1     ; Selector de nombre, inicializado en 1
    key resb 1            ; Variable para almacenar la tecla presionada

section .text
    org 0x100  ; Punto de inicio para un programa .COM en modo real de DOS

start:
    ; Configurar modo de video 03h (texto, 80x25, 16 colores)
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Mostrar mensajes iniciales
    mov ah, 0x09
    mov dx, msg
    int 0x21

    mov ah, 0x09
    mov dx, change_msg
    int 0x21

    ; Inicializar posición del cursor
    mov byte [x_pos], 20
    mov byte [y_pos], 10
    mov byte [nombre_sel], 1

main_loop:
    ; Leer la tecla presionada
    mov ah, 0x00
    int 0x16            ; Llamada a la interrupción del BIOS para esperar una tecla

    ; Leer la tecla presionada
    mov ah, 0x01        ; Función de BIOS para leer la tecla
    int 0x16            ; Llamada a la interrupción del BIOS para leer la tecla
    mov [key], al

    ; Comprobar si la tecla es 'd' (0x64 en código ASCII)
    cmp al, 'd'
    je move_right

    ; Comprobar si la tecla es 'a' (0x61 en código ASCII)
    cmp al, 'a'
    je move_left

    ; Comprobar si la tecla es 'w' (0x77 en código ASCII)
    cmp al, 'w'
    je move_up

    ; Comprobar si la tecla es 's' (0x73 en código ASCII)
    cmp al, 's'
    je move_down

    ; Comprobar si la tecla es 'n' (0x6E en código ASCII) para cambiar el nombre
    cmp al, 'n'
    je change_name

    jmp main_loop       ; Si no es ninguna tecla manejada, regresar al bucle principal

move_right:
    ; Mover el texto a la derecha
    inc byte [x_pos]    ; Incrementar la posición X
    cmp byte [x_pos], 79
    jg set_pos_x_max    ; Si excede el límite, ajustar a 79
    jmp update_display

move_left:
    ; Mover el texto a la izquierda
    dec byte [x_pos]    ; Decrementar la posición X
    cmp byte [x_pos], 0
    jl set_pos_x_min    ; Si es menor que 0, ajustar a 0
    jmp update_display

move_up:
    ; Mover el texto hacia arriba
    dec byte [y_pos]    ; Decrementar la posición Y
    cmp byte [y_pos], 0
    jl set_pos_y_min    ; Si es menor que 0, ajustar a 0
    jmp update_display

move_down:
    ; Mover el texto hacia abajo
    inc byte [y_pos]    ; Incrementar la posición Y
    cmp byte [y_pos], 24
    jg set_pos_y_max    ; Si excede el límite, ajustar a 24
    jmp update_display

change_name:
    ; Cambiar el nombre que se muestra
    mov al, [nombre_sel]
    inc al              ; Incrementar el selector de nombre
    cmp al, 3
    jg set_name_first   ; Si excede el límite, reiniciar al primer nombre
    mov [nombre_sel], al
    jmp update_display

set_name_first:
    mov byte [nombre_sel], 1  ; Reiniciar al primer nombre
    jmp update_display

set_pos_x_max:
    mov byte [x_pos], 79
    jmp update_display

set_pos_x_min:
    mov byte [x_pos], 0
    jmp update_display

set_pos_y_max:
    mov byte [y_pos], 24
    jmp update_display

set_pos_y_min:
    mov byte [y_pos], 0
    jmp update_display

update_display:
    ; Limpiar la pantalla
    mov ah, 0x06        ; Función 0x06 de BIOS: Desplazamiento de pantalla hacia arriba
    mov al, 0            ; Número de líneas a desplazar (0 = limpiar toda la pantalla)
    mov bh, 0x07         ; Atributo de fondo (color blanco sobre negro)
    mov cx, 0            ; Esquina superior izquierda (fila=0, columna=0)
    mov dx, 184Fh        ; Esquina inferior derecha (fila=24, columna=79)
    int 0x10             ; Llamada a la interrupción de BIOS para limpiar la pantalla

    ; Mover el cursor a la nueva posición
    mov ah, 0x02         ; Función de BIOS para mover el cursor
    mov bh, 0x00         ; Página de pantalla (0 para modo de texto)
    mov dh, [y_pos]      ; Fila (0-24)
    mov dl, [x_pos]      ; Columna (0-79)
    int 0x10             ; Llamada a la interrupción de BIOS

    ; Mostrar el nombre en pantalla
    mov al, [nombre_sel] ; Seleccionar el nombre a mostrar
    cmp al, 1
    je show_nombre1
    cmp al, 2
    je show_nombre2
    cmp al, 3
    je show_nombre3
    jmp main_loop

show_nombre1:
    mov ah, 0x09
    mov dx, nombre1
    int 0x21
    jmp main_loop

show_nombre2:
    mov ah, 0x09
    mov dx, nombre2
    int 0x21
    jmp main_loop

show_nombre3:
    mov ah, 0x09
    mov dx, nombre3
    int 0x21
    jmp main_loop

    ; Salir del programa
    mov ax, 0x4C00
    int 0x21            ; Llamada a la interrupción de DOS para salir
