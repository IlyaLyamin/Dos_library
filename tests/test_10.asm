;I just link them together, check using afdpro
.286
.287
.model small
.stack 0FFFFh

EXTRN matrixInit:near, newMatrix: near, setElement:near,getElement:near, dotMatrix:near

.data 
    matrix_ind_1    dw ?
    matrix_ind_2    dw ?
    scalar          dd 2.0  ; 00 00 00 40
.code 

main proc
    mov AX, @data
    mov DS, AX

    mov AX, 400h ; user_stack_size 
    mov BX, 06h ; max_elements
    call matrixInit 

    mov AX, 02h ; rows
    mov BX, 03h ; columns
    call newMatrix

    mov [matrix_ind_1], DX

    mov DX, [matrix_ind_1]
    mov BX, 00h ; row
    mov SI, 00h ; column
    mov CX, 04040h 
    mov DI, 000h
    call setElement

    mov BX, 00h ; row
    mov SI, 01h ; column
    mov CX, 07f80h
    mov DI, 000h
    call setElement

    mov BX, 00h ; row
    mov SI, 02h ; column
    mov CX, 0ff80h 
    mov DI, 000h
    call setElement

    mov BX, 01h ; row
    mov SI, 00h ; column
    mov CX, 0h 
    mov DI, 000h
    call setElement

    mov BX, 01h ; row
    mov SI, 01h ; column
    mov CX, 0bf80h 
    mov DI, 000h
    call setElement

    mov BX, 01h ; row
    mov SI, 02h ; column
    mov CX, 0454ah 
    mov DI, 0d000h
    call setElement

;   [3, +inf, -inf] 
;   [0, -1, 3245]

    mov dx, [matrix_ind_1]
    ; mov cx, word ptr [scalar + 2]
    ; mov di, word ptr [scalar]

    mov cx, 04000h
    mov di, 0h

    call dotMatrix
    ;(0, 0)
    mov bx, 00h
    mov si, 0h
    call getElement

    cmp cx, 040c0h
    jne error_1
    cmp di, 0h
    jne error_1

    ;(0, 1)
    mov bx, 00h
    mov si, 01h
    call getElement

    cmp cx, 07f80h
    jne error_1
    cmp di, 0h
    jne error_1

    ;(0, 2)
    mov bx, 00h
    mov si, 02h
    call getElement

    cmp cx, 0ff80h
    jne error_1
    cmp di, 0h
    jne error_1

    ;(1, 0)
    mov bx, 01h
    mov si, 0h
    call getElement

    cmp cx, 0h
    jne error_1
    cmp di, 0h
    jne error_1

    ;(1, 1)
    mov bx, 01h
    mov si, 01h
    call getElement

    cmp cx, 0c000h
    jne error_1
    cmp di, 0h
    jne error_1

    ;(1, 2)
    mov bx, 01h
    mov si, 02h
    call getElement

    cmp cx, 045cah
    jne error_1
    cmp di, 0d000h
    jne error_1
    mov AL, 0
    jmp end_tests

error_1:
    mov AL, 1
    jmp end_tests

end_tests: 
    mov AH, 4Ch
    int 21h

main endp
end main