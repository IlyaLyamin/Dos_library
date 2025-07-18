.286
.287
.model small
.stack 0FFFFh

EXTRN matrixInit:near, newMatrix: near, setElement:near,getElement:near, invMatrix:near

.data 
    matrix1_id  dw ?
    matrix2_id  dw ?
    matrix3_id  dw ?
    matrix4_id  dw ?
.code 

main proc
    mov AX, @data
    mov DS, AX

    mov AX, 400h ; user_stack_size 
    mov BX, 64h ; max_elements
    call matrixInit 

;------Test 1: Valid Matrix Inverse
    mov AX, 04h ; rows
    mov BX, 04h ; columns
    call newMatrix
    mov [matrix1_id], DX

    mov BX, 00h ; row
    mov SI, 00h ; column
    mov CX, 40a0h ; 5
    mov DI, 0000h
    call setElement

    mov BX, 00h ; row
    mov SI, 01h ; column
    mov CX, 40c0h ; 6
    mov DI, 0000h
    call setElement

    mov BX, 00h ; row
    mov SI, 02h ; column
    mov CX, 40e0h ; 7
    mov DI, 0000h
    call setElement

    mov BX, 00h ; row
    mov SI, 03h ; column
    mov CX, 4100h ; 8
    mov DI, 0000h
    call setElement

    mov BX, 01h ; row
    mov SI, 00h ; column
    mov CX, 4110h ; 9
    mov DI, 0000h
    call setElement

    mov BX, 01h ; row
    mov SI, 01h ; column
    mov CX, 4000h ; 2
    mov DI, 0000h
    call setElement

    mov BX, 01h ; row
    mov SI, 02h ; column
    mov CX, 4040h ; 3
    mov DI, 0000h
    call setElement

    mov BX, 01h ; row
    mov SI, 03h ; column
    mov CX, 3f80h ; 1
    mov DI, 0000h
    call setElement

    mov BX, 02h ; row
    mov SI, 00h ; column
    mov CX, 4100h ; 8
    mov DI, 0000h
    call setElement

    mov BX, 02h ; row
    mov SI, 01h ; column
    mov CX, 4040h ; 3
    mov DI, 0000h
    call setElement

    mov BX, 02h ; row
    mov SI, 02h ; column
    mov CX, 40c0h ; 6
    mov DI, 0000h
    call setElement

    mov BX, 02h ; row
    mov SI, 03h ; column
    mov CX, 4100h ; 8
    mov DI, 0000h
    call setElement

    mov BX, 03h ; row
    mov SI, 00h ; column
    mov CX, 4040h ; 3
    mov DI, 0000h
    call setElement

    mov BX, 03h ; row
    mov SI, 01h ; column
    mov CX, 4040h ; 3
    mov DI, 0000h
    call setElement

    mov BX, 03h ; row
    mov SI, 02h ; column
    mov CX, 4000h ; 2
    mov DI, 0000h
    call setElement

    mov BX, 03h ; row
    mov SI, 03h ; column
    mov CX, 0000h ; 0
    mov DI, 0000h
    call setElement

