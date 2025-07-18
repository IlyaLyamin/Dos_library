.286
.model small
INCLUDE LIB.INC

EXTRN descriptors:Matrix
EXTRN getElement:near, setElement:near, newMatrix:near, checkID:near, getDim:near
PUBLIC negMatrix

.data 
matrix1_id dw ?
matrix2_id dw ?
matrix_rows dw ?
matrix_cols dw ?
.code 
negMatrix PROC
    push SI
    push DI
    push CX
    push BX 
    
    ; DX = ID of a matrix to mult. by -1
    call checkID 
    cmp AL, 0
    jne error_incorrect_id
    ; DI = offset for a decriptor
    mov [matrix1_id], DX
    
    call getDim

    mov [matrix_rows], BX
    mov [matrix_cols], SI

    mov AX, [matrix_rows]
    xchg BX, SI
    
    call newMatrix ; registers are quite weird

    cmp AL, ERR_MEM_ALLOC
    je error_allocate

    mov [matrix2_id], DX

    xor CX, CX
loop_for_rows:
    cmp CX, [matrix_rows]
    jge end_loops 

    xor AX, AX
    loop_for_columns:
        cmp AX, [matrix_rows]
        jge next_row


        mov DX, [matrix1_id]
        mov BX, CX
        mov SI, AX

        push CX
        push AX

        call getElement

        mov DX, [matrix2_id]
        
        xor CX, 8000h ; inverting number 

        call setElement
        
        pop AX
        pop CX

        inc AX
        jmp loop_for_columns


    next_row:
        inc CX
        jmp loop_for_rows

end_loops:
    mov DX, [matrix2_id]
    xor AL, AL

error_incorrect_id:
    ; AL = incorrect_id
    jmp transpMatrix_exit

error_allocate:
    ; AL = alloc
    jmp transpMatrix_exit

transpMatrix_exit:
    pop BX
    pop CX
    pop DI
    pop SI
    ret 
negMatrix ENDP

END
