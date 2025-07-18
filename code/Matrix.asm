.286 
INCLUDE LIB.INC
.model small

public user_stack_size, max_element_in_matrix, max_matr, matrix_count, matrixInit
public descriptors, newMatrix, checkID, freeMatrix

.data 
user_stack_size dw ?
max_element_in_matrix dw ?
max_matr dw ?                   ; max number of matrixs
matrix_count dw 0
descriptors Matrix 64h dup (<>) ; 100 descriptors reserved

.code
matrixInit PROC    
    mov [max_element_in_matrix], BX ; may be useful in the future
    mov [user_stack_size], AX ; as well
    
    clc ; clear CF just in case

    push SI
    push DX
    push BP
    mov BP, SP 
    push AX
    push BX ; pushing registers 

    ; enough space for user's stack?
    cmp AX, SP
    ja errors ; user's stack > SP => error

    ; max_elem = 0?
    cmp BX, 0
    je errors ; max_elem = 0 => nothing to allocate, error


    ; 1 matrix
    mov DX, BX
    shl DX, 2 ; DX*4, using .316, of not suitable i'll redo it. source: https://metanit.com/assembler/tutorial/2.9.php
    jc errors ; if overflow, DX > memory => error

    mov SI, SP 
    sub SI, AX ; SI = avaliable space fpr matrices 

    ; calculating the number of avaliable matrices
    mov AX, SI
    xor DX, DX
    shl BX, 2 ; BX = actual number of bytes in a matrix
    div BX ; AX = free_space / 1_matrix
    mov CX, AX ; this will be returned

    cmp CX, 64h ; number of decriptors < 100?
    jb skip_hundred
    mov CX, 64h ; number of descriptors = 100

skip_hundred:

    mov [max_matr], CX 
    mov DI, SP
    sub SP, [BP - 2] ; SP -= user's stack, reserving it

    ; setting up descriptors loop
    mov AX, SP ; AX = beginning adress
    xor SI, SI; SI = 0  (useful later)
    ; BX = real matrix size
    
   
    mov SP, DI 
    
    push CX ; needed for loop
    cmp CX, 0 
    je skipLoop ; CX = 0, so no matrices. This situation is unlikely to happen but who knows
    mov DI, offset descriptors
    xor DI, DI ; good tone

loopForDescriptors:
    ; used flag = 0.
    mov word ptr [descriptors + SI].DataPointer, AX ; exact matrix
    mov word ptr [descriptors + SI].DataPointer + 2, SS ; stack segment
    ; Rows = 0
    ; Cols = 0
    add SI, DESCRIPTOR_SIZE ; next descriptor
    sub AX, BX ; next matrix
    loop loopForDescriptors

skipLoop:
    pop CX ; CX = 0, CX is needed to be restored
    clc ; CF = 0
    jmp ending 

errors:
    
    
    xor CX, CX ; just in case
    stc ; CF = 1
    pop BX
    pop AX
    pop BP
    pop DX
    pop SI
    mov AL, ERR_MEM_ALLOC ; error code
    RET

ending:
    pop BX
    pop AX
    pop BP
    pop DX
    pop SI
    xor AL, AL ; Al = 0
    RET
matrixInit ENDP

;---------------------------------------

newMatrix PROC
    push bx
    push cx
    push si
    push di
    push es

    mov cx, [matrix_count]
    cmp cx, [max_matr]
    jae memory_error

    cmp ax, 0
    jbe dim_error
    cmp bx, 0
    jbe dim_error

    push ax
    mul bx
    cmp ax, [max_element_in_matrix]
    ja dim_error_mul
    pop ax
    
    mov cx, [max_matr]                      ;searching for a free slot
    xor si, si
find_slot:
    cmp [descriptors + si].UsedFlag, 0
    je slot_found
    add si, sizeof Matrix
    loop find_slot
    jmp memory_error

slot_found:
    ; setting used flag
    mov [descriptors + si].UsedFlag, 1

    ; saving dimensions of a new matrix
    mov [descriptors + si].Rows, ax
    mov [descriptors + si].Columns, bx

    ; cleaning matrix storage
    les di, [descriptors + si].DataPointer
    mov cx, [max_element_in_matrix]       ; cuz cleaning byte by byte
    shl cx, 2           ; real size
    xor ax, ax
    std
    rep stosb
    cld
    ; increasing number of current matrices 
    inc [matrix_count]

    ; returning ID of a matrix (index = matrix_list / sizeof Matrix)
    mov ax, si
    xor dx, dx
    mov cx, sizeof Matrix
    div cx
    mov dx, ax

    clc
    mov al, 00h
    jmp createMatrix_exit


memory_error:      ; memory_error 
    mov al, 02h
    xor dx, dx
    jmp createMatrix_exit 
dim_error_mul:
    pop ax          ; or else the stack is ruined
dim_error:
    mov al, 03h             ; dimension_error 
    xor dx, dx
createMatrix_exit:
    pop es
    pop di
    pop si
    pop cx
    pop bx
    ret
newMatrix ENDP

checkID PROC
    cmp DX, [max_matr]
    jae invalid_id
    mov DI, DX
    imul DI, DESCRIPTOR_SIZE
    cmp [descriptors + DI].UsedFlag, 0
    je invalid_id
    xor AX, AX
    ret
invalid_id:
    mov AL, ERR_INCORRECT_ID
    ret
checkID ENDP

freeMatrix PROC
    push bx
    push si
    push di

    call checkID                         ;validates id of matrix
    cmp al, 0
    jnz freeMatrix_exit                  ;if there is an error jump to exit

    mov [descriptors + di].UsedFlag, 0   ;remove used flag
    dec [matrix_count]
    xor AL, AL                           ; no errors   

freeMatrix_exit:
    pop bx 
    pop si
    pop di
    ret    
freeMatrix ENDP

END

