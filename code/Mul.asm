.286
.287
.model small
INCLUDE LIB.INC


EXTRN getElement:near, setElement:near, getDim:near, checkID:near, \
 newMatrix:near
PUBLIC mulMatrix

.data
matrix1_id dw ?
matrix2_id dw ?

matrix1_rows dw ?
matrix1_cols dw ?

matrix2_rows dw ?
matrix2_cols dw ?

matrix_result_id dw ?

buffer_el_1 dd ?
buffer_el_2 dd ?
buffer_sum dd ?

current_row dw 0
current_column dw 0
current_k dw 0
.code 
mulMatrix PROC
    ; AX = first matrix
    ; BX = second matrix 

    push SI

    mov [matrix1_id], AX
    mov [matrix2_id], BX

    mov DX, AX
    call getDim

    cmp AL, ERR_INCORRECT_ID
    je error_ID

    mov [matrix1_rows], BX
    mov [matrix1_cols], SI
    
    mov DX, [matrix2_id]
    call getDim

    cmp AL, ERR_INCORRECT_ID
    je error_ID

    mov [matrix2_rows], BX
    mov [matrix2_cols], SI

    cmp BX, [matrix1_cols] ; cols(A) = rows(B)
    jne error_incompat

    mov AX, [matrix1_rows]
    mov BX, [matrix2_cols]
    call newMatrix

    cmp AL, ERR_INVALID_DIMS
    je error_invalid

    mov [matrix_result_id], DX

    push DI
    push CX

    FINIT

loop_for_rows:
    mov AX, [current_row]
    cmp AX, [matrix1_rows]
    jge end_loops

    mov [current_column], 0
    loop_for_columns:
        mov AX, [current_column]
        cmp AX, [matrix2_cols]
        jge next_row

        mov word ptr [buffer_sum], 0
        mov word ptr [buffer_sum+2], 0

        FLD [buffer_sum]
        mov [current_k], 0

        loop_for_element:
            mov AX, [current_k]
            cmp AX, [matrix1_cols]
            jge next_column

            mov BX, [current_row] ; A[i][k]
            mov SI, [current_k]

            
            mov DX, [matrix1_id]
            call getElement

            mov word ptr [buffer_el_1+2], CX
            mov word ptr [buffer_el_1], DI

            mov BX, [current_k] ; B[k][j]
            mov SI, [current_column]

            mov DX, [matrix2_id]
            call getElement
            
            mov word ptr [buffer_el_2+2], CX
            mov word ptr [buffer_el_2], DI

            FLD [buffer_el_1]
            FLD [buffer_el_2]
            FMULP st(1), st(0)
            FADDP st(1), st(0) ; FPU is kinda tricky
            
            ; sum += A[i][k] * B[k][j]

            inc [current_k]
            jmp loop_for_element
        
        next_column:
        FSTP [buffer_sum]
        mov BX, [current_row]
        mov SI, [current_column]

        mov CX, word ptr [buffer_sum+2]
        mov DI, word ptr [buffer_sum]
        mov DX, [matrix_result_id]
        call setElement

        inc [current_column]
        jmp loop_for_columns

    next_row:
    inc [current_row]
    jmp loop_for_rows


end_loops:
    pop CX
    pop DI

    mov AL, 0
    mov DX, [matrix_result_id]
    jmp mul_end



error_invalid:
    jmp mul_end


error_incompat:
    mov AL, ERR_INCOMPAT_DIMS
    jmp mul_end
    

error_ID:
    jmp mul_end


mul_end:
    pop SI
    ret 

mulMatrix ENDP

END