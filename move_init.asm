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
    current_rotation_msg db 'Rotacion actual: $'
    current_name_msg db 'Nombre actual: $'
    newline db 0x0D, 0x0A, '$'  ; Nueva línea

section .bss
    current_rotation resb 1  ; Estado de rotación
    current_name resb 1      ; Nombre seleccionado
    key resb 1               ; Variable para la tecla presionada

section .text
    org 0x100  ; Punto de inicio para un programa .COM en modo real de DOS

start:
    ; Configurar modo de video 03h (texto, 80x25, 16 colores)
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Inicializar estado de rotación y nombre
    mov byte [current_rotation], 0  ; Sin rotación
    mov byte [current_name], 1      ; Nombre seleccionado por defecto: KEVIN

    call clear_screen
    call show_instructions
    call update_display

main_loop:
    ; Leer la tecla presionada
    mov ah, 0x00
    int 0x16            ; Llamada a la interrupción del BIOS para esperar una tecla
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

    ; [El resto de las comprobaciones de teclas permanecen iguales]

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
    call show_current_state
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
    ret

show_current_state:
    mov ah, 0x09
    mov dx, current_rotation_msg
    int 0x21
    
    mov al, [current_rotation]
    add al, '0'
    mov ah, 0x0E
    int 0x10
    
    mov ah, 0x02
    mov dl, 0x0D
    int 0x21
    mov dl, 0x0A
    int 0x21
    
    mov ah, 0x09
    mov dx, current_name_msg
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

display_name:
    mov al, [current_name]
    cmp al, 1
    je display_kevin
    cmp al, 2
    je display_eder
    cmp al, 3
    je display_nicol
    ret

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
    mov ah, 0x09
    mov dx, kevin_original
    int 0x21
    ret

show_kevin_left:
    mov ah, 0x09
    mov dx, kevin_left
    int 0x21
    ret

show_kevin_right:
    mov ah, 0x09
    mov dx, kevin_right
    int 0x21
    ret

show_kevin_180:
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
    mov ah, 0x09
    mov dx, eder_original
    int 0x21
    ret

show_eder_left:
    mov ah, 0x09
    mov dx, eder_left
    int 0x21
    ret

show_eder_right:
    mov ah, 0x09
    mov dx, eder_right
    int 0x21
    ret

show_eder_180:
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
    mov ah, 0x09
    mov dx, nicol_original
    int 0x21
    ret

show_nicol_left:
    mov ah, 0x09
    mov dx, nicol_left
    int 0x21
    ret

show_nicol_right:
    mov ah, 0x09
    mov dx, nicol_right
    int 0x21
    ret

show_nicol_180:
    mov ah, 0x09
    mov dx, nicol_180
    int 0x21
    ret