;   [5, 6, 7, 8]
;   [9, 2, 3, 1]
;   [8, 3, 6, 8]
;   [3, 3, 2, 0]

    mov DX, [matrix1_id]
    call invMatrix
    mov [matrix2_id], DX

    cmp AL, 0
    jne error_1

    mov DX, [matrix2_id]
    mov BX, 00h ; row
    mov SI, 00h ; column
    call getElement ; BFEE EF06 = -1.86
    cmp CX, 0BFEEh
    jne error_1
    cmp DI, 0EF06h
    jne error_1


    mov BX, 00h ; row
    mov SI, 01h ; column
    call getElement ; BFCC CCE3 = -1.6
    cmp CX, 0BFCCh
    jne error_1
    cmp DI, 0CCE3h
    jne error_1


    mov BX, 00h ; row
    mov SI, 02h ; column
    call getElement ; 4004 4452 = 2.06
    cmp CX, 4004h
    jne error_1
    cmp DI, 4452h
    jne error_1


    mov BX, 00h ; row
    mov SI, 03h ; column
    call getElement ; 402E EF02 = 2.73
    cmp CX, 402Eh
    jne error_1
    cmp DI, 0EF02h
    jne error_1


    mov BX, 01h ; row
    mov SI, 00h ; column
    call getElement ; C09D DDEC = -4.93
    cmp CX, 0C09Dh
    jne error_1
    cmp DI, 0DDECh
    jne error_1


    mov BX, 01h ; row
    mov SI, 01h ; column
    call getElement ; C099 99A7 = -4.8
    cmp CX, 0C099h
    jne error_1
    cmp DI, 99A7h
    jne error_1


    mov BX, 01h ; row
    mov SI, 02h ; column
    call getElement ; 40B1 1121 = 5.53
    cmp CX, 40B1h
    jne error_1
    cmp DI, 1121h
    jne error_1


    mov BX, 01h ; row
    mov SI, 03h ; column
    call getElement ; 40FB BBD3 = 7.86
    cmp CX, 40FBh
    jne error_1
    cmp DI, 0BBD3h
    jne error_1


    mov BX, 02h ; row
    mov SI, 00h ; column
    call getElement ; 4123 3342 = 10.2
    cmp CX, 4123h
    jne error_1
    cmp DI, 3342h
    jne error_1


    mov BX, 02h ; row
    mov SI, 01h ; column
    call getElement ; 4119 99A8 = 9.6
    cmp CX, 4119h
    jne error_1
    cmp DI, 99A8h
    jne error_1


    mov BX, 02h ; row
    mov SI, 02h ; column
    call getElement ; C136 6677 = -11.4
    cmp CX, 0C136h
    jne error_1
    cmp DI, 6677h
    jne error_1


    mov BX, 02h ; row
    mov SI, 03h ; column
    call getElement ; C176 667F = -15.4
    cmp CX, 0C176h
    jne error_1
    cmp DI, 667Fh
    jne error_1


    mov BX, 03h ; row
    mov SI, 00h ; column
    call getElement ; C07B BBD0 = -3.93
    cmp CX, 0C07Bh
    jne error_1
    cmp DI, 0BBD0h
    jne error_1


    mov BX, 03h ; row
    mov SI, 01h ; column
    call getElement ; C073 3347 = -3.8
    cmp CX, 0C073h
    jne error_1
    cmp DI, 3347h
    jne error_1


    mov BX, 03h ; row
    mov SI, 02h ; column
    call getElement ; 4091 111D = 4.53
    cmp CX, 4091h
    jne error_1
    cmp DI, 111Dh
    jne error_1


    mov BX, 03h ; row
    mov SI, 03h ; column
    call getElement ; 40BB BBCD = 5.86
    cmp CX, 40BBh
    jne error_1
    cmp DI, 0BBCDh
    jne error_1


    jmp test2

;------Test 2: Singular Matrix
test2:
    mov AX, 02h ; rows
    mov BX, 02h ; columns
    call newMatrix
    mov [matrix3_id], DX

    mov BX, 00h ; row
    mov SI, 00h ; column
    mov CX, 3f80h ; 1
    mov DI, 0000h
    call setElement

    mov BX, 00h ; row
    mov SI, 01h ; column
    mov CX, 4000h ; 2
    mov DI, 0000h
    call setElement

    mov BX, 01h ; row
    mov SI, 00h ; column
    mov CX, 4000h ; 2
    mov DI, 0000h
    call setElement

    mov BX, 01h ; row
    mov SI, 01h ; column
    mov CX, 4080h ; 4
    mov DI, 0000h
    call setElement


    mov DX, [matrix3_id]
    call invMatrix

    cmp AL, 8
    jne error_2

    jmp test3

;------Test 3: Non-Square Matrix
test3:
    mov AX, 02h ; rows
    mov BX, 03h ; columns
    call newMatrix
    mov [matrix4_id], DX

    call invMatrix

    cmp AL, 7
    jne error_3

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

end_tests: 
    mov AH, 4Ch
    int 21h

main endp
end main
