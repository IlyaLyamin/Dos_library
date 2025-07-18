.286
.model small
.stack 0FFFFh

EXTRN matrixInit:near, newMatrix: near, setElement:near, getElement:near, getDim:near, negMatrix:near

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
    mov BX, 02h ; columns
    call newMatrix

    mov [matrix_ind_1], DX

    mov DX, [matrix_ind_1]
    mov BX, 00h ; row
    mov SI, 00h ; column
    mov CX, 3F80h ; 1
    mov DI, 0000h
    call setElement

    mov BX, 00h ; row
    mov SI, 01h ; column
    mov CX, 4000h ; 2
    mov DI, 0000h
    call setElement

    mov BX, 01h ; row
    mov SI, 00h ; column
    mov CX, 4040h ; 3
    mov DI, 0000h
    call setElement

    mov BX, 01h ; row
    mov SI, 01h ; column
    mov CX, 4080h 
    mov DI, 0000h
    call setElement

;   [1, 2] 
;   [3, 4]

    call negMatrix

    cmp AL, 0
    jne error_1

    cmp DX, 1
    jne error_1

    mov [matrix_ind_2], DX

    call getDim

    cmp BX, 2 ; rows
    jne error_1

    cmp SI, 2 ; cols
    jne error_1

    xor BX, BX
    xor SI, SI

    
    call getElement

    cmp CX, 0BF80h
    jne error_1
    cmp DI, 0
    jne error_1

    inc SI

    call getElement

    cmp CX, 0C000h
    jne error_1
    cmp DI, 0
    jne error_1

    inc BX
    dec SI

    call getElement

    cmp CX, 0C040h
    jne error_1
    cmp DI, 0
    jne error_1

    inc SI

    call getElement

    cmp CX, 0C080h
    jne error_1
    cmp DI, 0
    jne error_1
    mov AL, 0
    jmp end_tests
    
error_1:
    mov AL, 1
    jmp end_tests

end_tests: 
    mov AX, 4C00h
    int 21h

main endp
end main