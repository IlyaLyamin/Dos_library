;I just link them together, check using afdpro
.286
.model small
.stack 0FFFFh

EXTRN matrixInit:near, newMatrix: near, checkID: near, setElement:near,  getElement:near

.data 
    matrix_ind dw ?
.code 

main proc
    mov ax, @data
    mov ds, ax

    mov ax, 400h ; user_stack_size 
    mov bx, 19h ; max_elements
    call matrixInit 

    mov ax, 02h ; rows
    mov bx, 02h ; columns
    call newMatrix

    mov [matrix_ind], dx

;------Test 1: Valid Element Update-------------------------------------
    
    mov bx, 01h ; row
    mov si, 01h ; column
    mov cx, 4048h
    mov di, 0F5C3h
    call setElement
    xor cx,cx 
    xor di,di ; so reading will be seen
    mov bx, 01h ; row
    mov si, 01h ; column
    call getElement
    cmp al, 0 ; elemnt can be viewed using afdpro 
    jne error_1

    jmp test2

;------Test 2: Index Out of Bounds (row)-------------------------------------
test2:
    mov dx, [matrix_ind]
    mov bx, 03h ; row
    mov si, 01h ; column
    call getElement
    cmp al, 4
    jne error_2

    jmp test3

;------Test 3: Index out of Bounds (column)-------------------------------------
test3:
    xor ax, ax
    mov dx, [matrix_ind]
    mov bx, 01h ; row
    mov si, 03h ; column
    call getElement

    cmp al, 4
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