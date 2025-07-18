.286
.287
.model small
INCLUDE LIB.INC

EXTRN checkID:near, getDim:near, getElement:near, setElement:near, newMatrix:near, freeMatrix:near
PUBLIC invMatrix

.data
    src_id      dw  ?       
    aug_id      dw  ?       
    inv_id      dw  ?       
    n           dw  ?       
    two_n       dw  ?       
    i           dw  ?       
    j           dw  ?       
    k           dw  ?       
    m           dw  ?       
    pivot       dd  ?       
    factor      dd  ?       
    temp        dd  ?       
    a_im        dd  ?       
    a_jm        dd  ?       

.code
invMatrix PROC

    push BX
    push SI
    push DI

    mov [src_id], DX        

    call checkID
    cmp AL, 0
    jne error_incorrect_id

    call getDim             
    cmp BX, SI
    jne error_non_square
    mov [n], BX             
    mov AX, BX
    shl AX, 1
    mov [two_n], AX         

    mov AX, [n]
    mov BX, [two_n]
    call newMatrix
    cmp AL, 0
    jne error_memory
    mov [aug_id], DX        

    mov word ptr [i], 0
loop_init_i:
    mov AX, [i]
    cmp AX, [n]
    jge end_init
    mov word ptr [j], 0
loop_init_j:
    mov AX, [j]
    cmp AX, [two_n]
    jge end_init_j
    cmp AX, [n]
    jl copy_from_A
    mov AX, [j]
    mov BX, AX
    sub BX, [n]
    cmp BX, [i]
    je set_one
    mov CX, 0          
    mov DI, 0
    jmp set_element_aug
set_one:
    mov CX, 3F80h      
    mov DI, 0000h
    jmp set_element_aug
copy_from_A:
    mov DX, [src_id]
    mov BX, [i]
    mov SI, [j]

    call getElement    
set_element_aug:
    mov DX, [aug_id]
    mov BX, [i]
    mov SI, [j]
    call setElement
    inc word ptr [j]
    jmp loop_init_j
end_init_j:
    inc word ptr [i]
    jmp loop_init_i
end_init:

    FINIT                   
    mov word ptr [i], 0
loop_i:
    mov AX, [i]
    cmp AX, [n]
    jge end_loops

    mov DX, [aug_id]
    mov BX, [i]
    mov SI, [i]
    call getElement
    mov AX, [i]
    mov word ptr [pivot], DI
    mov word ptr [pivot+2], CX

    FLD dword ptr [pivot]
    FTST
    FSTSW AX
    SAHF
    FSTP ST(0)
    jne pivot_nonzero

    mov AX, [i]
    inc AX
    mov [k], AX
loop_find_k:
    mov AX, [k]
    cmp AX, [n]
    jge singular_matrix
    mov DX, [aug_id]
    mov BX, [k]
    mov SI, [i]
    call getElement
    mov AX, [k]
    mov word ptr [temp], DI
    mov word ptr [temp+2], CX
    FLD dword ptr [temp]
    FTST
    FSTSW AX
    SAHF
    FSTP ST(0)
    jne swap_rows
    inc word ptr [k]
    jmp loop_find_k

swap_rows:
    mov word ptr [m], 0
loop_swap_m:
    mov AX, [m]
    cmp AX, [two_n]
    jge end_swap
    mov DX, [aug_id]
    mov BX, [i]
    mov SI, [m]
    call getElement
    mov word ptr [temp], DI
    mov word ptr [temp+2], CX
    mov DX, [aug_id]
    mov BX, [k]
    mov SI, [m]
    call getElement
    push CX
    push DI
    mov BX, [i]
    call setElement
    pop DI
    pop CX
    mov BX, [k]
    call setElement
    inc word ptr [m]
    jmp loop_swap_m
end_swap:
    mov DX, [aug_id]
    mov BX, [i]
    mov SI, [i]
    call getElement
    mov word ptr [pivot], DI
    mov word ptr [pivot+2], CX

pivot_nonzero:
    mov word ptr [m], 0
loop_norm_m:
    mov AX, [m]
    cmp AX, [two_n]
    jge end_norm
    mov DX, [aug_id]
    mov BX, [i]
    mov SI, [m]
    call getElement
    mov word ptr [temp], DI
    mov word ptr [temp+2], CX
    FLD dword ptr [temp]
    FLD dword ptr [pivot]
    FDIVP ST(1), ST(0)
    FSTP dword ptr [temp]
    mov CX, word ptr [temp+2]
    mov DI, word ptr [temp]
    call setElement
    inc word ptr [m]
    jmp loop_norm_m
end_norm:

    mov word ptr [j], 0
loop_j:
    mov AX, [j]
    cmp AX, [n]
    jge next_i
    cmp AX, [i]
    je skip_j
    mov DX, [aug_id]
    mov BX, [j]
    mov SI, [i]
    call getElement
    mov word ptr [factor], DI
    mov word ptr [factor+2], CX
    mov word ptr [m], 0
loop_elim_m:
    mov AX, [m]
    cmp AX, [two_n]
    jge end_elim_j
    mov DX, [aug_id]
    mov BX, [j]
    mov SI, [m]
    call getElement
    mov word ptr [a_jm], DI
    mov word ptr [a_jm+2], CX
    mov DX, [aug_id]
    mov BX, [i]
    mov SI, [m]
    call getElement
    mov word ptr [a_im], DI
    mov word ptr [a_im+2], CX
    FLD dword ptr [factor]
    FLD dword ptr [a_im]
    FMULP ST(1), ST(0)
    FLD dword ptr [a_jm]
    FSUBRP ST(1), ST(0)
    FSTP dword ptr [a_jm]
    mov CX, word ptr [a_jm+2]
    mov DI, word ptr [a_jm]
    mov BX, [j]
    mov SI, [m]
    call setElement
    inc word ptr [m]
    jmp loop_elim_m
end_elim_j:
skip_j:
    inc word ptr [j]
    jmp loop_j
next_i:
    inc word ptr [i]
    jmp loop_i
end_loops:

    mov AX, [n]
    mov BX, [n]
    call newMatrix
    cmp AL, 0
    jne error_memory_inv
    mov [inv_id], DX

    mov word ptr [i], 0
loop_copy_i:
    mov AX, [i]
    cmp AX, [n]
    jge end_copy
    mov word ptr [j], 0
loop_copy_j:
    mov AX, [j]
    cmp AX, [n]
    jge end_copy_i
    mov DX, [aug_id]
    mov BX, [i]
    mov SI, [j]
    add SI, [n]
    call getElement
    mov DX, [inv_id]
    mov BX, [i]
    mov SI, [j]
    call setElement
    inc word ptr [j]
    jmp loop_copy_j
end_copy_i:
    inc word ptr [i]
    jmp loop_copy_i
end_copy:

    mov DX, [aug_id]
    call freeMatrix
    mov DX, [inv_id]
    xor AL, AL
    jmp invMatrix_exit

singular_matrix:
    mov DX, [aug_id]
    call freeMatrix
    mov AL, ERR_SINGULAR
    jmp invMatrix_exit

error_memory:
    mov AL, ERR_MEM_ALLOC
    jmp invMatrix_exit

error_memory_inv:
    mov DX, [aug_id]
    call freeMatrix
    mov AL, ERR_MEM_ALLOC
    jmp invMatrix_exit

error_non_square:
    mov AL, ERR_NON_SQUARE
    jmp invMatrix_exit

error_incorrect_id:
    mov AL, ERR_INCORRECT_ID

invMatrix_exit:
    pop DI
    pop SI
    pop BX
    ret
invMatrix ENDP

END