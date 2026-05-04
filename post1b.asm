; ============================================================
; post1b.asm - INT 10h: posicionamiento de cursor y color
; Autor   : Torres
; Materia : Arquitectura de Computadores - Unidad 7
; Compilar: nasm -f bin post1b.asm -o post1b.com
; Ejecutar: post1b.com  (dentro de DOSBox)
;
; Descripcion:
;   Usa INT 10h para:
;     - Limpiar la pantalla (AH=06h, scroll hacia arriba)
;     - Posicionar el cursor en filas/columnas exactas (AH=02h)
;     - Escribir caracteres con atributo de color (AH=09h)
;   Byte de atributo: bits[7:4]=fondo  bits[3:0]=texto
;     Ejemplo: 1Eh = 0001 1110b = fondo azul (1h), texto amarillo (Eh)
;              0Ch = 0000 1100b = fondo negro (0h), texto rojo claro (Ch)
; ============================================================

ORG 100h            ; Offset de inicio para archivos .COM

; ── Seccion de codigo ────────────────────────────────────────
section .text
start:

    ; ── Limpiar pantalla ─────────────────────────────────────
    ; INT 10h / AH=06h: scroll region hacia arriba
    ;   AL=0  → limpiar toda la ventana (no scroll parcial)
    ;   CH:CL → esquina superior izquierda (fila 0, col 0)
    ;   DH:DL → esquina inferior derecha   (fila 24=18h, col 79=4Fh)
    ;   BH    → atributo de relleno (07h = blanco sobre negro)
    mov ah, 06h         ; funcion 06h: scroll hacia arriba
    xor al, al          ; AL=0: limpiar ventana completa
    xor cx, cx          ; CH=0 fila, CL=0 columna (esquina sup-izq)
    mov dx, 184Fh       ; DH=18h=24 fila, DL=4Fh=79 columna (esq inf-der)
    mov bh, 07h         ; atributo relleno: texto blanco sobre fondo negro
    int 10h             ; llamada BIOS video

    ; ── Posicionar cursor: fila 2, columna 10 ────────────────
    ; INT 10h / AH=02h: set cursor position
    ;   BH=pagina de video (0), DH=fila, DL=columna
    mov ah, 02h         ; funcion 02h: posicionar cursor
    xor bh, bh          ; BH=0 pagina de video 0
    mov dh, 02h         ; DH=2 fila 2
    mov dl, 0Ah         ; DL=10 columna 10
    int 10h             ; posicionar cursor

    ; ── Escribir "A": texto amarillo (Eh) sobre fondo azul (1h) ──
    ; Atributo 1Eh = 0001 1110b
    ;   bits[7:4]=0001 → fondo azul
    ;   bits[3:0]=1110 → texto amarillo
    ; INT 10h / AH=09h: write character and attribute at cursor
    ;   AL=caracter ASCII, BH=pagina, BL=atributo, CX=repeticiones
    mov ah, 09h         ; funcion 09h: escribir caracter con atributo
    mov al, 'A'         ; caracter a escribir
    xor bh, bh          ; BH=0 pagina 0
    mov bl, 1Eh         ; BL=1Eh: fondo azul, texto amarillo
    mov cx, 1           ; CX=1 repeticion
    int 10h             ; escribir caracter

    ; ── Posicionar cursor: fila 3, columna 10 ────────────────
    mov ah, 02h         ; funcion 02h: posicionar cursor
    xor bh, bh          ; pagina 0
    mov dh, 03h         ; fila 3
    mov dl, 0Ah         ; columna 10
    int 10h             ; posicionar cursor

    ; ── Escribir "U": texto rojo claro (Ch) sobre negro (0) ──
    ; Atributo 0Ch = 0000 1100b
    ;   bits[7:4]=0000 → fondo negro
    ;   bits[3:0]=1100 → texto rojo claro
    mov ah, 09h         ; funcion 09h: escribir caracter con atributo
    mov al, 'U'         ; primer caracter de "U7"
    xor bh, bh          ; pagina 0
    mov bl, 0Ch         ; BL=0Ch: fondo negro, texto rojo claro
    mov cx, 1           ; 1 repeticion
    int 10h             ; escribir "U"

    ; ── Avanzar cursor a columna 11 para escribir "7" ────────
    mov ah, 02h         ; funcion 02h: posicionar cursor
    xor bh, bh          ; pagina 0
    mov dh, 03h         ; fila 3 (misma fila)
    mov dl, 0Bh         ; columna 11 (siguiente columna)
    int 10h             ; mover cursor

    ; ── Escribir "7": mismo atributo rojo claro ──────────────
    mov ah, 09h         ; funcion 09h: escribir caracter con atributo
    mov al, '7'         ; segundo caracter de "U7"
    xor bh, bh          ; pagina 0
    mov bl, 0Ch         ; BL=0Ch: fondo negro, texto rojo claro
    mov cx, 1           ; 1 repeticion
    int 10h             ; escribir "7"

    ; ── Esperar pulsacion de tecla antes de salir ────────────
    ; INT 21h / AH=07h: leer caracter sin eco (no muestra el caracter)
    mov ah, 07h         ; funcion 07h: leer caracter sin eco
    int 21h             ; esperar tecla (retorna ASCII en AL)

    ; ── Salir al sistema operativo ───────────────────────────
    mov ah, 4Ch         ; funcion 4Ch: exit
    xor al, al          ; AL=0: sin error
    int 21h             ; retornar a DOS
