.286
.model small
INCLUDE LIB.INC

EXTRN descriptors:Matrix
EXTRN getElement:near, setElement:near, newMatrix:near, checkID:near, \
getDim:near, mulMatrix:near, freeMatrix:near
PUBLIC degMatrix

.data 
matrix_src_id       dw ?
matrix_rslt_id      dw ?
matrix_buffer_id    dw ?
to_copy_id          dw ?
n                   dw ?
exponent            dw ?
i                   dw ?
j                   dw ?
loop_limit          dw ?  ; Новая переменная для ограничения цикла

.code 

degMatrix PROC
    
    mov [matrix_src_id], ax
    mov [exponent], bx

    mov dx, ax
    call getDim
    cmp al, ERR_INCORRECT_ID
    je error_ID

    push si
    cmp bx, si
    jne error_not_square

    mov [n], bx

    push cx
    push di

    mov ax, [n]
    mov bx, [n]
    call newMatrix
    cmp al, 0
    jne error_alloc

    mov [matrix_rslt_id], dx
    
    mov ax, [exponent]
    cmp ax, 0
    je identity_m

    mov dx, [matrix_src_id]
    mov [to_copy_id], dx

    call matrixCopy
    cmp al, ERR_MEM_ALLOC
    je error_alloc

    mov bx, [exponent]
    cmp bx, 1
    je deg_exit

    ; Устанавливаем loop_limit = exponent - 1
    mov ax, bx
    dec ax
    mov [loop_limit], ax

    mov [i], 0

loop_mul:
    mov ax, [i]
    cmp ax, [loop_limit]
    jge deg_exit

    mov ax, [matrix_rslt_id]
    mov bx, [matrix_src_id]
    call mulMatrix
    cmp al, ERR_MEM_ALLOC
    je error_alloc

    mov [matrix_buffer_id], dx
    mov [to_copy_id], dx
    call matrixCopy

    ; Освобождаем временную матрицу
    push dx
    mov dx, [matrix_buffer_id]
    call freeMatrix
    pop dx

    inc [i]
    jmp loop_mul

identity_m:
    mov [i], 0
loop_ident:
    mov ax, [i]
    cmp ax, [n]
    jge deg_exit

    mov dx, [matrix_rslt_id]
    mov cx, 3f80h  ; 1.0 в формате float
    mov di, 0000h
    mov bx, [i]
    mov si, [i]
    call setElement

    inc [i]
    jmp loop_ident

error_not_square:
    pop si
    mov al, ERR_NON_SQUARE
    ret

error_alloc:
    mov al, ERR_MEM_ALLOC
    pop di
    pop cx
    pop si
    ret 

error_ID:
    ret

deg_exit:
    pop di
    pop cx
    pop si
    xor al, al
    ret  ; Убрано освобождение matrix_buffer_id, так как оно происходит в цикле
degMatrix ENDP

matrixCopy PROC
    mov [i], 0
loop_copy_i:
    mov ax, [i]
    cmp ax, [n]
    jge end_loops

    mov [j], 0
loop_copy_j:
    mov ax, [j]
    cmp ax, [n]
    jge next_row

    mov dx, [to_copy_id]
    mov bx, [i]
    mov si, [j]
    call getElement

    mov dx, [matrix_rslt_id]
    call setElement

    inc [j]
    jmp loop_copy_j

next_row:
    inc [i]
    jmp loop_copy_i

end_loops:
    ret
matrixCopy ENDP

END