; ============================================================
; post1.asm - INT 21h: salida de texto basica
; Autor   : Torres
; Materia : Arquitectura de Computadores - Unidad 7
; Compilar: nasm -f bin post1.asm -o post1.com
; Ejecutar: post1.com  (dentro de DOSBox)
;
; Descripcion:
;   Usa la interrupcion INT 21h / AH=09h para imprimir tres
;   cadenas de texto en pantalla, terminadas con el caracter "$".
;   Finaliza con INT 21h / AH=4Ch (exit limpio al sistema DOS).
; ============================================================

ORG 100h            ; Offset de inicio para archivos .COM

; ── Seccion de datos ─────────────────────────────────────────
section .data
    ; Cadenas terminadas en "$" requeridas por INT 21h / AH=09h
    ; 0Dh = Carriage Return (CR), 0Ah = Line Feed (LF)
    msg1 db "Arquitectura de Computadores", 0Dh, 0Ah, "$"
    msg2 db "Unidad 7: Pantalla y Teclado", 0Dh, 0Ah, "$"
    msg3 db "Laboratorio POST-1", 0Dh, 0Ah, "$"

; ── Seccion de codigo ────────────────────────────────────────
section .text
start:
    ; --- Imprimir msg1 ---
    ; AH=09h: imprime cadena apuntada por DS:DX hasta encontrar "$"
    mov ah, 09h         ; funcion 09h de INT 21h: imprimir cadena
    mov dx, msg1        ; DS:DX → direccion de msg1
    int 21h             ; llamada al sistema DOS

    ; --- Imprimir msg2 ---
    ; AH sigue siendo 09h, solo cambia DX
    mov dx, msg2        ; DS:DX → direccion de msg2
    int 21h             ; llamada al sistema DOS

    ; --- Imprimir msg3 ---
    mov dx, msg3        ; DS:DX → direccion de msg3
    int 21h             ; llamada al sistema DOS

    ; --- Salir al sistema operativo ---
    ; AH=4Ch: terminar proceso, AL=codigo de retorno (0=OK)
    mov ah, 4Ch         ; funcion 4Ch: exit
    xor al, al          ; AL = 0 (sin error)
    int 21h             ; retornar a DOS
