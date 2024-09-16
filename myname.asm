[BITS 16]

section .data
    ; Definir las versiones de cada nombre según las rotaciones
    ; Nombre KEVIN
    kevin_original db 'KEVIN$', 0
    kevin_left db 'N', 0x0D, 0x0A, 'I', 0x0D, 0x0A, 'V', 0x0D, 0x0A, 'E', 0x0D, 0x0A, 'K', 0x0D, 0x0A, '$', 0
    kevin_right db 'K', 0x0D, 0x0A, 'E', 0x0D, 0x0A, 'V', 0x0D, 0x0A, 'I', 0x0D, 0x0A, 'N', 0x0D, 0x0A, '$', 0
    kevin_180 db 'NIVEK$', 0

    ; Nombre EDER
    eder_original db 'EDER$', 0
    eder_left db 'R', 0x0D, 0x0A, 'E', 0x0D, 0x0A, 'D', 0x0D, 0x0A, 'E', 0x0D, 0x0A, '$', 0
    eder_right db 'E', 0x0D, 0x0A, 'D', 0x0D, 0x0A, 'E', 0x0D, 0x0A, 'R', 0x0D, 0x0A, '$', 0
    eder_180 db 'REDE$', 0

    ; Nombre NICOL
    nicol_original db 'NICOL$', 0
    nicol_left db 'L', 0x0D, 0x0A, 'O', 0x0D, 0x0A, 'C', 0x0D, 0x0A, 'I', 0x0D, 0x0A, 'N', 0x0D, 0x0A, '$', 0
    nicol_right db 'N', 0x0D, 0x0A, 'I', 0x0D, 0x0A, 'C', 0x0D, 0x0A, 'O', 0x0D, 0x0A, 'L', 0x0D, 0x0A, '$', 0
    nicol_180 db 'LOCIN$', 0

    ; Mensajes iniciales
    msg db 'Presione "d" para rotar 90 grados a la izquierda, "a" para rotar 90 grados a la derecha', 0x0D, 0x0A, '$'
    msg2 db 'Presione "w" para rotar 180 grados, "s" para rotar 180 grados en el otro sentido', 0x0D, 0x0A, '$'
    msg3 db 'Presione "1" para KEVIN, "2" para EDER, "3" para NICOL', 0x0D, 0x0A, '$'
    msg4 db 'Presione "r" para reiniciar, "q" para salir', 0x0D, 0x0A, '$'
    newline db 0x0D, 0x0A, '$'  ; Nueva línea

section .bss
    current_rotation resb 1  ; Estado de rotación
    current_name resb 1      ; Nombre seleccionado
    key resb 1               ; Variable para la tecla presionada
    cursor_x resb 1          ; Coordenada X del cursor
    cursor_y resb 1          ; Coordenada Y del cursor

section .text
    org 0x100  ; Punto de inicio para un programa .COM en modo real de DOS

start:
    ; Configurar modo de video 03h (texto, 80x25, 16 colores)
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Mostrar mensajes iniciales
    mov ah, 09h
    lea dx, [msg]
    int 21h

    lea dx, [msg2]
    int 21h

    lea dx, [msg3]
    int 21h

    lea dx, [msg4]
    int 21h

    ; Esperar a que el usuario presione una tecla
    mov ah, 01h     ; Llamada a la función para esperar entrada de teclado
    int 21h         ; Leer el carácter presionado
    ; AL ya contiene la tecla presionada, úsala según la lógica que necesites

    ; Inicializar estado de rotación y nombre
    mov byte [current_rotation], 0  ; Sin rotación
    mov byte [current_name], 1      ; Nombre seleccionado por defecto: KEVIN

    call clear_screen
    call show_instructions
    call update_display

main_loop:
    ; Leer la tecla presionada
    mov ah, 0x00
    int 0x16
    mov [key], al

    ; Comprobar si la tecla es 'd' (rotación a la izquierda)
    cmp al, 'd'
    je rotate_left

    ; Comprobar si la tecla es 'a' (rotación a la derecha)
    cmp al, 'a'
    je rotate_right

    ; Comprobar si la tecla es 'w' (rotación 180 grados)
    cmp al, 'w'
    je rotate_180

    ; Comprobar si la tecla es 's' (volver a la posición original)
    cmp al, 's'
    je rotate_original

    ; Seleccionar nombres
    cmp al, '1'
    je select_kevin

    cmp al, '2'
    je select_eder

    cmp al, '3'
    je select_nicol

    ; Mostrar todos los nombres al presionar '4'
    cmp al, '4'
    je display_all_names

    ; Mover cursor con teclas de flecha
    cmp al, 0x4B  ; Flecha izquierda
    je move_cursor_left
    cmp al, 0x4D  ; Flecha derecha
    je move_cursor_right
    cmp al, 0x48  ; Flecha arriba
    je move_cursor_up
    cmp al, 0x50  ; Flecha abajo
    je move_cursor_down

    ; Reiniciar el programa con 'r'
    cmp al, 'r'
    je restart_program

    ; Salir del programa con 'q'
    cmp al, 'q'
    je exit_program

    jmp main_loop       ; Si no es ninguna tecla manejada, regresar al bucle principal

rotate_left:
    mov byte [current_rotation], 1 ; Rotación a la izquierda
    jmp update_display

rotate_right:
    mov byte [current_rotation], 2 ; Rotación a la derecha
    jmp update_display

rotate_180:
    mov byte [current_rotation], 3 ; Rotación 180 grados
    jmp update_display

rotate_original:
    mov byte [current_rotation], 0 ; Volver a la posición original
    jmp update_display

