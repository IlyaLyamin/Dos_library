.286
.287
.model small
INCLUDE LIB.INC


EXTRN getElement:near, setElement:near, getDim:near, checkID:near, \
 newMatrix:near
PUBLIC subMatrix

.data
matrix1_id dw ?
matrix2_id dw ?

matrix_rows dw ?
matrix_cols dw ?

matrix_result_id dw ?

buffer_sum dd ?
buffer_to_sub dd ?

current_row dw 0
current_column dw 0
current_k dw 0
.code 
subMatrix PROC
    ; ax = first matrix
    ; bx = second matrix 

    push si

    mov [matrix1_id], ax
    mov [matrix2_id], bx

    mov dx, ax
    call getDim

    cmp al, ERR_INCORRECT_ID
    je error_ID

    mov [matrix_rows], bx
    mov [matrix_cols], si
    
    mov dx, [matrix2_id]
    call getDim

    cmp al, ERR_INCORRECT_ID
    je error_ID

    cmp bx, [matrix_rows]
    jne error_mismatch

    cmp si, [matrix_cols]
    jne error_mismatch


    mov ax, [matrix_rows]
    mov bx, [matrix_cols]
    call newMatrix

    mov [matrix_result_id], dx

    push di
    push cx

    FINIT

loop_for_rows:
    mov ax, [current_row]
    cmp ax, [matrix_rows]
    jge end_loops

    mov [current_column], 0
    loop_for_columns:
        mov ax, [current_column]
        cmp ax, [matrix_cols]
        jge next_row

        mov word ptr [buffer_sum], 0
        mov word ptr [buffer_sum+2], 0
        
        mov bx, [current_row]
        mov si, [current_column]
        mov dx, [matrix1_id]
        call getElement

        mov word ptr [buffer_sum+2], cx 
        mov word ptr [buffer_sum], di 

        mov dx, [matrix2_id]
        call getElement

        mov word ptr [buffer_to_sub+2], cx 
        mov word ptr [buffer_to_sub], di 

        FLD [buffer_sum]
        FLD [buffer_to_sub]
        FSUBP st(1), st(0)

        FSTP [buffer_sum]
        mov bx, [current_row]
        mov si, [current_column]

        mov cx, word ptr [buffer_sum+2]
        mov di, word ptr [buffer_sum]
        mov dx, [matrix_result_id]
        call setElement

        inc [current_column]
        jmp loop_for_columns

    next_row:
    inc [current_row]
    jmp loop_for_rows


end_loops:
    pop cx
    pop di

    mov al, 0
    mov dx, [matrix_result_id]
    jmp sub_end


error_mismatch:
    mov al, ERR_DIM_MISMATCH
    jmp sub_end
    

error_ID:
    jmp sub_end


sub_end:
    pop si
    ret 

subMatrix ENDP

END