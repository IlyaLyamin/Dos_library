;I just link them together, check using afdpro
.286
.model small
.stack 0FFFFh

EXTRN matrixInit:near

.data 

.code 

main proc
    mov ax, @data
    mov ds, ax
start: ; Test 2: Memory allocation failure
    mov AX, 0FFFFh ; user_stack_size -- excessive
    mov BX, 100h ; max_elements = 100
    call matrixInit 
    jnc error_2 ; CF check, set
    cmp AL, 1 ; Code check -- ERR_MEM_ALLOC
    jne error_2
    jmp test1

test1: ; ordinary case
    mov AX, 400h ; user_stack_size = 1024
    mov BX, 04h ; max_elements = 256
    call matrixInit 
    jc error_1 ; CF check
    cmp AL, 0 ; Code check
    jne error_1 
    cmp CX, 0 ; more than one matrix
    je error_1
    mov AL, 0
    jmp end_tests

error_1:
    mov AL, 1
    jmp end_tests

error_2:
    mov AL, 2
    jmp end_tests

end_tests: 
    mov AH, 4Ch
    int 21h

main endp
end main