.286
.model small
INCLUDE LIB.INC

EXTRN descriptors:Matrix
EXTRN checkID:near
PUBLIC getDim, setElement, getElement, checkNumMat

.data

.code
getDim PROC near
    ; DX - descriptor(ID)

    push DI

    call checkID  
    cmp al, 09h
    je end_prog

    mov BX, word ptr [descriptors + DI].Rows
    mov DI, word ptr [descriptors + DI].Columns

    mov SI, DI
    xor AL, AL

end_prog:
    pop DI
    ret
getDim ENDP


setElement PROC 
    push es
    push bp
    mov bp, sp

    push dx ; bp - 2, matrix ID
    push bx ; bp - 4, row
    push si ; bp - 6, column
    push cx ; bp - 8, float1
    push di ; bp - 10, float2

    call checkId 

    ; errors
    cmp al, 9
    je error_incorrect_id

    mov ax, [descriptors + di].Rows
    cmp bx, ax
    jae error_out_of_bounds

    mov ax, [descriptors + di].Columns
    cmp si, ax
    jae error_out_of_bounds


    ; offset
    mov ax, [descriptors + di].Columns
    mul bx
    add ax, si
    shl ax, 2
    add ax, 3

    les di, [descriptors + di].DataPointer
    sub di, ax

    pop cx
    pop ax
    

    mov es:[di], cx
    mov es:[di+2], ax
    mov di, cx
    mov cx, ax
    mov al, 0
    jmp setElement_exit


error_incorrect_id:
    pop di
    pop cx
    mov al, ERR_INCORRECT_ID
    jmp setElement_exit

error_out_of_bounds:
    pop di
    pop cx
    mov al, ERR_OUT_OF_BOUNDS
    
setElement_exit:
    pop si 
    pop bx 
    pop dx 
    pop bp 
    pop es
    ret

setElement ENDP

getElement PROC 
    push es
    push dx
    push bx
    push si

    ; id
    call checkID
    cmp al, 09h
    je getElement_error_id

    ; bounds
    mov ax, [descriptors + di].Rows
    cmp bx, ax
    jae getElement_error_bound
    mov ax, [descriptors + di].Columns
    cmp si, ax
    jae getElement_error_bound

    ;address
    mov ax, [descriptors + di].Columns
    mul bx
    add ax, si
    shl ax, 2
    add ax, 3 ; in data

    les di, [descriptors + di].DataPointer ; seg + offset(begining)
    sub di, ax ; exact element

    mov cx, es:[di+2] ; upper
    mov di, es:[di] ; lowwer
    xor ax,ax
    jmp getElement_exit

getElement_error_id:
    mov al, ERR_INCORRECT_ID
    jmp getElement_exit

getElement_error_bound:
    mov al, ERR_OUT_OF_BOUNDS
    jmp getElement_exit

getElement_exit:
    pop si
    pop bx
    pop dx
    pop es
    ret
getElement ENDP

checkNumMat PROC
    push SI
    push DI
    push AX
    push BX
    call checkID

    cmp AL, 0
    jne error_incorrect_id

    mov SI, word ptr [descriptors + DI + 1] 

    mov AX, [descriptors + DI].Rows
    mov BX, [descriptors + DI].Columns
    mul BX

loop_for_checking_each_element:
    mov BX, SS:[SI-1]
    shr BX, 7
    and BX, 0FFh 

    cmp BX, 255
    je not_numeric
    dec AX
    cmp AX, 0
    je numeric

    sub SI, 4
    jmp loop_for_checking_each_element
    

not_numeric: 
    mov CL, 01h 
    pop BX
    pop AX
    pop DI
    pop SI
    xor AL, AL
    ret


error_incorrect_id:
    pop BX
    pop AX
    mov AL, ERR_INCORRECT_ID
    pop DI
    pop SI
    ret

numeric:
    mov CL, 0
    pop BX
    pop AX
    pop DI
    pop SI
    xor AL, AL
    ret
checkNumMat ENDP

END