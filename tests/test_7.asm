.286
.287
.model small
.stack 0FFFFh

EXTRN matrixInit:near, newMatrix: near, setElement:near,getElement:near, addMatrix:near

.data 
    matrix_ind_1    dw ?
    matrix_ind_2    dw ?
    matrix_result_1 dw ?
    matrix_result_2 dw ?

    matrix_ind_3    dw ?
    matrix_ind_4    dw ?

    ;buffer          dd ?
    scalar          dd 2.0
.code 

main proc
    mov AX, @data
    mov DS, AX

    mov AX, 400h ; user_stack_size 
    mov BX, 10h ; max_elements
    call matrixInit 

;-------Test 1: Valid Matrix Addition-------------

    mov AX, 02h ; rows
    mov BX, 02h ; columns
    call newMatrix
    mov [matrix_ind_1], DX

    mov AX, 02h ; rows 
    mov BX, 02h ; cols
    call newMatrix
    mov [matrix_ind_2], DX

    mov DX, [matrix_ind_1]
    mov BX, 00h ; row
    mov SI, 00h ; column
    mov CX, 3f80h ; 1
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
    

;   [1, 2] 
;   [3, 4]

    mov DX, [matrix_ind_2]
    mov BX, 00h ; row
    mov SI, 00h ; column
    mov CX, 40a0h ; 5
    mov DI, 0000h
    call setElement
    

    mov BX, 00h ; row
    mov SI, 01h ; column
    mov CX, 40c0h ; 6
    mov DI, 0000h
    call setElement
    

    mov BX, 01h ; row
    mov SI, 00h ; column
    mov CX, 40e0h ; 7
    mov DI, 0000h
    call setElement
    

    mov BX, 01h ; row
    mov SI, 01h ; column
    mov CX, 4100h ; 8
    mov DI, 0000h
    call setElement
    

;   [5, 6] 
;   [7, 8]




;   [6, 8] 
;   [10, 12]

    mov AX, [matrix_ind_1]
    mov BX, [matrix_ind_2]

    call addMatrix
    mov [matrix_result_1], DX

    ;[0, 0]
    mov BX, 00h
    mov SI, 00h
    mov DX, [matrix_result_1]
    call getElement

    cmp CX, 40c0h ; 6
    jne error_1
    cmp DI, 0000h
    jne error_1

    ;[0, 1]
    mov BX, 00h
    mov SI, 01h
    mov DX, [matrix_result_1]
    call getElement

    cmp CX, 4100h ; 8
    jne error_1
    cmp DI, 0000h
    jne error_1

    ;[1, 0]
    mov BX, 01h
    mov SI, 00h
    mov DX, [matrix_result_1]
    call getElement

    cmp CX, 4120h ; 10
    jne error_1
    cmp DI, 0000h
    jne error_1

    ;[1, 1]
    mov BX, 01h
    mov SI, 01h
    mov DX, [matrix_result_1]
    call getElement

    cmp CX, 4140h ; 12
    jne error_1
    cmp DI, 0000h
    jne error_1

    
;-------Test 2: Dimension Mismatch--------------

    mov AX, 02h ; rows
    mov BX, 02h ; columns
    call newMatrix
    mov [matrix_ind_3], DX

    mov AX, 03h ; rows
    mov BX, 02h ; columns
    call newMatrix
    mov [matrix_ind_4], DX

    mov AX, [matrix_ind_3]
    mov BX, [matrix_ind_4]
    call addMatrix
    
    cmp AL, 5
    jne error_2

    mov AL, 0
    jmp end_tests

error_1:
    mov AL, 1
    jmp end_tests

error_2:
    mov AX, 2
    jmp end_tests

end_tests: 
    mov AH, 4Ch
    int 21h

main endp
end main