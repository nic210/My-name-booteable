; Programa: Juego de Rotación de Nombres
; Descripción: Muestra los nombres de dos integrantes en una posición aleatoria
;              y permite rotarlos según las teclas de flecha presionadas.
; Ensamblador: NASM/SASM
; Plataforma: DOS (Modo real)



section .data
    ; Definición de las letras como matrices de bits (8x8 píxeles por letra)
    letra_A db 0x18, 0x24, 0x42, 0x7E, 0x42, 0x42, 0x42, 0x00
    letra_B db 0x7C, 0x42, 0x42, 0x7C, 0x42, 0x42, 0x7C, 0x00
    letra_C db 0x3C, 0x42, 0x40, 0x40, 0x40, 0x42, 0x3C, 0x00
    letra_D db 0x78, 0x44, 0x42, 0x42, 0x42, 0x44, 0x78, 0x00
    letra_E db 0x7E, 0x40, 0x40, 0x7C, 0x40, 0x40, 0x7E, 0x00
    letra_I db 0x7E, 0x18, 0x18, 0x18, 0x18, 0x18, 0x7E, 0x00
    letra_K db 0x42, 0x44, 0x48, 0x70, 0x48, 0x44, 0x42, 0x00
    letra_L db 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x7E, 0x00
    letra_N db 0x42, 0x62, 0x52, 0x4A, 0x46, 0x42, 0x42, 0x00
    letra_O db 0x3C, 0x42, 0x42, 0x42, 0x42, 0x42, 0x3C, 0x00
    letra_R db 0x7C, 0x42, 0x42, 0x7C, 0x48, 0x44, 0x42, 0x00
    letra_V db 0x42, 0x42, 0x42, 0x42, 0x42, 0x24, 0x18, 0x00

    ; Nombres para mostrar
    nombres db 'Kevin', 0, 'Nicol', 0, 'Eder', 0, 0

    ; Tabla de punteros a las letras
    letras dw letra_A  ; Índice 0 - 'A'
           dw letra_B  ; Índice 1 - 'B'
           dw letra_C  ; Índice 2 - 'C'
           dw letra_D  ; Índice 3 - 'D'
           dw letra_E  ; Índice 4 - 'E'
           dw letra_I  ; Índice 5 - 'I'
           dw letra_K  ; Índice 6 - 'K'
           dw letra_L  ; Índice 7 - 'L'
           dw letra_N  ; Índice 8 - 'N'
           dw letra_O  ; Índice 9 - 'O'
           dw letra_R  ; Índice 10 - 'R'
           dw letra_V  ; Índice 11 - 'V'

    msg_confirmacion db 'Presiona Enter para comenzar$',0

section .bss
    ; Variables para la posición y estado
    posX resw 1
    posY resw 1
    matriz_letra resb 8  ; Espacio para una letra de 8x8 bits
    temp_matriz resb 8   ; Espacio temporal para rotaciones

section .text
start:
    ; Configurar modo de video 13h (320x200, 256 colores)
    mov ah, 0x00
    mov al, 0x13
    int 0x10

    ; Mostrar pantalla de confirmación
    call clear_screen
    call mostrar_confirmacion

    ; Esperar a que el usuario presione Enter
wait_enter:
    mov ah, 0x00
    int 0x16
    cmp al, 0x1C  ; Código de Enter
    jne wait_enter

    ; Iniciar el juego
start_game:
    call clear_screen

    ; Generar posición aleatoria
    call generar_posicion_aleatoria

    ; Dibujar los nombres en pantalla
    call dibujar_nombres

main_loop:
    ; Comprobar si hay una tecla presionada
    mov ah, 0x01
    int 0x16
    jz main_loop  ; Si no hay tecla, continuar el bucle

    ; Leer la tecla
    mov ah, 0x00
    int 0x16

    cmp al, 0xE0
    jne check_other_keys

    ; Tecla extendida (flechas)
    mov ah, 0x00
    int 0x16
    mov bl, al    ; Guardar código de la tecla en BL

    cmp bl, 0x4B  ; Flecha izquierda
    je rotate_left
    cmp bl, 0x4D  ; Flecha derecha
    je rotate_right
    cmp bl, 0x48  ; Flecha arriba
    je rotate_up
    cmp bl, 0x50  ; Flecha abajo
    je rotate_down
    jmp main_loop

check_other_keys:
    cmp al, 'R'       ; Tecla 'R' para reiniciar
    je restart_game
    cmp al, 0x1B      ; Código ASCII de 'Esc' para salir
    je exit_game
    jmp main_loop

rotate_left:
    ; Rotar las letras 90 grados a la izquierda
    call rotar_letras_90_izquierda
    call dibujar_nombres
    jmp main_loop

