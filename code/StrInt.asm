.286
.287
INCLUDE LIB.INC
.model small

EXTRN setElement:near, getDim:near, getElement:near

PUBLIC stringToFloat, writeElem, floatToString, buffer_output, readElem

;consts for floatToString
MASK_EXP    equ 7F80h
MASK_MANT   equ 007Fh
SIGN_BIT    equ 8000h

.data 
    ; for decimal notation
    point_flag      db  0h              ; 1 - to integer 
    sign_flag       db  1h              ; 0 - -, 1 - +
    integer_len     dw  0h
    fractial_len    dw  0h
    int_str         db  08h dup(?)
    frac_str        db  08h dup(?)

    term_buffer     dd  ?               ; for Terms       
    temp_word       dw  ?               ; для временного слова
    original_cw     dw  ?               ; для сохранения исходного управляющего слова FPU
    
    ; for scientific notation
    float_ten       dd  10.0
    len_mant        db  0h
    max_len_mant    db  08h
    result          dd ? 

    ;for writeElem
    matrix_id       dw ? 
    row             dw ?
    col             dw ?
    offst          dw ?
    ;for floatToString
    buffer_output   db 12 DUP (0)
    temp_float  dd  ?
    sign_char   db  ?
    digit       dw  ?
    exp_high    dw 4120h
    one_high    dw 3F80h
.code

;//////////////////////////////////////////////////////////////////////////////
floatToString proc near
  push ax 
  push bx 
  push cx 
  push dx 
  push si 
  push di 
  push bp
  push    cx
  mov     word ptr [temp_float], di
  mov     word ptr [temp_float+2], cx
  mov     ax, cx
  and     ax, MASK_EXP
  cmp     ax, 0
  jne     notZero

  mov     ax, cx
  and     ax, MASK_MANT
  or      ax, di
  jz      zero

notZero:
  cmp     ax, MASK_EXP
  jne     normalNumber
  mov     ax, cx
  and     ax, MASK_MANT
  or      ax, di
  jz      isInfinity
  mov     di, si
  mov     byte ptr [di], 'N'
  mov     byte ptr [di+1], 'a'
  mov     byte ptr [di+2], 'n'
  mov     byte ptr [di+3], '$'
  jmp     done

isInfinity:
  test    cx, SIGN_BIT
  jz      posInf
  mov     di, si
  mov     byte ptr [di], '-'
  mov     byte ptr [di+1], 'I'
  mov     byte ptr [di+2], 'n'
  mov     byte ptr [di+3], 'f'
  mov     byte ptr [di+4], '$'
  jmp     done 
  
posInf:
  mov     di, si
  mov     byte ptr [di], '+'
  mov     byte ptr [di+1], 'I'
  mov     byte ptr [di+2], 'n'
  mov     byte ptr [di+3], 'f'
  mov     byte ptr [di+4], '$'
  jmp     done

zero:
  mov     di, si
  mov     byte ptr [di], '0'
  mov     byte ptr [di+1], '$'
  jmp     done
normalNumber:
  test    cx, SIGN_BIT
  jz      posNumber
  mov     byte ptr [sign_char], '-'
  jmp     loadAbs
posNumber:
  mov     byte ptr [sign_char], '+'
loadAbs:
  FLD     dword ptr [temp_float]
  FABS
  xor     cx, cx
normHi:
  FST     dword ptr [temp_float]
  mov     bx, word ptr [temp_float+2]
  cmp     bx, 4120h
  jb      normLo
  FDIV    dword ptr [float_ten]
  inc     cx
  jmp     normHi
normLo:
  cmp     bx, 3F80h
  jae     afterNorm
  FMUL    dword ptr [float_ten]
  dec     cx
  FST     dword ptr [temp_float]
  mov     bx, word ptr [temp_float+2]
  jmp     normLo

afterNorm:
  mov     di, si
  mov     al, [sign_char]
  mov     byte ptr [di], al
  inc     di

  FSTCW   word ptr [original_cw]
  mov     ax, [original_cw]
  and     ax, not (3 shl 10)    
  or      ax, (1 shl 10)       
  mov     [temp_word], ax
  FLDCW   word ptr [temp_word]

  FLD     ST(0)           
  FRNDINT               
  FIST    word ptr [digit]     
  FSUBP   ST(1), ST(0)         

  FLDCW   word ptr [original_cw]

  mov     ax, [digit]
  add     al, '0'
  mov     byte ptr [di], al
  inc     di
  mov     byte ptr [di], '.'
  inc     di
  FLD     dword ptr [temp_float]
  FABS
  FILD    word ptr [digit]
  FSUBR   ST(0), ST(1)
  FSTP    ST(1)
  mov     dx, 6

