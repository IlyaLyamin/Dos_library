.286
.model small
.stack 0FFFFh

EXTRN matrixInit:near, newMatrix:near, freeMatrix:near, checkID:near

.data

.code

main PROC
    mov ax, @data
    mov ds, ax
    ;---------matrix init 
    mov ax, 400h ;stack size
    mov bx, 19h ;max elements
    call matrixInit
    ;---------matrix create 
    mov ax, 3 ;rows
    mov bx, 4 ;Cols
    call newMatrix ;matrix id in dx
test_1:
    ;---------TEST 1: delete an existing matrix
    call freeMatrix
    call checkID
    cmp al, 9
    jne error_1
    jmp test_2

test_2:
    ;---------TEST 2: delete an inexisting matrix
    xor ax, ax
    mov dx, 0h
    call freeMatrix
    cmp al, 09h
    jne error_2
    mov AL, 0
    je end_test

error_1:
    mov AL, 1
    jmp end_test

error_2:
    mov AL, 2
    jmp end_test

end_test:
    mov AH, 4Ch
    int 21h

main ENDP
END main