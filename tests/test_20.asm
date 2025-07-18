;I just link them together, check using afdpro
.286
.model small
.stack 0FFFFh

EXTRN max_matr:word, matrixInit:near, newMatrix: near, checkID: near

.data 
    matrix_ind dw ?
.code 

main proc
    mov ax, @data
    mov ds, ax

    ; lib init

    mov ax, 400h ; user_stack_size 
    mov bx, 19h ; max_elements
    call matrixInit 

;------Test 1: Valid Matrix ID-------------------------------------
    mov ax, 02h
    mov bx, 03h
    call newMatrix
    mov [matrix_ind], dx
    mov ax, 02h
    mov bx, 03h
    call newMatrix
    mov dx, word ptr [matrix_ind]
    call checkID
    cmp al, 09h;
    je error_1
    xor dx, dx
    xor ax,ax
    jmp test2   

;------Test 2: Invalid Matrix ID(out of range)-------------------------------------

test2:
    mov ax, 02h
    mov bx, 03h
    call newMatrix ; we can check descriptor using afdpro
    mov [matrix_ind], dx
    mov dx, word ptr [max_matr]
    inc dx
    call checkID
    cmp al, 09h
    jne error_2
    xor ax,ax
    jmp test3

;------Test 2: Invalid Matrix ID(mtx not created)-------------------------------------
test3:
    mov dx, word ptr [matrix_ind]
    inc dx
    call checkID
    cmp al, 09h
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

main endp
end main