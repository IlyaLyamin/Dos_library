.286
.287
.model small
INCLUDE LIB.INC

EXTRN checkID:near, getDim:near, getElement:near, setElement:near
PUBLIC detMatrix

.data
    matrix_id   dw  ?
    n           dw  ?
    det         dd  0.0
    temp        dd  0.0
    pivot       dd  0.0
    a_ji        dd  0.0
    factor      dd  0.0
    a_jm        dd  0.0
    a_im        dd  0.0
    i           dw  0
    j           dw  0
    k           dw  0
    m           dw  0

.code
detMatrix PROC
    push BX
    push SI
    mov [matrix_id], DX
    call checkID
    cmp AL, 0
    jne error_incorrect_id
    call getDim
    cmp AL, 0
    jne error_incorrect_id
    cmp BX, SI
    jne error_non_square
    mov [n], BX
    FINIT
    FLD1
    FSTP dword ptr [det]
    mov word ptr [i], 0
loop_i:
    mov ax, [i]
    cmp ax, [n]
    jge end_loops
    mov BX, [i]
    mov SI, [i]
    mov DX, [matrix_id]
    call getElement
    mov word ptr [pivot], DI
    mov word ptr [pivot+2], CX
    FLD dword ptr [pivot]
    FTST
    FSTSW AX
    SAHF
    FSTP ST(0)
    je find_k
    jmp eliminate
find_k:
    mov AX, [i]
    inc AX
    mov [k], AX
loop_k:
    mov AX, [k]
    cmp AX, [n]
    jge no_pivot
    mov BX, [k]
    mov SI, [i]
    mov DX, [matrix_id]
    call getElement
    mov word ptr [a_ji], DI
    mov word ptr [a_ji+2], CX
    FLD dword ptr [a_ji]
    FTST
    FSTSW AX
    SAHF
    FSTP ST(0)
    jne swap_rows
    inc word ptr [k]
    jmp loop_k
no_pivot:
    FLDZ
    FSTP dword ptr [det]
    jmp end_loops
swap_rows:
    mov word ptr [m], 0
loop_m_swap:
    mov AX, [m]
    cmp AX, [n]
    jge end_swap
    mov BX, [i]
    mov SI, [m]
    call getElement
    mov word ptr [temp], DI
    mov word ptr [temp+2], CX
    mov BX, [k]
    mov SI, [m]
    call getElement
    push CX
    push DI
    mov BX, [i]
    call setElement
    mov BX, [k]
    mov SI, [m]
    mov CX, word ptr [temp+2]
    mov DI, word ptr [temp]
    call setElement
    inc word ptr [m]
    jmp loop_m_swap
end_swap:
    FLD dword ptr [det]
    FCHS
    FSTP dword ptr [det]
eliminate:
    mov BX, [i]
    mov SI, [i]
    mov DX, [matrix_id]
    call getElement
    mov word ptr [pivot], DI
    mov word ptr [pivot+2], CX
    mov AX, [i]
    inc AX
    mov [j], AX
loop_j:
    mov AX, [j]
    cmp AX, [n]
    jge next_i
    mov BX, [j]
    mov SI, [i]
    call getElement
    mov word ptr [a_ji], DI
    mov word ptr [a_ji+2], CX
    FLD dword ptr [a_ji]
    FLD dword ptr [pivot]
    FDIVP ST(1), ST(0)
    FSTP dword ptr [factor]
    mov word ptr [m], 0
loop_m_elim:
    mov AX, [m]
    cmp AX, [n]
    jge next_j
    mov BX, [j]
    mov SI, [m]
    call getElement
    mov word ptr [a_jm], DI
    mov word ptr [a_jm+2], CX
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
    mov BX, [j]
    mov SI, [m]
    mov CX, word ptr [a_jm+2]
    mov DI, word ptr [a_jm]
    call setElement
    inc word ptr [m]
    jmp loop_m_elim
next_j:
    inc word ptr [j]
    jmp loop_j
next_i:
    FLD dword ptr [det]
    FLD dword ptr [pivot]
    FMULP ST(1), ST(0)
    FSTP dword ptr [det]
    inc word ptr [i]
    jmp loop_i
end_loops:
    mov CX, word ptr [det+2]
    mov DI, word ptr [det]
    xor AL, AL
    jmp detMatrix_exit
error_non_square:
    mov AL, ERR_NON_SQUARE
    jmp detMatrix_exit
error_incorrect_id:
    mov AL, ERR_INCORRECT_ID
    jmp detMatrix_exit
detMatrix_exit:
    pop SI
    pop BX
    ret
detMatrix ENDP
END