fracLoop:
  FMUL  dword ptr [float_ten]
  FLD   ST(0)
  FRNDINT
  FISTP word ptr [digit]
  FILD  word ptr [digit]
  FSUBP ST(1), ST(0)
  mov   ax, [digit]
  add   al, '0'
  mov   byte ptr [di], al
  inc   di
  dec   dx
  jnz   fracLoop
  FSTP    ST(0)
  mov     byte ptr [di], 'e'
  inc     di
  cmp     cx, 0
  jge     expPositive
  mov     byte ptr [di], '-'
  neg     cx
  jmp     expSignDone
expPositive:
  mov     byte ptr [di], '+'
expSignDone:
  inc     di
  mov     ax, cx
  xor     dx, dx
  mov     bx, 10
  div     bx
  add     al, '0'
  mov     byte ptr [di], al
  inc     di
  add     dl, '0'
  mov     byte ptr [di], dl
  inc     di
  mov     byte ptr [di], '$'

done:
  FINIT
  pop     cx
  pop     bp
  pop di 
  pop si 
  pop dx 
  pop cx 
  pop bx 
  pop ax
  ret
floatToString ENDP

stringToFloat proc;<<<<<<<<<<<<<<<<<<<<<<<<<
    ;es:si  - address of input
    push bx
    push dx
    push es
    push si

    call search_e               ; 1 - scientific, 2 - decimal

    cmp al, 01h
    je pars_scientific

pars_decimal:

    call strToDecCon            ; set all for decimal notation and validate
    cmp al, 0Ah
    je end_prog

    call calculateDec           
    ; clean memory
    mov cx, word ptr [result + 2]
    mov di, word ptr [result]

    mov bx, 0h
    mov word ptr [result], bx
    mov word ptr [result + 2], bx
    mov [point_flag], bl
    inc bl 
    mov [sign_flag], bl
    dec bl
    mov word ptr [integer_len], bx
    mov word ptr [fractial_len], bx

    push cx
    push di

    mov cx, 8          
    xor ax, ax         
    lea di, int_str    
    rep stosb    

    mov cx, 8          
    lea di, frac_str    
    rep stosb

    pop di
    pop cx         

    mov word ptr [term_buffer], bx
    mov word ptr [term_buffer + 2], bx
    mov word ptr [temp_word], bx    

pars_scientific:


end_prog:
    pop si
    pop es 
    pop dx 
    pop bx
    ret

stringToFloat endp;<<<<<<<<<<<<<<<<<<<<<<<<<


strToDecCon PROC;<<<<<<<<<<<<<<<<<<<<<<<<<
    push di
    cld
cycle:
    xor ax, ax
    lodsb

    cmp al, '.'
    jne not_change_flag
    add [point_flag], 01h
    cmp [point_flag], 02h
    jge error_conversial
    jmp cycle

    not_change_flag:

    cmp al, '$'
    je end_sprog

    call checkNum                   ; REURNS ERROR IN AH
    cmp ah, ERR_STR_CONV
    jne add_char

    cmp [int_str], 0h
    jne error_conversial 
    cmp al, '-'
    je set_min
    cmp al, '+'
    jne error_conversial
    jmp cycle

add_char:
    cmp [point_flag], 0h
    je to_int
    cmp [point_flag], 01h
    je to_frac
    jmp error_conversial

to_int:
    mov di, word ptr [integer_len]
    mov byte ptr [int_str + di], al 
    inc word ptr [integer_len]
    jmp cycle

to_frac:
    mov di, word ptr [fractial_len]
    mov [frac_str + di], al 
    inc word ptr [fractial_len]
    jmp cycle

set_min:
    mov [sign_flag], 0
    jmp cycle

error_conversial:
    pop di
    mov al, 0Ah
    ret

end_sprog:
    pop di
    ret

strToDecCon ENDP;<<<<<<<<<<<<<<<<<<<<<<<<<


checkNum PROC;<<<<<<<<<<<<<<<<<<<<<<<<<
    cmp al, '0'
    jl not_num

    cmp al, '9'
    jg not_num

    ret

not_num:
    mov ah, ERR_STR_CONV
    ret
checkNum ENDP


search_e PROC;<<<<<<<<<<<<<<<<<<<<<<<<
    push si 
cycle:
    lodsb

    cmp al,'e'
    je ret_e

    cmp al, '$'
    je end_sprog

    jmp cycle

ret_e:
    mov ax, 01h
    pop si
    ret    

end_sprog:
    mov ax, 0h
    pop si
    ret

search_e ENDP ;<<<<<<<<<<<<<<<<<<<<<<<<<

;-------------------------------------------------------

