;I just link them together, check using afdpro
.286
.model small
.stack 0FFFFh

EXTRN matrixInit:near, newMatrix: near, setElement:near, checkNumMat:near

.data 
    matrix_ind_1 dw ?
    matrix_ind_2 dw ?
.code 

main proc
    mov AX, @data
    mov DS, AX

    mov AX, 400h ; user_stack_size 
    mov BX, 19h ; max_elements
    call matrixInit 

    mov AX, 05h ; rows
    mov BX, 05h ; columns
    call newMatrix

    mov [matrix_ind_1], DX

    mov AX, 05h ; rows
    mov BX, 05h ; columns
    call newMatrix

    mov [matrix_ind_2], DX


;------Test 1: All Elements Are Numeric-------------------------------------
    ; by default all elements are zero
    mov DX, [matrix_ind_1]
    mov BX, 04h ; row
    mov SI, 03h ; column
    mov CX, 0C380h  ; -257.32004 D
    mov DI, 0A8f7h  
    call setElement

    call checkNumMat
    cmp AL, 0  
    jne error_1

    cmp CL, 0
    jne error_1

    jmp test2

;------Test 2: Contains Non-Numeric Element-------------------------------------

test2:
    mov DX, [matrix_ind_2]
    mov BX, 04h ; row
    mov SI, 03h ; column
    mov CX, 07FC0h  ; NaN
    mov DI, 2283h
    call setElement

    call checkNumMat

    cmp AL, 0  
    jne error_2

    cmp CL, 01h
    jne error_2

    jmp test3

;------Test 3: Invalid Matrix ID-------------------------------------


test3:
    mov DX, 02h ; incorrect ID

    call checkNumMat

    cmp AL, 9  
    jne error_3
    mov AL, 0
    jmp end_tests

error_1:
    mov AL, 1
    jmp end_tests

error_2:
    mov al, 2
    jmp end_tests

error_3:
    mov AL,3
    jmp end_tests

end_tests: 
    mov AH, 4Ch
    int 21h

main endp
end main