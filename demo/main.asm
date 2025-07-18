; LIB.inc == Consts.inc
.286
INCLUDE LIB.INC
INCLUDELIB LIB.LIB

.model small
.stack 0FFFFh

; Import all library functions and variables
EXTRN matrixInit:PROC
EXTRN newMatrix:PROC
EXTRN freeMatrix:PROC
EXTRN setElement:PROC
EXTRN getElement:PROC
EXTRN writeElem:PROC
EXTRN floatToString:PROC
EXTRN getDim:PROC
EXTRN addMatrix:PROC
EXTRN dotMatrix:PROC
EXTRN mulMatrix:PROC
EXTRN stringToFloat:PROC
EXTRN max_matr:WORD

.stack 0FAFFh

.data
    msg_init_ok     DB "Initialization OK: Max matrices = $"
    msg_step1_ok    DB "Step 1 (b*A + B) OK, ID = $"
    msg_step2_ok    DB "Step 2 ((b*A + B)*C) OK, ID = $"
    msg_result      DB "X elements:", 0Dh, 0Ah, "$"
    msg_prompt_b    DB "Enter scalar b (decimal, e.g., 2.0): $"
    msg_error       DB "Error: Code = $"
    
    newline         DB 0Dh, 0Ah, '$'
    space           DB " $"    
    input_buffer    DB 12h              ; Max length of input
                    DB 0h               ; Actual length (filled by INT 21h)
                    DB 12 DUP(?)        ; Buffer for input string
                    DB '$'
    current_row     DW 0h
    current_column  DW 0h
    current_matrix  DW 0h

    matrixA_id      DW 0h               ; ID for matrix A
    matrixB_id      DW 0h               ; ID for matrix B
    matrixC_id      DW 0h               ; ID for matrix C
    matrix_bA_id    DW 0h               ; ID for matrix b*A
    matrix_bAB_id   DW 0h               ; ID for matrix (b*A + B)
    matrixX_id      DW 0h               ; ID for matrix X
    scalar          DD 0h            

    mA_0_0 db "1.0$", 0h
    mA_0_1 db "2.0$", 0h
    mA_1_0 db "3.0$", 0h
    mA_1_1 db "4.0$", 0h

    mB_0_0 db "5.0$", 0h
    mB_0_1 db "6.0$", 0h
    mB_1_0 db "7.0$", 0h
    mB_1_1 db "8.0$", 0h

    mC_0_0 db "9.0$", 0h
    mC_0_1 db "10.0$", 0h
    mC_1_0 db "11.0$", 0h
    mC_1_1 db "12.0$", 0h

.code
main proc
;   part 1
    mov ax, @data
    mov ds, AX

    mov AX, 400h 
    mov BX, 04h 
    call matrixInit     ;cx - number of initialized matrices

    cmp al, 0
    jne init_failed

    ; Print max_matrices
    mov ah, 09h
    lea dx, msg_init_ok
    int 21h
    mov ax, max_matr
    mov bx, 10
    mov cx, 0
;-------- output the result --------
convert_max:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz convert_max
print_max:
    pop dx
    mov ah, 02h
    int 21h
    loop print_max
    mov dl, 0Ah             ; New line
    mov ah, 02h
    int 21h
;-----------------------------------

;   part 2: creating matrices

    mov ax, 2               ; rows = 2
    mov bx, 2               ; columns = 2
    call newMatrix
    mov matrixA_id, dx      ; Save ID of A
    cmp al, 0
    jne new_failed

    mov ax, 2               ; rows = 2
    mov bx, 2               ; columns = 2
    call newMatrix
    mov matrixB_id, dx      ; Save ID of B
    cmp al, 0
    jne new_failed

    mov ax, 2               ; rows = 2
    mov bx, 2               ; columns = 2
    call newMatrix
    mov matrixC_id, dx      ; Save ID of C
    cmp al, 0
    jne new_failed

;   part 3: Filling in the Matrices with Values
    push ax
    mov ax, ds
    mov es, ax
    pop ax

; -----------MATRIX A---------------
    mov si, offset mA_0_0
    call stringToFloat      ; cx:di 
    mov dx, matrixA_id      ; ID of A
    mov bx, 0               ; row = 0
    mov si, 0               ; col = 0
    call setElement
    cmp al, 0
    jne input_failed

    mov si, offset mA_0_1
    call stringToFloat      ; cx:di 
    mov dx, matrixA_id      ; ID of A
    mov bx, 0               ; row = 0
    mov si, 1               ; col = 1
    call setElement
    cmp al, 0
    jne input_failed

    mov si, offset mA_1_0
    call stringToFloat      ; cx:di 
    mov dx, matrixA_id      ; ID of A
    mov bx, 1               ; row = 1
    mov si, 0               ; col = 0
    call setElement
    cmp al, 0
    jne input_failed

    mov si, offset mA_1_1
    call stringToFloat      ; cx:di 
    mov dx, matrixA_id      ; ID of A
    mov bx, 1               ; row = 1
    mov si, 1               ; col = 1
    call setElement
    cmp al, 0
    jne input_failed

