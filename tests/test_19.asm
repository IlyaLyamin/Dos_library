.286
.287
.model small
.stack 0FFFFh

EXTRN floatToString:near

.data 
    buffer      db 14 dup (0)
    expected_1   db "+3.140000e+00$"
    expected_2   db "Nan$"
    expected_3   db "+Inf$"
    expected_4   db "-Inf$"

.code 

main proc
    mov ax, @data
    mov ds, ax
    mov es, ax
;------------------------------TEST_1--------------------------------------
    
    mov si, offset buffer
    mov cx, 4048h
    mov di, 0F5C3h
    call floatToString
    
    mov si, offset buffer
    mov di, offset expected_1
    call compareStrings
    jc error_1
    ;------------------------------TEST_2--------------------------------------
    
    mov si, offset buffer
    mov cx, 7FC0h
    mov di, 0000h
    call floatToString
    
    mov si, offset buffer
    mov di, offset expected_2
    call compareStrings
    jc error_2
    ;------------------------------TEST_3--------------------------------------
    
    mov si, offset buffer
    mov cx, 7F80h
    mov di, 0000h
    call floatToString
    
    mov si, offset buffer
    mov di, offset expected_3
    call compareStrings
    jc error_3

    ;------------------------------TEST_4--------------------------------------

    
    mov si, offset buffer
    mov cx, 0FF80h
    mov di, 0000h
    call floatToString
    
    mov si, offset buffer
    mov di, offset expected_4
    call compareStrings
    jc error_4


    mov al, 0
    jmp endTests
;-----------------------------ERRORS---------------------------
error_1:
    mov al, 1
    jmp endTests

error_2:
    mov al, 2
    jmp endTests

error_3:
    mov al, 3
    jmp endTests

error_4:
    mov al, 4
    jmp endTests

endTests: 
    mov ah, 4Ch
    int 21h

compareStrings proc
    push si
    push di
    push ax
compareLoop:
    mov al, [si]
    cmp al, [di]
    jne compareFail
    cmp al, '$'
    je compareEqual
    inc si
    inc di
    jmp compareLoop
compareFail:
    stc
    jmp compareEnd
compareEqual:
    clc
compareEnd:
    pop ax
    pop di
    pop si
    ret
compareStrings endp

main endp
end main