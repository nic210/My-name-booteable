[BITS 16]
org 0x1000

start:
    ; Configurar el modo de video
    mov ax, 0x0003
    int 0x10

game_init:
    ; Limpiar la pantalla y mostrar el mensaje de bienvenida
    call clear_screen
    mov si, welcome_msg
    call print_string

    ; Esperar a que el usuario presione una tecla
    mov ah, 0x00
    int 0x16

    ; Limpiar la pantalla y mostrar el nombre
    call clear_screen
    call reset_name

main_loop:
    call display_name
    mov ah, 0x00
    int 0x16

    cmp al, 'd'
    je rotate_left
    cmp al, 'a'
    je rotate_right
    cmp al, 's'
    je rotate_down
    cmp al, 'w'
    je rotate_up
    cmp al, 'r'
    je game_init
    cmp al, 'q'
    je exit_program

    jmp main_loop

rotate_left:
    call rotate_left_90
    jmp main_loop

rotate_right:
    call rotate_right_90
    jmp main_loop

rotate_down:
    call rotate_down_90
    jmp main_loop

rotate_up:
    call rotate_up_90
    jmp main_loop

exit_program:
    call clear_screen
    mov si, goodbye_msg
    call print_string
    cli
    hlt

display_name:
    call clear_screen
    mov si, rotated_name
    mov cx, 5
.row:
    push cx
    mov cx, 5
.col:
    mov al, [si]
    mov ah, 0x0E
    int 0x10
    inc si
    loop .col
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    pop cx
    loop .row
    ret

clear_screen:
    mov ax, 0x0600
    mov bh, 0x07
    mov cx, 0x0000
    mov dx, 0x184F
    int 0x10
    mov ah, 0x02
    xor bh, bh
    xor dx, dx
    int 0x10
    ret

print_string:
    mov ah, 0x0E
.next_char:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .next_char
.done:
    ret

reset_name:
    mov si, name
    mov di, rotated_name
    mov cx, 5
    rep movsb
    mov cx, 20
    mov al, ' '
    rep stosb
    ret

rotate_left_90:
    ; Implementación simplificada para demostración
    mov si, rotated_name
    mov di, buffer
    mov cx, 5
.col:
    push cx
    mov bx, 20
.row:
    mov al, [si + bx]
    mov [di], al
    inc di
    sub bx, 5
    cmp bx, 0
    jge .row
    inc si
    pop cx
    loop .col
    mov si, buffer
    mov di, rotated_name
    mov cx, 25
    rep movsb
    ret

rotate_right_90:
    ; Implementación simplificada para demostración
    mov si, rotated_name
    add si, 4
    mov di, buffer
    mov cx, 5
.col:
    push cx
    xor bx, bx
.row:
    mov al, [si + bx]
    mov [di], al
    inc di
    add bx, 5
    cmp bx, 20
    jle .row
    dec si
    pop cx
    loop .col
    mov si, buffer
    mov di, rotated_name
    mov cx, 25
    rep movsb
    ret

rotate_down_90:
    ; Implementación simplificada para demostración
    mov si, rotated_name
    add si, 24
    mov di, buffer
    mov cx, 25
.loop:
    mov al, [si]
    mov [di], al
    inc di
    dec si
    loop .loop
    mov si, buffer
    mov di, rotated_name
    mov cx, 25
    rep movsb
    ret

rotate_up_90:
    ; Implementación simplificada para demostración
    mov si, rotated_name
    mov di, buffer
    mov cx, 25
    rep movsb
    ret

name db 'KEVIN'
rotated_name times 25 db ' '
buffer times 25 db 0

welcome_msg db 'Bienvenido al juego de rotacion de letras!', 0x0D, 0x0A
            db 'Usa WASD para rotar, R para reiniciar, Q para salir.', 0x0D, 0x0A
            db 'Presiona cualquier tecla para comenzar...', 0x0D, 0x0A, 0
goodbye_msg db 'Finalizado', 0

; Rellenar hasta 510 bytes
times 540 - ($ - $$) db 0

dw 0xAA55