; --------OUTPUT MATRIX-------------
    mov dx, word ptr [matrixA_id]
    call print_matrix

; -----------MATRIX B---------------

    mov si, offset mB_0_0
    call stringToFloat       
    mov dx, matrixB_id  
    mov bx, 0               
    mov si, 0               
    call setElement
    cmp al, 0
    jne input_failed

    mov si, offset mB_0_1
    call stringToFloat     
    mov dx, matrixB_id    
    mov bx, 0               
    mov si, 1             
    call setElement
    cmp al, 0
    jne input_failed

    mov si, offset mB_1_0
    call stringToFloat      
    mov dx, matrixB_id      
    mov bx, 1               
    mov si, 0               
    call setElement
    cmp al, 0
    jne input_failed

    mov si, offset mB_1_1
    call stringToFloat       
    mov dx, matrixB_id      
    mov bx, 1               
    mov si, 1               
    call setElement
    cmp al, 0
    jne input_failed

; --------OUTPUT MATRIX-------------
    mov dx, word ptr [matrixB_id]
    call print_matrix

; -----------MATRIX C---------------

    mov si, offset mC_0_0
    call stringToFloat       
    mov dx, matrixC_id  
    mov bx, 0               
    mov si, 0               
    call setElement
    cmp al, 0
    jne input_failed

    mov si, offset mC_0_1
    call stringToFloat     
    mov dx, matrixC_id    
    mov bx, 0               
    mov si, 1             
    call setElement
    cmp al, 0
    jne input_failed

    mov si, offset mC_1_0
    call stringToFloat      
    mov dx, matrixC_id      
    mov bx, 1               
    mov si, 0               
    call setElement
    cmp al, 0
    jne input_failed

    mov si, offset mC_1_1
    call stringToFloat       
    mov dx, matrixC_id      
    mov bx, 1               
    mov si, 1               
    call setElement
    cmp al, 0
    jne input_failed

; --------OUTPUT MATRIX-------------
    mov dx, word ptr [matrixC_id]
    call print_matrix

; -----------INPUT SCALAR---------------
    mov ah, 09h
    lea dx, msg_prompt_b
    int 21h

    mov ah, 0Ah
    mov dx, offset input_buffer
    int 21h

    mov si, offset input_buffer + 1  
    mov cl, [si]                     
    mov ch, 0
    add si, cx                       
    mov byte ptr [si+1], '$'       
    
    mov ah, 09h
    mov dx, offset newline
    int 21h

    mov ax, ds
    mov es, ax
    mov si, offset input_buffer + 2
    call stringToFloat

    mov word ptr [scalar], di
    mov word ptr [scalar + 2], cx  

; part 4: Scalar multiplication
 
    mov dx, [matrixA_id]
    call dotMatrix
    cmp al, 00h
    jne dot_failed
    mov word ptr [matrix_bA_id], dx

    mov dx, word ptr [matrixA_id]
    call freeMatrix
    cmp al, 00h
    jne free_failed

; --------OUTPUT MATRIX-------------
    mov dx, word ptr [matrix_bA_id]
    call print_matrix

; part 5: Matix addition b*A + B

    mov ax, word ptr [matrix_bA_id]
    mov bx, word ptr [matrixB_id]
    call addMatrix
    cmp al, 00h
    jne add_failed
    mov word ptr [matrix_bAB_id], dx

    mov dx, word ptr [matrix_bA_id]
    call freeMatrix
    cmp al, 00h
    jne free_failed

    mov dx, word ptr [matrixB_id]
    call freeMatrix
    cmp al, 00h
    jne free_failed
; --------OUTPUT MATRIX-------------
    mov dx, word ptr [matrix_bAB_id]
    call print_matrix

; part 6: Matix multiplication (b*A + B)*C

    mov ax, word ptr [matrix_bAB_id]
    mov bx, word ptr [matrixC_id]
    call mulMatrix
    cmp al, 00h
    jne mul_failed

    mov word ptr [matrixX_id], dx

    mov dx, word ptr [matrix_bAB_id]
    call freeMatrix
    cmp al, 00h
    jne free_failed

    mov dx, word ptr [matrixC_id]
    call freeMatrix
    cmp al, 00h
    jne free_failed

; --------OUTPUT MATRIX-------------
    mov dx, word ptr [matrixX_id]
    call print_matrix

    jmp exit