select_kevin:
    mov byte [current_name], 1
    jmp update_display

select_eder:
    mov byte [current_name], 2
    jmp update_display

select_nicol:
    mov byte [current_name], 3
    jmp update_display

update_display:
    call clear_screen
    call show_instructions

    ; Establecer posición del cursor
    call set_cursor_position

    ; Mostrar el nombre seleccionado
    call display_name
    jmp main_loop

clear_screen:
    mov ah, 0x06        ; Función 0x06 de BIOS: Desplazamiento de pantalla hacia arriba
    mov al, 0            ; Número de líneas a desplazar (0 = limpiar toda la pantalla)
    mov bh, 0x07         ; Atributo de fondo (color blanco sobre negro)
    mov cx, 0            ; Esquina superior izquierda (fila=0, columna=0)
    mov dx, 184Fh        ; Esquina inferior derecha (fila=24, columna=79)
    int 0x10             ; Llamada a la interrupción de BIOS para limpiar la pantalla
    ret

show_instructions:
    mov ah, 0x09
    mov dx, msg
    int 0x21
    mov dx, msg2
    int 0x21
    mov dx, msg3
    int 0x21
    mov dx, msg4
    int 0x21
    ret

show_current_state:
    
    mov al, [current_rotation]
    add al, '0'
    mov ah, 0x0E
    int 0x10
    
    mov ah, 0x02
    mov dl, 0x0D
    int 0x21
    mov dl, 0x0A
    int 0x21
    
    
    mov al, [current_name]
    add al, '0'
    mov ah, 0x0E
    int 0x10
    
    mov ah, 0x02
    mov dl, 0x0D
    int 0x21
    mov dl, 0x0A
    int 0x21
    ret

set_cursor_position:
    mov ah, 0x02      ; Función 0x02: Mover cursor
    mov bh, 0x00      ; Página de pantalla
    mov dh, [cursor_y] ; Fila
    mov dl, [cursor_x] ; Columna
    int 0x10          ; Llamada a la interrupción de BIOS
    ret

move_cursor_left:
    dec byte [cursor_x]
    jmp update_display

move_cursor_right:
    inc byte [cursor_x]
    jmp update_display

move_cursor_up:
    dec byte [cursor_y]
    jmp update_display

move_cursor_down:
    inc byte [cursor_y]
    jmp update_display

restart_program:
    jmp start

exit_program:
    mov ah, 0x4C
    int 0x21

display_name:
    call clear_screen
    
    mov al, [current_name]
    cmp al, 1
    je display_kevin
    cmp al, 2
    je display_eder
    cmp al, 3
    je display_nicol
    ret

display_all_names:
    call clear_screen  ; Limpiar pantalla

    ; Mostrar "KEVIN"
    mov ah, 0x09
    mov dx, kevin_original
    int 0x21
    ; Salto de línea
    mov dx, newline
    int 0x21

    ; Mostrar "EDER"
    mov ah, 0x09
    mov dx, eder_original
    int 0x21
    ; Salto de línea
    mov dx, newline
    int 0x21

    ; Mostrar "NICOL"
    mov ah, 0x09
    mov dx, nicol_original
    int 0x21
    ; Salto de línea
    mov dx, newline
    int 0x21

    jmp main_loop  ; Volver al bucle principal

display_kevin:
    mov al, [current_rotation]
    cmp al, 0
    je show_kevin_original
    cmp al, 1
    je show_kevin_left
    cmp al, 2
    je show_kevin_right
    cmp al, 3
    je show_kevin_180
    ret

show_kevin_original:
    call set_cursor_position
    mov ah, 0x09
    mov dx, kevin_original
    int 0x21
    ret

show_kevin_left:
    call set_cursor_position
    mov ah, 0x09
    mov dx, kevin_left
    int 0x21
    ret

show_kevin_right:
    call set_cursor_position
    mov ah, 0x09
    mov dx, kevin_right
    int 0x21
    ret

show_kevin_180:
    call set_cursor_position
    mov ah, 0x09
    mov dx, kevin_180
    int 0x21
    ret

display_eder:
    mov al, [current_rotation]
    cmp al, 0
    je show_eder_original
    cmp al, 1
    je show_eder_left
    cmp al, 2
    je show_eder_right
    cmp al, 3
    je show_eder_180
    ret

show_eder_original:
    call set_cursor_position
    mov ah, 0x09
    mov dx, eder_original
    int 0x21
    ret

show_eder_left:
    call set_cursor_position
    mov ah, 0x09
    mov dx, eder_left
    int 0x21
    ret

show_eder_right:
    call set_cursor_position
    mov ah, 0x09
    mov dx, eder_right
    int 0x21
    ret

show_eder_180:
    call set_cursor_position
    mov ah, 0x09
    mov dx, eder_180
    int 0x21
    ret


display_nicol:
    mov al, [current_rotation]
    cmp al, 0
    je show_nicol_original
    cmp al, 1
    je show_nicol_left
    cmp al, 2
    je show_nicol_right
    cmp al, 3
    je show_nicol_180
    ret

show_nicol_original:
    call set_cursor_position
    mov ah, 0x09
    mov dx, nicol_original
    int 0x21
    ret

show_nicol_left:
    call set_cursor_position
    mov ah, 0x09
    mov dx, nicol_left
    int 0x21
    ret

show_nicol_right:
    call set_cursor_position
    mov ah, 0x09
    mov dx, nicol_right
    int 0x21
    ret

show_nicol_180:
    call set_cursor_position
    mov ah, 0x09
    mov dx, nicol_180
    int 0x21
    ret