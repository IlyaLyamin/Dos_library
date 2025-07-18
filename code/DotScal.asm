.286
.287
.model small
INCLUDE LIB.INC


EXTRN getElement:near, setElement:near, getDim:near, checkID:near, \
 newMatrix:near
PUBLIC dotMatrix


.data
source_matrix_id    dw  0h
res_matrix_id       dw  0h    
rows                dw  0h
columns             dw  0h   
current_row         dw  0h
current_column      dw  0h
scalar              dd  0h
buffer              dd  0h

.code
dotMatrix PROC
    ; dx - ID of matrix
    ; cx:di - scalar
    mov word ptr [source_matrix_id], dx
    mov word ptr [scalar], di
    mov word ptr [scalar + 2], cx   ; di cx: 00 00 00 40

    push bx
    push si
    
    call getDim                     ; bx - rows, si - columns
    cmp al, ERR_INCORRECT_ID
    je incorrect_id

    mov word ptr [rows], bx
    mov word ptr [columns], si

    mov ax, bx
    mov bx, si
    call newMatrix
    cmp al, ERR_MATRIX_FULL
    je no_free_slots

    cmp al, ERR_INVALID_DIMS
    je invalid_dim 

    mov word ptr [res_matrix_id], dx

    FINIT

    push cx
    push di

    xor bx, bx
    xor si, si

    xor cx, cx
    mov cx, word ptr [rows] 
row_cycle:
    push cx
    mov cx, word ptr [columns]
column_cycle:
    push cx
    mov bx, word ptr [current_row]
    mov si, word ptr [current_column]
    mov dx, word ptr [source_matrix_id]
    call getElement                     ; cx:di
    mov word ptr [buffer], di
    mov word ptr [buffer + 2], cx

    FLD dword ptr [scalar] 
    FLD dword ptr [buffer]   
    FMULP st(1), st(0)      
    FSTP dword ptr [buffer]

    mov dx, word ptr [res_matrix_id]
    mov cx, word ptr [buffer + 2]
    mov di, word ptr [buffer]
    call setElement


    inc word ptr [current_column]
    pop cx
    loop column_cycle

    mov word ptr [current_column], 0h

    pop cx

    inc word ptr [current_row]
    loop row_cycle

    jmp end_prog

invalid_dim:
    pop si
    pop bx
    ret

no_free_slots:
    pop si
    pop bx
    ret

incorrect_id:
    ret

end_prog:
    mov dx, word ptr [res_matrix_id]
    pop di
    pop cx 
    pop si
    pop bx
    xor ax, ax
     
    ret 

dotMatrix ENDP

END