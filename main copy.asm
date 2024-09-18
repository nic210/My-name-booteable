[BITS 16]
org 0x1000

SCREEN_WIDTH equ 80
SCREEN_HEIGHT equ 25
BUFFER_SIZE equ SCREEN_WIDTH * SCREEN_HEIGHT

section .data
; Representaciones predefinidas de "Kevin"
kevin_normal db 'KEVIN', 0
kevin_left db 'K', 'E', 'V', 'I', 'N', 0
kevin_right db 'N', 'I', 'V', 'E', 'K', 0
kevin_180 db 'NIVEK', 0

; Representaciones predefinidas de "Nicol"
nicol_normal db 'NICOL', 0
nicol_left db 'N', 'I', 'C', 'O', 'L', 0
nicol_right db 'L', 'O', 'C', 'I', 'N', 0
nicol_180 db 'LOCIN', 0

; Representaciones predefinidas de "Edeer"
edeer_normal db 'EDER', 0
edeer_left db 'E', 'D', 'E','R', 0
edeer_right db 'R', 'E','D', 'E', 0
edeer_180 db 'REDE', 0

; Tabla de punteros a las versiones rotadas de los nombres
name_pointers_normal dw kevin_normal, nicol_normal, edeer_normal
name_pointers_left dw kevin_left, nicol_left, edeer_left
name_pointers_right dw kevin_right, nicol_right, edeer_right
name_pointers_180 dw kevin_180, nicol_180, edeer_180

; Instrucciones
instructions db '"WASD":juegar "r":reiniciar "q":salir', 0
instructions_length equ $ - instructions

section .bss
screen_matrix resb BUFFER_SIZE
name_index resb 1        ; Índice del nombre actual
rotation_index resb 1    ; Índice para la rotación (0=normal, 1=izquierda, 2=derecha, 3=180)
current_position resw 1  ; Posición actual del nombre en la pantalla

section .text
start:
    ; Configurar el modo de video (80x25 texto)
    mov ax, 0x0003
    int 0x10

    ; Inicializar índices
    mov byte [name_index], 0
    mov byte [rotation_index], 0

    ; Generar posición aleatoria inicial
    call get_random_position
    mov [current_position], ax

    ; Mostrar instrucciones
    call show_instructions

    ; Esperar entrada del teclado para iniciar el juego
    call wait_for_key

    ; Limpiar la pantalla completamente antes de iniciar el juego
    call clear_screen

    ; Iniciar el bucle principal del juego
    jmp main_loop

main_loop:
    ; Inicializar la matriz de la pantalla
    call init_screen_matrix

    ; Colocar el nombre actual en la matriz en la posición actual
    call place_name

    ; Dibujar la matriz en la pantalla
    call draw_screen_matrix

    ; Esperar entrada del teclado
    call wait_for_key

    ; Comprobar si la tecla es 'r' para mostrar instrucciones
    cmp al, 'r'
    je show_instructions_and_continue

    ; Comprobar si es una tecla WASD y rotar el nombre
    cmp al, 'a'  ; Rotación 90 grados a la izquierda
    je rotate_left
    cmp al, 'd'  ; Rotación 90 grados a la derecha
    je rotate_right
    cmp al, 's'  ; Rotación 180 grados
    je rotate_180
    cmp al, 'w'  ; Volver a la rotación normal
    je rotate_normal

    ; Comprobar si la tecla es 'q' para salir
    cmp al, 'q'
    je exit_program

    ; Cualquier otra tecla, continuar el bucle
    jmp continue_loop

rotate_left:
    mov byte [rotation_index], 1
    jmp continue_loop

rotate_right:
    mov byte [rotation_index], 2
    jmp continue_loop

rotate_180:
    mov byte [rotation_index], 3
    jmp continue_loop

rotate_normal:
    mov byte [rotation_index], 0
    jmp continue_loop

show_instructions_and_continue:
    call show_instructions
    call wait_for_key
    call clear_screen
    jmp next_name

next_name:
    ; Incrementar el índice y asegurarse de que esté entre 0 y 2
    mov al, [name_index]
    inc al
    cmp al, 3
    jne .store
    xor al, al
.store:
    mov [name_index], al
    ; Resetear la rotación a la normal
    mov byte [rotation_index], 0
    ; Generar nueva posición aleatoria
    call get_random_position
    mov [current_position], ax
    jmp continue_loop

continue_loop:
    ; Limpiar la pantalla y continuar el bucle
    call clear_screen
    jmp main_loop

