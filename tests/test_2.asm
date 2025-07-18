;I just link them together, check using afdpro
.286
.model small
.stack 0FFFFh

EXTRN matrixInit:near, newMatrix: near

.data 

.code 

main proc
    mov ax, @data
    mov ds, ax

test1: ; ordinary case
    mov ax, 400h ; user_stack_size 
    mov bx, 19h ; max_elements
    call matrixInit 
;------TEST 1: valid matrix creation-------------------------------------
    mov ax, 02h
    mov bx, 03h
    call newMatrix ; we can check descriptor using afdpro
    jc error_1 ; CF = 1, somehow

    cmp al, 0 ; AL = 0, no errors
    jne error_1

    cmp dx, 0 ; it's the first matrix, so ID should be 0
    jne error_1

    xor dx, dx ; will be needed for the second test
    jmp test2   

;------TEST 2: invalid dimentions, zero rows-------------------------------------

test2:
    xor ax, ax ; ax = 0
    mov bx, 03h
    call newMatrix ; we can check descriptor using afdpro

    cmp al, 3 ; AL = 3, no errors
    jne error_2

    cmp dx, 0 ; dx = 0, no ID
    jne error_2
    jmp test3

;------TEST 3: matrix exceeds maximum supported dimensions-------------------------------------
test3:
    mov ax, 19h ; ax = 25
    mov bx, 02h ; bx = 2 => ax*bx > 25
    call newMatrix ; we can check descriptor using afdpro

    cmp al, 3 ; AL = 3, no errors
    jne error_3

    cmp dx, 0 ; dx = 0, no ID
    jne error_3
    mov AL, 0
    jmp end_tests

error_1:
    mov AL,1
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