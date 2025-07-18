.286
.287
.model small
.stack 0FFFFh

EXTRN stringToFloat:near

.data 
    str1 db "3.14$", 0
    str2 db "12.3a$", 0
    str3 db " $", 0
    str4 db "12.3.4$", 0

.code 

main proc
    mov AX, @data
    mov DS, AX
    mov ES, AX
    xor CX, CX
    xor DI, DI

    ; Test 1: Valid Decimal String
    mov SI, offset str1
    call stringToFloat
    cmp CX, 4048h
    jne error_1
    cmp DI, 0F5C2h
    jne error_1
    cmp AL, 0
    jne error_1

    ; Test 2: Invalid String Format (Non-Numeric Characters)
    mov SI, offset str2
    call stringToFloat
    cmp AL, 10
    jne error_2

    ; Test 3: Invalid String Format (Whitespace String)
    mov SI, offset str3
    call stringToFloat
    cmp AL, 10
    jne error_3

    ; Test 4: Invalid String Format (Multiple Decimal Points)
    mov SI, offset str4
    call stringToFloat
    cmp AL, 10
    jne error_4

    mov AL, 0
    jmp end_tests

error_1:
    mov AL, 1
    jmp end_tests

error_2:
    mov AL, 2
    jmp end_tests

error_3:
    mov AL, 3
    jmp end_tests

error_4:
    mov AL, 4
    jmp end_tests

end_tests: 
    mov AH, 4Ch
    int 21h

main endp
end main