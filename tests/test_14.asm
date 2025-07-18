;I just link them together, check using afdpro
.286
.model small
.stack 0FFFFh

EXTRN matrixInit:near, newMatrix: near, setElement:near, transpMatrix:near, getElement:near, getDim:near

.data 
    matrix_ind_1 dw ?
    matrix_ind_2 dw ?
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
    mov CX, 0000h 
    mov DI, 0001h
    call setElement

    mov BX, 00h ; row
    mov SI, 01h ; column
    mov CX, 0000h 
    mov DI, 0002h
    call setElement

    mov BX, 00h ; row
    mov SI, 02h ; column
    mov CX, 0000h 
    mov DI, 0003h
    call setElement

    mov BX, 01h ; row
    mov SI, 00h ; column
    mov CX, 0000h 
    mov DI, 0004h
    call setElement

    mov BX, 01h ; row
    mov SI, 01h ; column
    mov CX, 0000h 
    mov DI, 0005h
    call setElement

    mov BX, 01h ; row
    mov SI, 02h ; column
    mov CX, 0000h 
    mov DI, 0006h
    call setElement

;   [0000.0001, 0000.0002, 0000.0003] 
;   [0000.0004, 0000.0005, 0000.0006]


    call transpMatrix

;   [0000.0001, 0000.0004]
;   [0000.0002, 0000.0005]
;   [0000.0003, 0000.0006]    

    cmp AL, 0
    jne error_1

    cmp DX, 1
    jne error_1

    mov [matrix_ind_2], DX

    call getDim

    cmp BX, 3 ; rows
    jne error_1

    cmp SI, 2 ; cols
    jne error_1

    xor BX, BX
    xor SI, SI


    ; [0, 0] = 0000.0001
    call getElement

    cmp CX, 0
    jne error_1

    cmp DI, 1
    jne error_1

    ;[0, 1] = 0000.0004
    inc SI

    call getElement

    cmp CX, 0
    jne error_1

    cmp DI, 4
    jne error_1

    ;[1, 0] = 0000.0002
    inc BX
    dec SI

    call getElement

    cmp CX, 0
    jne error_1

    cmp DI, 2
    jne error_1

    ;[1, 1] = 0000.0005
    inc SI

    call getElement

    cmp CX, 0
    jne error_1

    cmp DI, 5
    jne error_1

    ;[2, 0] = 0000.0003
    inc BX
    dec SI

    call getElement

    cmp CX, 0
    jne error_1

    cmp DI, 3
    jne error_1


    ;[2, 1] = 0000.0006
    inc SI

    call getElement

    cmp CX, 0
    jne error_1

    cmp DI, 6
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