; support functions
init_failed:
    mov ah, 09h
    lea dx, msg_error
    int 21h
    mov al, al              ; Error code
    mov bl, 10
    xor ah, ah
    mov cx, 0
convert_err:
    xor dx, dx
    div bl
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz convert_err
print_err:
    pop dx
    mov ah, 02h
    int 21h
    loop print_err
    mov dl, 0Ah
    mov ah, 02h
    int 21h
    jmp exit


input_failed:
    mov ah, 09h
    lea dx, msg_error
    int 21h
    mov al, al              ; Error code
    mov bl, 10
    xor ah, ah
    mov cx, 0
convert_input:
    xor dx, dx
    div bl
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz convert_input
print_input:
    pop dx
    mov ah, 02h
    int 21h
    loop print_input
    mov dl, 0Ah
    mov ah, 02h
    int 21h
    jmp exit


dot_failed:
    mov ah, 09h
    lea dx, msg_error
    int 21h
    mov al, al              ; Error code
    mov bl, 10
    xor ah, ah
    mov cx, 0
convert_dot:
    xor dx, dx
    div bl
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz convert_dot
print_dot:
    pop dx
    mov ah, 02h
    int 21h
    loop print_dot
    mov dl, 0Ah
    mov ah, 02h
    int 21h
    jmp exit


free_failed:
    mov ah, 09h
    lea dx, msg_error
    int 21h
    mov al, al              ; Error code
    mov bl, 10
    xor ah, ah
    mov cx, 0
convert_free:
    xor dx, dx
    div bl
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz convert_free
print_free:
    pop dx
    mov ah, 02h
    int 21h
    loop print_free
    mov dl, 0Ah
    mov ah, 02h
    int 21h
    jmp exit


new_failed:
    mov ah, 09h
    lea dx, msg_error
    int 21h
    mov al, al              ; Error code
    mov bl, 10
    xor ah, ah
    mov cx, 0
convert_new:
    xor dx, dx
    div bl
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz convert_new
print_new:
    pop dx
    mov ah, 02h
    int 21h
    loop print_new
    mov dl, 0Ah
    mov ah, 02h
    int 21h
    jmp exit


add_failed:
    mov ah, 09h
    lea dx, msg_error
    int 21h
    mov al, al              ; Error code
    mov bl, 10
    xor ah, ah
    mov cx, 0
convert_add:
    xor dx, dx
    div bl
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz convert_add
print_add:
    pop dx
    mov ah, 02h
    int 21h
    loop print_add
    mov dl, 0Ah
    mov ah, 02h
    int 21h
    jmp exit


mul_failed:
    mov ah, 09h
    lea dx, msg_error
    int 21h
    mov al, al              ; Error code
    mov bl, 10
    xor ah, ah
    mov cx, 0
convert_mul:
    xor dx, dx
    div bl
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz convert_mul
print_mul:
    pop dx
    mov ah, 02h
    int 21h
    loop print_mul
    mov dl, 0Ah
    mov ah, 02h
    int 21h
    jmp exit



exit:
    mov ax, 4C00h
    int 21h

main ENDP

print_matrix PROC
    ;dx - ID
    mov word ptr[current_matrix], dx
    mov word ptr[current_column], 00h
    mov word ptr[current_row], 00h
    push ax
    push bx
    push cx
    push si
    call getDim

    mov cx, bx
row_cycle:
    push cx
    mov cx, si      ; количество columns
columns_cycle:
    push cx
    push dx
    push bx
    push si
    push di

    mov dx, word ptr [current_matrix]
    mov bx, word ptr [current_row]
    mov si, word ptr [current_column]
    call getElement                     ; returns in cx:di

    call floatToString                  ; returns es:si with reference

    push ax
    push ds
    mov ax, es
    mov ds, ax
    mov dx, si

    xor ax, ax
    mov ah, 09h
    int 21h                             ; output the element

    pop ds      
    mov dx, offset space                
    int 21h                             ; output the space

    pop ax                              
    pop di
    pop si
    pop bx
    pop dx
    pop cx
    inc word ptr [current_column]
    loop columns_cycle
    pop cx    

    push ax
    mov ax, 0900h
    mov dx, offset newline                
    int 21h                             ; output new line   

    xor ax, ax
    mov word ptr [current_column], ax
    pop ax

    
    inc word ptr [current_row]
    loop row_cycle

    push ax
    xor ax, ax
    mov word ptr [current_row], ax
    mov ax, 0900h
    mov dx, offset newline                
    int 21h                             ; output new line  
    pop ax

    pop si
    pop cx
    pop bx
    pop ax
    ret

print_matrix ENDP

END main