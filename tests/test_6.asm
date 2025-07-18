;I just link them together, check using afdpro
.286
.model small
.stack 0FFFFh

EXTRN matrixInit:near, newMatrix: near, getDim:near

.data 
second_matrix_ID dw ?
.code 

main proc
    mov ax, @data
    mov ds, ax

    mov ax, 400h ; user_stack_size 
    mov bx, 19h ; max_elements
    call matrixInit 

;------ valid matrix creation (1) -------------------------------------

    mov ax, 02h
    mov bx, 03h
    call newMatrix ; we can check descriptor using afdpro
    jc error ; CF = 1, somehow

    cmp al, 0 ; AL = 0, no errors
    jne error

    cmp dx, 0 ; it's the first matrix, so ID should be 0
    jne error

    xor dx, dx ; will be needed for the second test

;------ valid matrix creation (2) -------------------------------------

    mov ax, 03h
    mov bx, 03h
    call newMatrix ; we can check descriptor using afdpro
    jc error ; CF = 1, somehow

    cmp al, 0 ; AL = 0, no errors
    jne error

    cmp dx, 1 ; it's the second matrix, so ID should 1
    jne error

    mov [second_matrix_ID], dx

    xor dx, dx ; will be needed for the second test

;------ TEST 1: valid dimentions -------------------------------------

    xor bx, bx
    xor si, si

    mov DX, 1h
    call getDim

    cmp BX, 03h
    jne error_1

    cmp SI, 03h
    jne error_1

    ;------ TEST 2: invalid ID -------------------------------------

    xor bx, bx
    xor si, si

    mov DX, 5h
    call getDim

    cmp al, 09h
    jne error_2
    mov AL, 0
    jmp end_prog
error:
    jmp end_prog

error_1:
    mov AL, 1
    jmp end_prog

error_2:
    mov AL, 2
    jmp end_prog

end_prog:
    mov AH, 4Ch
    int 21h

main endp
end main