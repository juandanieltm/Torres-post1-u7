; ============================================================
; post1c.asm - Cadena en posicion exacta con color
; Autor   : Torres
; Materia : Arquitectura de Computadores - Unidad 7
; Compilar: nasm -f bin post1c.asm -o post1c.com
; Ejecutar: post1c.com  (dentro de DOSBox)
;
; Descripcion:
;   Recorre la cadena "titulo" caracter a caracter usando SI como
;   puntero. Por cada caracter:
;     1. Posiciona el cursor (INT 10h / AH=02h) en la columna actual
;     2. Escribe el caracter con atributo verde brillante (0Ah)
;        usando INT 10h / AH=09h
;     3. Incrementa SI (siguiente caracter) y DL (siguiente columna)
;   Termina cuando encuentra el caracter "$" (fin de cadena).
;   Atributo 0Ah = 0000 1010b: fondo negro (0), texto verde brillante (Ah)
; ============================================================

ORG 100h            ; Offset de inicio para archivos .COM

; ── Seccion de datos ─────────────────────────────────────────
section .data
    titulo  db "UNIDAD 7 - PANTALLA Y TECLADO", "$"
    filaT   equ 5       ; constante: fila donde aparece el titulo
    colT    equ 25      ; constante: columna inicial del titulo

; ── Seccion de codigo ────────────────────────────────────────
section .text
start:

    ; ── Limpiar pantalla ─────────────────────────────────────
    ; INT 10h / AH=06h: scroll hacia arriba para limpiar
    mov ah, 06h         ; funcion 06h: scroll hacia arriba
    xor al, al          ; AL=0: limpiar toda la ventana
    xor cx, cx          ; esquina superior izquierda: fila 0, col 0
    mov dx, 184Fh       ; esquina inferior derecha: fila 24, col 79
    mov bh, 07h         ; atributo relleno: blanco sobre negro
    int 10h             ; limpiar pantalla

    ; ── Preparar puntero e indices iniciales ─────────────────
    mov si, titulo      ; SI = offset del primer caracter de titulo
    mov dl, colT        ; DL = columna inicial (25)
    mov dh, filaT       ; DH = fila fija (5)

; ── Bucle: escribir caracter a caracter ──────────────────────
.bucle:
    mov al, [si]        ; AL = caracter apuntado por SI
    cmp al, '$'         ; comparar con fin de cadena
    je  .fin            ; si es "$", terminar bucle

    ; -- Posicionar cursor en (dh=fila, dl=columna) actual --
    ; INT 10h / AH=02h: set cursor position
    mov ah, 02h         ; funcion 02h: posicionar cursor
    xor bh, bh          ; BH=0 pagina de video 0
    int 10h             ; cursor → fila dh, columna dl

    ; -- Escribir caracter con atributo verde brillante (0Ah) --
    ; INT 10h / AH=09h: write character and attribute at cursor
    ;   AL = caracter (ya cargado arriba)
    ;   BH = pagina, BL = atributo, CX = repeticiones
    mov ah, 09h         ; funcion 09h: escribir caracter con atributo
    xor bh, bh          ; BH=0 pagina 0
    mov bl, 0Ah         ; BL=0Ah: fondo negro, texto verde brillante
    mov cx, 1           ; CX=1 repeticion
    int 10h             ; escribir caracter con color

    inc si              ; SI++ → avanzar al siguiente caracter
    inc dl              ; DL++ → avanzar a la siguiente columna
    jmp .bucle          ; repetir hasta encontrar "$"

; ── Fin del bucle ────────────────────────────────────────────
.fin:
    ; ── Esperar tecla antes de salir ─────────────────────────
    ; INT 21h / AH=07h: leer caracter sin eco
    mov ah, 07h         ; funcion 07h: esperar pulsacion de tecla
    int 21h             ; pausa hasta que el usuario presione una tecla

    ; ── Salir al sistema operativo ───────────────────────────
    mov ah, 4Ch         ; funcion 4Ch: exit
    xor al, al          ; AL=0: sin error
    int 21h             ; retornar a DOS
