.286
.287
.model small
.stack 0FFFFh

EXTRN matrixInit:near, newMatrix: near, setElement:near,getElement:near, writeElem:near

.data 
    str1            db "3.14$", 0
    matrix_ind_1    dw ?

.code

main proc

    mov AX, @data
    mov DS, AX
    mov ES, AX
    xor CX, CX
    xor DI, DI

    mov AX, 400h ; user_stack_size 
    mov BX, 10h ; max_elements
    call matrixInit 

    mov AX, 02h ; rows
    mov BX, 02h ; columns
    call newMatrix
    mov [matrix_ind_1], DX 

; Test 1: Valid Input
    mov SI, offset str1
    mov ax, 0
    mov bx, 0
    mov dx, [matrix_ind_1]
    call writeElem

    cmp al, 0
    jne error_1

    mov bx, 0
    mov si, 0
    mov dx, [matrix_ind_1]
    call getElement

    cmp CX, 4048h
    jne error_1
    cmp DI, 0F5C2h
    jne error_1    

    mov AL, 0
    jmp end_tests


error_1:                ;invalid input
    mov AL, 1
    jmp end_tests

end_tests: 
    mov AH, 4Ch
    int 21h

main endp
end main