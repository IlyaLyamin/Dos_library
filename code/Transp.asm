.286
.model small
INCLUDE LIB.INC

EXTRN descriptors:Matrix
EXTRN getElement:near, setElement:near, newMatrix:near, checkID:near, getDim:near
PUBLIC transpMatrix

.data 

.code 
transpMatrix PROC
    push SI
    push DI
    push CX
    push BX 
    push BP
    
    ; DX = ID of a matrix to transpose
    call checkID 
    cmp AL, 0
    jne error_incorrect_id
    ; DI = offset fo a decriptor
    mov BP, SP
    push DX ; source id, BP - 2
    push DI ; source offset, BP - 4


    
    call getDim

    push BX ; source rows, BP - 6
    push SI ; source columns, BP - 8

    mov AX, SI
    
    call newMatrix ; registers are quite weird

    cmp AL, ERR_MEM_ALLOC
    je error_allocate

    push DX ; new matrix ID, BP - 10

    xor CX, CX
loop_for_rows:
    cmp CX, [BP-6] 
    jge end_loops 

    xor AX, AX
    loop_for_columns:
        cmp AX, [BP-8]
        jge next_row


        mov DX, [BP-2]
        mov BX, CX
        mov SI, AX

        push CX
        push AX

        call getElement

        mov DX, [BP-10]
        xchg BX, SI 

        call setElement
        
        pop AX
        pop CX

        inc AX
        jmp loop_for_columns


    next_row:
        inc CX
        jmp loop_for_rows

end_loops:
    mov DX, [BP-10]
    xor AL, AL

    add SP, 0Ah

error_incorrect_id:
    ; AL = incorrect_id
    jmp transpMatrix_exit

error_allocate:
    ; AL = alloc
    add SP, 08h
    jmp transpMatrix_exit

transpMatrix_exit:
    pop BP
    pop BX
    pop CX
    pop DI
    pop SI
    ret 
transpMatrix ENDP

END