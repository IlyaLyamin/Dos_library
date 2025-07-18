.286
.287
.model small
.stack 0FFFFh

EXTRN matrixInit:near, newMatrix:near, setElement:near, getElement:near, detMatrix:near

.data
    matrix_1x1_id   dw  ?
    matrix_4x4_id   dw  ?

.code
main PROC
    mov ax, @data
    mov ds, ax
    mov ax, 400h
    mov bx, 30h
    call matrixInit

;------Test 1: Valid Determinant (1x1)-------------------------------------
    mov ax, 01h
    mov bx, 01h
    call newMatrix
    mov [matrix_1x1_id], dx

    mov bx, 0
    mov si, 0
    mov cx, 4000h               ; 2.0 (0x40000000)
    mov di, 0000h
    call setElement

    mov dx, [matrix_1x1_id]
    call detMatrix
    cmp al, 0
    jne error_1
    ; Expected: CX=0x4000, DI=0x0000 (2.0), verify in AFDPro
    jmp test2

;------Test 2: Valid Determinant (4x4)-------------------------------------
test2:
    mov ax, 04h
    mov bx, 04h
    call newMatrix
    mov [matrix_4x4_id], dx
    ; [5.0, 6.0, 7.0, 8.0]
    ; [9.0, 2.0, 3.0, 1.0]
    ; [8.0, 3.0, 6.0, 8.0]
    ; [3.0, 3.0, 2.0, 0.0]
    mov dx, [matrix_4x4_id]
    mov bx, 0
    mov si, 0
    mov cx, 40A0h               ; 5.0 (0x40A00000)
    mov di, 0000h
    call setElement
    mov si, 1
    mov cx, 40C0h               ; 6.0 (0x40C00000)
    mov di, 0000h
    call setElement
    mov si, 2
    mov cx, 40E0h               ; 7.0 (0x40E00000)
    mov di, 0000h
    call setElement
    mov si, 3
    mov cx, 4100h               ; 8.0 (0x41000000)
    mov di, 0000h
    call setElement
    mov bx, 1
    mov si, 0
    mov cx, 4110h               ; 9.0 (0x41100000)
    mov di, 0000h
    call setElement
    mov si, 1
    mov cx, 4000h               ; 2.0 (0x40000000)
    mov di, 0000h
    call setElement
    mov si, 2
    mov cx, 4040h               ; 3.0 (0x40400000)
    mov di, 0000h
    call setElement
    mov si, 3
    mov cx, 3F80h               ; 1.0 (0x3F800000)
    mov di, 0000h
    call setElement
    mov bx, 2
    mov si, 0
    mov cx, 4100h               ; 8.0 (0x41000000)
    mov di, 0000h
    call setElement
    mov si, 1
    mov cx, 4040h               ; 3.0 (0x40400000)
    mov di, 0000h
    call setElement
    mov si, 2
    mov cx, 40C0h               ; 6.0 (0x40C00000)
    mov di, 0000h
    call setElement
    mov si, 3
    mov cx, 4100h               ; 8.0 (0x41000000)
    mov di, 0000h
    call setElement
    mov bx, 3
    mov si, 0
    mov cx, 4040h               ; 3.0 (0x40400000)
    mov di, 0000h
    call setElement
    mov si, 1
    mov cx, 4040h               ; 3.0 (0x40400000)
    mov di, 0000h
    call setElement
    mov si, 2
    mov cx, 4000h               ; 2.0 (0x40000000)
    mov di, 0000h
    call setElement
    mov si, 3
    mov cx, 0000h               ; 0.0 (0x00000000)
    mov di, 0000h
    call setElement
    mov dx, [matrix_4x4_id]
    call detMatrix
    cmp al, 0
    jne error_2
    ; Expected: CX=0xC170, DI=0x0000 (-15.0)(there may be a slight error)
    jmp test3

;------Test 3: Non-Square Matrix (2x3)-------------------------------------
test3:
    mov ax, 02h
    mov bx, 03h
    call newMatrix
    call detMatrix
    cmp al, 7
    jne error_3
    mov AL, 0
    jmp end_tests

error_1:
    mov AL, 1
    jmp end_tests

error_2:
    mov AL, 2
    jmp end_tests

error_3:
    mov AL, 3
    jmp end_tests

end_tests:
    mov AH, 4Ch
    int 21h

main ENDP
END main