rotate_right:
    ; Rotar las letras 90 grados a la derecha
    call rotar_letras_90_derecha
    call dibujar_nombres
    jmp main_loop

rotate_up:
    ; Rotar las letras 180 grados
    call rotar_letras_180
    call dibujar_nombres
    jmp main_loop

rotate_down:
    ; Rotar las letras 180 grados
    call rotar_letras_180
    call dibujar_nombres
    jmp main_loop

restart_game:
    call clear_screen
    jmp start_game

exit_game:
    ; Restaurar modo de video a texto y salir
    mov ah, 0x00
    mov al, 0x03   ; Modo de texto 80x25
    int 0x10
    mov ax, 0x4C00
    int 0x21

;------------------------------------------------
; Rutinas auxiliares
;------------------------------------------------

clear_screen:
    ; Limpiar pantalla en modo 13h (llenar con color negro)
    pusha
    mov ax, 0A000h
    mov es, ax
    xor di, di
    mov cx, 320*200/4  ; Cada escritura son 4 bytes
    xor eax, eax       ; Color negro
    rep stosd
    popa
    ret

mostrar_confirmacion:
    ; Mostrar mensaje de confirmación para iniciar el juego
    pusha
    ; Mensaje: "Presiona Enter para comenzar"
    mov ah, 09h
    mov dx, msg_confirmacion
    int 21h
    popa
    ret

generar_posicion_aleatoria:
    ; Generar coordenadas X e Y aleatorias
    pusha
    mov ah, 2Ch
    int 21h      ; Obtener el contador de sistema para usar como semilla
    mov bx, dx   ; Usar DX como semilla

    ; Generar X aleatoria entre 0 y (320 - ancho del texto)
    mov ax, bx
    xor dx, dx
    mov cx, 220  ; Margen para que el texto no salga de pantalla
    div cx
    mov [posX], dx  ; posX = dx

    ; Generar Y aleatoria entre 0 y (200 - alto del texto)
    mov ax, bx
    xor dx, dx
    mov cx, 180  ; Margen para que el texto no salga de pantalla
    div cx
    mov [posY], dx  ; posY = dx
    popa
    ret

dibujar_nombres:
    ; Dibujar los nombres en la posición (posX, posY)
    pusha
    mov si, nombres     ; Apuntar al inicio de los nombres
    mov ax, [posX]
    mov bx, ax         ; bx = posX
    mov dx, [posY]     ; dx = posY

dibujar_letra:
    lodsb              ; Cargar siguiente carácter en AL
    cmp al, 0
    je fin_dibujo_nombres

    ; Convertir carácter a índice de letra
    ; Supongamos que 'A' es índice 0, 'B' es índice 1, etc.
    ; Convertir de ASCII a índice
    sub al, 'A'
    cbw                ; Extender AL a AX
    shl ax, 1          ; Multiplicar por 2 (cada puntero en 'letras' es de 2 bytes)
    push si            ; Guardar SI
    mov si, letras
    add si, ax         ; Apuntar al puntero de la letra correspondiente
    mov di, [si]       ; Cargar puntero a la matriz de bits de la letra
    pop si             ; Restaurar SI

    ; Copiar la matriz de la letra a 'matriz_letra'
    push si
    push di
    mov si, di         ; SI apunta a la matriz de la letra
    lea di, [matriz_letra]
    mov cx, 8
    rep movsb          ; Copiar 8 bytes
    pop di
    pop si

    ; Dibujar la letra en (bx, dx)
    push bx
    push dx
    call dibujar_letra_en_posicion
    pop dx
    pop bx

    ; Avanzar posición X para la siguiente letra
    add bx, 8          ; Asumiendo que cada letra tiene ancho de 8 píxeles
    jmp dibujar_letra

fin_dibujo_nombres:
    popa
    ret

dibujar_letra_en_posicion:
    ; Dibujar la letra almacenada en 'matriz_letra' en la posición (BX, DX)
    ; BX = posX, DX = posY
    pusha
    mov ax, 0A000h
    mov es, ax         ; ES apunta a la memoria de video

    mov si, matriz_letra  ; SI apunta a la matriz de la letra
    mov cx, 8            ; Altura de la letra (8 filas)
    mov bp, dx           ; Guardar posY inicial

draw_row:
    push cx
    mov cx, 8           ; 8 bits por fila
    mov al, [si]        ; Cargar byte de la fila
    mov ah, al          ; AH = AL

    mov di, bx          ; DI = posX
    mov dx, bp          ; DX = posY actual

draw_pixel:
    shl al, 1           ; Desplazar a la izquierda para obtener el bit más significativo
    jc pixel_on         ; Si el bit es 1, dibujar píxel
    jmp skip_pixel