exit_program:
    ; Salir del programa
    mov ax, 0x4C00
    int 0x21

init_screen_matrix:
    mov di, screen_matrix
    mov cx, BUFFER_SIZE
    mov al, ' '  ; Llenar con espacios
    rep stosb
    ret

place_name:
    ; Seleccionar el nombre basado en el índice y la rotación
    movzx si, byte [name_index]
    shl si, 1  ; Multiplicar el índice por 2 para acceder a la tabla de nombres

    ; Seleccionar la tabla según el índice de rotación
    mov al, [rotation_index]
    cmp al, 1
    je .use_left
    cmp al, 2
    je .use_right
    cmp al, 3
    je .use_180

    ; Usar la versión normal por defecto
    mov ax, [name_pointers_normal + si]
    jmp .set_pointer

.use_left:
    mov ax, [name_pointers_left + si]
    jmp .set_pointer

.use_right:
    mov ax, [name_pointers_right + si]
    jmp .set_pointer

.use_180:
    mov ax, [name_pointers_180 + si]

.set_pointer:
    mov si, ax
    mov di, screen_matrix
    add di, [current_position]  ; Usar la posición actual
    call place_string
    ret
    
place_string:
    ; Comprobar si es una rotación a 90 grados (izquierda o derecha)
    mov al, [rotation_index]
    cmp al, 1  ; Rotación izquierda
    je .vertical_placement
    cmp al, 2  ; Rotación derecha
    je .vertical_placement
    
.horizontal_placement:
.loop:
    lodsb
    cmp al, 0
    je .done
    mov [di], al
    inc di
    jmp .loop

.done:
    ret

.vertical_placement:
.loop_vertical:
    lodsb
    cmp al, 0
    je .done
    mov [di], al
    add di, SCREEN_WIDTH  ; Mueve a la siguiente línea en la matriz
    jmp .loop_vertical

draw_screen_matrix:
    mov ax, 0x0000  ; Página 0, atributo 0 (negro sobre negro)
    mov ds, ax
    mov es, ax
    mov di, screen_matrix
    xor dx, dx      ; Empezar en la esquina superior izquierda
.loop:
    mov ah, 0x02  ; Establecer posición del cursor
    int 0x10
    mov ah, 0x0E  ; Escribir carácter en modo TTY
    mov al, [di]
    int 0x10
    inc di
    inc dl
    cmp dl, SCREEN_WIDTH
    jl .continue
    xor dl, dl
    inc dh
.continue:
    cmp dh, SCREEN_HEIGHT
    jl .loop
    ret

get_random_position:
    ; Leer el temporizador del sistema (conteo de ticks desde el arranque)
    mov ah, 0x00
    int 0x1A    ; Devuelve el conteo en CX:DX
    ; Usar DX como nuestro número "aleatorio"
    mov ax, dx
    xor dx, dx
    mov cx, SCREEN_HEIGHT - 1
    div cx      ; AX / CX, resultado en AX, resto en DX
    inc dx      ; Asegurarse de que la fila no sea 0
    mov bx, dx  ; Guardar fila en BX
    ; Calcular columna aleatoria (0-75)
    mov ax, dx
    xor dx, dx
    mov cx, 76  ; SCREEN_WIDTH - longitud máxima del nombre
    div cx
    imul bx, SCREEN_WIDTH
    add bx, dx
    mov ax, bx
    ret

show_instructions:
    ; Limpiar la pantalla antes de mostrar las instrucciones
    call clear_screen
    
    ; Mostrar las instrucciones en el centro de la pantalla
    mov ax, 0x1300  ; Función 13h de la INT 10h: escribir cadena
    mov bh, 0       ; Página de video
    mov bl, 0x07    ; Atributo (blanco sobre negro)
    mov cx, instructions_length  ; Longitud de la cadena de instrucciones
    mov dh, 5      ; Fila (centrado verticalmente)
    mov dl, 5  ; Columna (centrado horizontalmente)
    push ds
    pop es          ; ES = DS
    mov bp, instructions
    int 0x10
    ret

clear_screen:
    mov ax, 0x0600  ; Función 06h de la INT 10h: limpiar pantalla
    mov bh, 0x07    ; Atributo para espacios en blanco
    mov cx, 0x0000
    mov dx, 0x184F  ; Fila 25, columna 80
    int 0x10
    ret

wait_for_key:
    mov ah, 0x00
    int 0x16    ; Esperar entrada del teclado
    ret