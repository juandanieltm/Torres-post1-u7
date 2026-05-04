# Lab POST-1 — Manejo de Pantalla y Teclado (INT 21h / INT 10h)

**Arquitectura de Computadores · Unidad 7 · Post-Contenido 1**  
Universidad Francisco de Paula Santander · Ingeniería de Sistemas · 2026  
Autor: **Torres**

---

## Objetivo

Implementar programas en lenguaje ensamblador x86 que utilizan las interrupciones **INT 21h** e **INT 10h** para gestionar la salida de texto en pantalla, controlar la posición del cursor y aplicar atributos de color en modo texto, ejecutando el laboratorio en DOSBox con NASM como ensamblador.

---

## Estructura del Repositorio

```
Torres-post1-u7/
├── post1.asm          ← Paso 1: salida de texto con INT 21h
├── post1.com          ← Binario compilado
├── post1b.asm         ← Paso 2: cursor y color con INT 10h
├── post1b.com         ← Binario compilado
├── post1c.asm         ← Paso 3: cadena en posición exacta con color
├── post1c.com         ← Binario compilado
├── README.md          ← Este archivo
└── capturas/
    ├── checkpoint1a_compilacion_post1.png
    ├── checkpoint1b_ejecucion_post1.png
    ├── checkpoint2a_compilacion_post1b.png
    ├── checkpoint2b_ejecucion_post1b.png
    ├── checkpoint3a_compilacion_post1c.png
    └── checkpoint3b_ejecucion_post1c.png
```

---

## Compilación y Ejecución

```dosbox
MOUNT C C:\Users\Torres\Torres-post1-u7
C:
nasm -f bin post1.asm  -o post1.com
nasm -f bin post1b.asm -o post1b.com
nasm -f bin post1c.asm -o post1c.com

post1.com
post1b.com
post1c.com
```

---

## Referencia de Interrupciones Utilizadas

### INT 21h — Servicios DOS

| AH | Función | Parámetros | Descripción |
|----|---------|------------|-------------|
| `09h` | Imprimir cadena | `DS:DX` → cadena terminada en `$` | Imprime hasta encontrar `$` |
| `07h` | Leer carácter sin eco | — | Espera tecla, retorna ASCII en AL |
| `4Ch` | Terminar proceso | `AL` = código retorno | Exit limpio al DOS |

### INT 10h — Servicios BIOS Video

| AH | Función | Registros | Descripción |
|----|---------|-----------|-------------|
| `06h` | Scroll hacia arriba | `AL`=líneas (0=limpiar), `BH`=atributo, `CX`=esq.sup, `DX`=esq.inf | Limpia pantalla |
| `02h` | Posicionar cursor | `BH`=página, `DH`=fila, `DL`=columna | Mueve cursor a posición exacta |
| `09h` | Escribir carácter con atributo | `AL`=carácter, `BH`=página, `BL`=atributo, `CX`=repeticiones | Escribe con color |

### Byte de Atributo (INT 10h / AH=09h)

```
 Bit: 7  6  5  4 | 3  2  1  0
      └──────────┘ └──────────┘
       fondo (4b)   texto (4b)
```

| Valor | Color texto | Valor | Color fondo |
|-------|-------------|-------|-------------|
| `0h`  | Negro       | `0h`  | Negro       |
| `1h`  | Azul        | `1h`  | Azul        |
| `2h`  | Verde       | `2h`  | Verde       |
| `9h`  | Azul claro  | —     | —           |
| `0Ah` | Verde brillante | — | —          |
| `0Ch` | Rojo claro  | —     | —           |
| `0Eh` | Amarillo    | —     | —           |
| `0Fh` | Blanco brillante | — | —         |

**Ejemplos usados en el laboratorio:**

| Atributo | Binario | Fondo | Texto |
|----------|---------|-------|-------|
| `07h` | `0000 0111` | Negro | Blanco gris |
| `1Eh` | `0001 1110` | Azul | Amarillo |
| `0Ch` | `0000 1100` | Negro | Rojo claro |
| `0Ah` | `0000 1010` | Negro | Verde brillante |

---

## Checkpoint 1 — INT 21h: Salida de Texto (`post1.asm`)

### Descripción

El programa imprime tres cadenas usando `INT 21h / AH=09h`. Cada cadena termina con el carácter `$` y contiene `0Dh` (CR) + `0Ah` (LF) para salto de línea. Finaliza con `INT 21h / AH=4Ch`.

### Salida esperada en DOSBox

```
Arquitectura de Computadores
Unidad 7: Pantalla y Teclado
Laboratorio POST-1
```

### Resultado

✅ `post1.com` compila sin errores (107 bytes) y muestra las tres líneas correctamente en DOSBox.

Capturas: `checkpoint1a_compilacion_post1.png`, `checkpoint1b_ejecucion_post1.png`

---

## Checkpoint 2 — INT 10h: Cursor y Color (`post1b.asm`)

### Descripción

El programa usa `INT 10h` para:
1. **Limpiar la pantalla** (`AH=06h`, `AL=0`, `CX=0`, `DX=184Fh`, `BH=07h`)
2. **Posicionar cursor** (`AH=02h`, fila/columna en `DH`/`DL`)
3. **Escribir caracteres con color** (`AH=09h`, atributo en `BL`)

### Resultado visual

| Posición | Carácter | Atributo | Fondo | Texto |
|----------|----------|----------|-------|-------|
| Fila 2, Col 10 | `A` | `1Eh` | Azul | Amarillo |
| Fila 3, Col 10 | `U` | `0Ch` | Negro | Rojo claro |
| Fila 3, Col 11 | `7` | `0Ch` | Negro | Rojo claro |

### Resultado

✅ `post1b.com` compila sin errores (92 bytes). Muestra `A` en amarillo/azul en fila 2 y `U7` en rojo/negro en fila 3. Pantalla limpia antes de imprimir. Cursor visible.

Capturas: `checkpoint2a_compilacion_post1b.png`, `checkpoint2b_ejecucion_post1b.png`

---

## Checkpoint 3 — Cadena en Posición Exacta (`post1c.asm`)

### Descripción

Recorre la cadena `"UNIDAD 7 - PANTALLA Y TECLADO"` carácter a carácter usando `SI` como puntero. Por cada carácter:

1. `MOV al, [SI]` → cargar carácter
2. Comparar con `$` → terminar si es fin de cadena
3. `INT 10h / AH=02h` → posicionar cursor en `(DH=5, DL=columna_actual)`
4. `INT 10h / AH=09h` → escribir con atributo `0Ah` (verde brillante)
5. `INC SI` / `INC DL` → avanzar puntero y columna

### Resultado

| Campo | Valor |
|-------|-------|
| Fila | 5 (constante `filaT`) |
| Columna inicial | 25 (constante `colT`) |
| Longitud | 29 caracteres |
| Atributo | `0Ah` — verde brillante sobre negro |

### Resultado

✅ `post1c.com` compila sin errores (90 bytes). El título aparece en fila 5, columna 25, en verde brillante. El bucle posiciona el cursor antes de escribir cada carácter.

Capturas: `checkpoint3a_compilacion_post1c.png`, `checkpoint3b_ejecucion_post1c.png`

---

## Commits del Repositorio

```
feat: post1.asm — salida de texto con INT 21h / AH=09h
feat: post1b.asm — control de cursor y color con INT 10h
feat: post1c.asm — cadena en posicion exacta con bucle caracter a caracter
docs: README con tabla de interrupciones, atributos y checkpoints
```