pixel_on:
    ; Calcular dirección de memoria de video
    mov ax, dx
    mov bx, 320
    mul bx              ; AX = posY * 320
    add ax, di          ; AX = (posY * 320) + posX
    mov di, ax
    ; Dibujar píxel
    mov byte [es:di], 15   ; Color blanco

skip_pixel:
    inc di              ; Avanzar a la siguiente columna
    loop draw_pixel

    inc dx              ; Siguiente fila
    inc si              ; Siguiente byte de la matriz de bits
    pop cx
    loop draw_row

    popa
    ret

; Implementación de las rutinas de rotación

; Rotación de 90 grados a la izquierda
rotar_letras_90_izquierda:
    pusha
    ; Rotar la matriz de cada letra 90 grados a la izquierda
    lea si, [matriz_letra]
    lea di, [temp_matriz]
    call rotar_matriz_90_izquierda
    ; Copiar matriz rotada de temp_matriz a matriz_letra
    lea si, [temp_matriz]
    lea di, [matriz_letra]
    mov cx, 8
    rep movsb
    popa
    ret

; Rotación de 90 grados a la derecha
rotar_letras_90_derecha:
    pusha
    ; Rotar la matriz de cada letra 90 grados a la derecha
    lea si, [matriz_letra]
    lea di, [temp_matriz]
    call rotar_matriz_90_derecha
    ; Copiar matriz rotada de temp_matriz a matriz_letra
    lea si, [temp_matriz]
    lea di, [matriz_letra]
    mov cx, 8
    rep movsb
    popa
    ret

; Rotación de 180 grados
rotar_letras_180:
    pusha
    ; Rotar la matriz de cada letra 180 grados
    lea si, [matriz_letra]
    lea di, [temp_matriz]
    call rotar_matriz_180
    ; Copiar matriz rotada de temp_matriz a matriz_letra
    lea si, [temp_matriz]
    lea di, [matriz_letra]
    mov cx, 8
    rep movsb
    popa
    ret

; Rutinas de rotación de matrices

; Rotación de matriz de 8x8 bits 90 grados a la izquierda
rotar_matriz_90_izquierda:
    ; SI apunta a la matriz original
    ; DI apunta a la matriz destino
    pusha
    mov cx, 8          ; Contador de bits (columnas)
    mov bx, 0          ; Índice de destino
rotl_col_loop:
    mov al, 0
    mov bp, 8          ; Contador de filas
    mov si, matriz_letra
    add si, 7          ; Apuntar a la última fila
    add si, bx         ; Ajustar columna
rotl_row_loop:
    mov dl, [si]       ; Obtener byte de la fila
    shr dl, cl
    and dl, 1
    shl al, 1
    or al, dl
    sub si, 8          ; Mover a la fila anterior
    dec bp
    cmp bp, 0
    jne rotl_row_loop
    mov [di], al
    inc di
    inc bx
    dec cx
    cmp cx, 0
    jne rotl_col_loop
    popa
    ret

; Rotación de matriz de 8x8 bits 90 grados a la derecha
rotar_matriz_90_derecha:
    ; SI apunta a la matriz original
    ; DI apunta a la matriz destino
    pusha
    mov cx, 8          ; Contador de bits (columnas)
    mov bx, 0          ; Índice de destino
rotr_col_loop:
    mov al, 0
    mov bp, 8          ; Contador de filas
    mov si, matriz_letra
    add si, bx         ; Apuntar a la primera fila, columna actual
rotr_row_loop:
    mov dl, [si]       ; Obtener byte de la fila
    shr dl, cl
    and dl, 1
    shl al, 1
    or al, dl
    add si, 8          ; Mover a la siguiente fila
    dec bp
    cmp bp, 0
    jne rotr_row_loop
    mov [di], al
    inc di
    inc bx
    dec cx
    cmp cx, 0
    jne rotr_col_loop
    popa
    ret

; Rotación de matriz de 8x8 bits 180 grados
rotar_matriz_180:
    ; SI apunta a la matriz original
    ; DI apunta a la matriz destino
    pusha
    mov cx, 8
    mov si, matriz_letra
    add si, 7          ; Apuntar a la última fila
rot180_loop:
    mov al, [si]
    ; Invertir los bits de la fila
    mov ah, al
    mov al, 0
    mov cl, 8
rot180_bit_invert:
    rcr ah, 1
    rcl al, 1
    loop rot180_bit_invert
    mov [di], al
    inc di
    dec si
    cmp si, matriz_letra - 1
    jne rot180_loop
    popa
    ret

;------------------------------------------------
; Fin del programa
;---