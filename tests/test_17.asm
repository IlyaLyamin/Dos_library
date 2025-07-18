.286
.287
.model small
.stack 0FFFFh

EXTRN buffer_output:BYTE, \
matrixInit:near, newMatrix:near, \
setElement:near, readElem:near

.data 
    matrix_id   dw ?
    expected_1  db "+3.140000e+00$"
.code 

main proc
    mov AX, @data
    mov DS, AX
    mov ES, AX

    mov AX, 400h ; user_stack_size 
    mov BX, 06h ; max_elements
    call matrixInit 

    mov AX, 02h ; rows
    mov BX, 03h ; columns
    call newMatrix
;--------Test 1: Valid Number -----------------

    mov [matrix_id], dx

    mov bx, 0
    mov si, 0
    mov cx, 4048h
    mov di, 0f5c3h
    call setElement

    mov ax, 0
    mov bx, 0
    mov dx, [matrix_id]
    call readElem

    cmp al, 0
    jne error_1

    mov di, offset expected_1
    call compareStrings
    jc error_1

    xor al, al
    jmp end_tests
   

error_1:
    mov al, 1
    jmp end_tests

end_tests: 
    mov ah, 4Ch
    int 21h


compareStrings proc
    push si
    push di
    push ax
compareLoop:
    mov al, [si]
    cmp al, [di]
    jne compareFail
    cmp al, '$'
    je compareEqual
    inc si
    inc di
    jmp compareLoop
compareFail:
    stc
    jmp compareEnd
compareEqual:
    clc
compareEnd:
    pop ax
    pop di
    pop si
    ret
compareStrings endp



main endp
end main