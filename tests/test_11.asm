.286
.287
.model small
.stack 0FFFFh

EXTRN matrixInit:near, newMatrix: near, setElement:near,getElement:near, degMatrix:near

.data 
    matrix1_id  dw ?
    matrix2_id  dw ?

    matrix3_id  dw ?

    matrix4_id  dw ?
    matrix5_id  dw ?
.code 

main proc
    mov AX, @data
    mov DS, AX

    mov AX, 400h ; user_stack_size 
    mov BX, 64h ; max_elements
    call matrixInit 


;------Test 1: Valid Matrix Power
    mov AX, 02h ; rows
    mov BX, 02h ; columns
    call newMatrix
    mov [matrix1_id], DX

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
    mov CX, 4080h ; 4
    mov DI, 0000h
    call setElement

    mov ax, [matrix1_id]
    mov bx, 02h
    call degMatrix
    
    cmp al, 0
    jne error_1

    mov [matrix2_id], dx
    mov bx, 0
    mov si, 0
    call getElement
    cmp cx, 40e0h ; 7
    jne error_1
    cmp di, 0000h
    jne error_1

    mov bx, 0
    mov si, 1
    call getElement
    cmp cx, 4120h ; 10
    jne error_1
    cmp di, 0000h
    jne error_1

    mov bx, 1
    mov si, 0
    call getElement
    cmp cx, 4170h ; 15
    jne error_1
    cmp di, 0000h
    jne error_1

    mov bx, 1
    mov si, 1
    call getElement
    cmp cx, 41b0h ; 22
    jne error_1
    cmp di, 0000h
    jne error_1

;------Test 2: Non-Square Matrix
    mov AX, 02h ; rows
    mov BX, 03h ; columns
    call newMatrix
    mov [matrix3_id], DX

    mov ax, dx
    call degMatrix

    cmp al, 7
    jne error_2
    
;------Test 3: Zero Exponent
    mov AX, 02h ; rows
    mov BX, 02h ; columns
    call newMatrix
    mov [matrix4_id], DX

    mov ax, [matrix4_id]
    mov bx, 0
    call degMatrix

    cmp al, 0
    jne error_3

    mov [matrix5_id], dx
    mov bx, 0
    mov si, 0
    call getElement
    cmp cx, 3f80h ; 1
    jne error_3
    cmp di, 0000h
    jne error_3

    mov bx, 0
    mov si, 1
    call getElement
    cmp cx, 0000h ; 0
    jne error_3
    cmp di, 0000h
    jne error_3

    mov bx, 1
    mov si, 0
    call getElement
    cmp cx, 0000h ; 0
    jne error_3
    cmp di, 0000h
    jne error_3

    mov bx, 1
    mov si, 1
    call getElement
    cmp cx, 3f80h ; 1
    jne error_3
    cmp di, 0000h
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