calculateDec PROC ;<<<<<<<<<<<<<<<<<<<<<<<<<
    push cx
    push di
    push ax
    push bx

    FINIT 
    FLDZ
    FSTP dword ptr [result]

    ; Calculate integer part
    mov cx, word ptr [integer_len]
    xor di, di
    mov bx, cx
    dec bx                      

cycle_int:
    cmp cx, 0
    je process_fractial

    mov al, [int_str + di]     
    xor ah, ah                   
    push bx                    
    push ax                      
    call calculateTerm         

    FLD dword ptr [term_buffer]  
    FLD dword ptr [result]       
    FADD                       
    FSTP dword ptr [result]    

    dec bx
    inc di
    dec cx
    jmp cycle_int

process_fractial:
    cmp word ptr [fractial_len], 0
    je apply_sign

    mov cx, word ptr [fractial_len]
    xor di, di                   
    mov bx, -1                   

cycle_frac:
    cmp cx, 0
    je apply_sign

    mov al, [frac_str + di]      
    xor ah, ah                   
    push bx                  
    push ax                     
    call calculateTerm           

    FLD dword ptr [term_buffer] 
    FLD dword ptr [result]       
    FADD                         
    FSTP dword ptr [result]      

    dec bx
    inc di
    dec cx
    jmp cycle_frac

apply_sign:
    cmp byte ptr [sign_flag], 0 
    je negative
    FLD dword ptr [result] 
    jmp positive           

negative:
    FCHS                         ; change sign
    FSTP dword ptr [result] 
    pop bx
    pop ax
    pop di
    pop cx
    ret
    
positive:
    pop bx
    pop ax
    pop di
    pop cx
    ret
calculateDec ENDP ;<<<<<<<<<<<<<<<<<<<<<<<<<


calculateTerm PROC ;<<<<<<<<<<<<<<<<<<<<<<<<<
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push di

    
    mov al, [bp + 4]       
    mov bx, [bp + 6]        

    sub al, '0'             
    mov ah, 0               
    mov [temp_word], ax     

    ; (m) in FPU
    mov di, offset temp_word
    fild word ptr [di]      


    cmp bx, 0
    jge positive_power

    neg bx                  ; bx = |(m)|
    mov cx, bx 
    fld1                    ; ST(0) = 1.0, ST(1) = (m)
    fld dword ptr [float_ten] 

cycle_div:
    cmp cx, 0
    je end_cycle_div
    fdiv ST(1), ST(0)
    dec cx
    jmp cycle_div

end_cycle_div:
    fstp st(0)            
    fmulp st(1), st(0)      
    jmp save_result

positive_power:
    
    mov cx, bx              
    fld1                  
    fld dword ptr [float_ten]

cycle_mul:
    cmp cx, 0
    je end_cycle_mul
    fmul ST(1), ST(0)      
    dec cx
    jmp cycle_mul

end_cycle_mul:
    fstp st(0)             
    fmulp st(1), st(0)     

save_result:
    fstp dword ptr [term_buffer] 

    pop di
    pop cx
    pop bx
    pop ax
    pop bp
    ret 4                   
calculateTerm ENDP ;<<<<<<<<<<<<<<<<<<<<<<<<<

writeElem PROC
    mov [matrix_id], dx

    mov [row], ax
    mov [col], bx

    mov [offst], si

    call getDim
    cmp al, ERR_INCORRECT_ID
    je error_ID

    cmp bx, [row]
    jbe error_dim

    cmp si, [col]
    jbe error_dim 

    push cx
    push di 
    mov si, [offst] 

    call stringToFloat 
    cmp al, ERR_STR_CONV 
    je error_string 

    mov dx, [matrix_id]
    mov bx, [row]
    mov si, [col]
    
    call setElement

    xor al, al
    pop di 
    pop cx 
    jmp write_end

error_dim: 
    mov al, ERR_OUT_OF_BOUNDS
    jmp write_end

error_string:
        pop di
        pop cx
        jmp write_end 

error_ID:
    jmp write_end

write_end:
    ret

writeElem ENDP

readElem PROC
    mov [matrix_id], dx

    mov [row], ax
    mov [col], bx

    call getDim
    cmp al, ERR_INCORRECT_ID
    je error_ID

    cmp bx, [row]
    jbe error_dim

    cmp si, [col]
    jbe error_dim 

    mov bx, [row]
    mov si, [col]
    mov dx, [matrix_id]

    call getElement

    mov si, offset buffer_output

    call floatToString

    xor al, al
    jmp read_end


error_ID:
    jmp read_end

error_dim: 
    mov al, ERR_OUT_OF_BOUNDS
    jmp read_end

read_end:
    ret

readElem ENDP

END 