# Demonstration of the Matrix Library

This demonstration illustrates how to use the matrix library, written in MASM for DOS, to solve the matrix equation (b * A + B) * C = X, where b is a scalar constant, and A, B, and C are matrices.

## Example Equation
Consider the equation (b * A + B) * C = X, where:
- b = 2
- A = [ [1, 2], [3, 4] ]
- B = [ [5, 6], [7, 8] ]
- C = [ [9, 10], [11, 12] ]

The result will be the matrix X, which we will compute.

## Solution Steps
0. Users functions (briefly)
1. Initialize the library
2. Create matrices A, B, C, and intermediate matrices
3. Fill in the matrices with the values
4. Compute b * A
5. Perform the addition b * A + B
6. Multiply the result by C to obtain X

---

### Detailed Walkthrough

#### 0. Description of users functions
During the description of the work of this library, auxiliary functions will be used, which can be described by the library user at will, **but they are not included in the library**.

- **init_failed**: Reports an error if matrix library initialization fails, prints the error code, and exits.
- **new_failed**: Handles failure to create a new matrix, displays the error code, and exits.
- **dot_failed**: Manages errors during scalar multiplication (dotMatrix), prints the error code, and exits.
- **add_failed**: Reports errors during matrix addition (addMatrix), shows the error code, and exits.
- **mul_failed**: Handles errors in matrix multiplication (matMul), displays the error code, and exits.
- **input_failed**: Manages errors when setting matrix elements (writeElem), prints the error code, and exits.
- **print_failed**: Reports errors when reading matrix elements (readElem) for display, shows the error code, and exits.
- **free_failed**: Handles errors when freeing matrices (freeMatrix), displays the error code, and exits.

#### 1. Initialization

**Code: Declaring library**
```masm
.286
INCLUDE LIB.INC
INCLUDELIB LIB.LIB

.model small
.stack 0FFFFh

; Import all library functions
EXTRN matrixInit:PROC
EXTRN newMatrix:PROC
EXTRN freeMatrix:PROC
EXTRN setElement:PROC
EXTRN getDim:PROC
EXTRN addMatrix:PROC
EXTRN dotMatrix:PROC
EXTRN mulMatrix:PROC
EXTRN stringToFloat:PROC
EXTRN max_matr:WORD

.data
    msg_init_ok     DB "Initialization OK: Max matrices = $"
    msg_step1_ok    DB "Step 1 (b*A + B) OK, ID = $"
    msg_step2_ok    DB "Step 2 ((b*A + B)*C) OK, ID = $"
    msg_result      DB "X elements:", 0Dh, 0Ah, "$"
    msg_prompt_b    DB "Enter scalar b (decimal, e.g., 2.0): $"
    msg_error       DB "Error: Code = $"
    newline db 0Dh, 0Ah, '$'
    input_buffer    DB 12          ; Max length of input
                    DB 0             ; Actual length (filled by INT 21h)
                    DB 12 DUP(?)     ; Buffer for input string
    buffer          DB 10 DUP(?), "$"  ; Buffer for error code conversion
    matrixA_id      DW 0           ; ID for matrix A
    matrixB_id      DW 0           ; ID for matrix B
    matrixC_id      DW 0           ; ID for matrix C
    matrix_bA_id    DW 0           ; ID for matrix b*A
    matrix_bAB_id   DW 0           ; ID for matrix (b*A + B)
    matrixX_id      DW 0           ; ID for matrix X
    scalar          DD 0            

    mA_0_0 db "1.0$", 0
    mA_0_1 db "2.0$", 0
    mA_1_0 db "3.0$", 0
    mA_1_1 db "4.0$", 0

    mB_0_0 db "5.0$", 0
    mB_0_1 db "6.0$", 0
    mB_1_0 db "7.0$", 0
    mB_1_1 db "8.0$", 0

    mC_0_0 db "9.0$", 0
    mC_0_1 db "10.0$", 0
    mC_1_0 db "11.0$", 0
    mC_1_1 db "12.0$", 0

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
```

**Output:**
\>>>  Initialization OK: Max matrices = 100 (max numer of elements)

##### NOTE:
At this stage, a vector of descriptors has been created in memory, which are initialized by default and have `DataPointer` values that describe the position of the matrix in storage.

#### 2. Create matrices A, B, C

```masm
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
```

**Memory:**
Vector of matrix descriptors will be as follows:
| Address   | Value    | Description       | Matrix       |
|-----------|----------|-------------------|--------------|
| DS:012E   | 0x00     |                   |              |
| DS:012D   | 0x02     | **Columns**       | С            |
| ...       | ...      | ...               | ...          |
| DS:011F   | 0x01     | **UsedFlag**      | B            |
| DS:011E   | 0x00     |                   |              |
| DS:011D   | 0x02     | **Columns**       |              |
| DS:011C   | 0x00     |                   |              |
| DS:011B   | 0x02     | **Rows**          |              |
| DS:011A   | 0x1B     |                   |              |
| DS:0119   | 0x02     |                   |              |
| DS:0118   | 0xFB     |                   |              |
| DS:0117   | 0xF4     | **DataPointer**   |              |
| DS:0116   | 0x01     | **UsedFlag**      | A            |


where the **DataPointer** is 4 bytes with the address of the matrix in the data segment of the library, **Rows** is 2 bytes with the number of rows in the matrix, **Columns** is 2 bytes with the number of columns in the matrix.

##### NOTE:
At this stage, the memory in the storage has not yet been cleared, each matrix has simply been assigned its own address in the storage.

### 3. Fill in the Matrices with Values

#### Code
```masm
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

; -----------INPUT SCALAR---------------
    mov ah, 09h
    lea dx, msg_prompt_b
    int 21h

```
**Output:**
\>>> Enter scalar b (decimal, e.g., 2.0):

**Input:**
\<<< 2

#### Code
```masm
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
```


#### Memory
Vector of matrix descriptors will not be changed.

And matrix storage will look like:
| Address   | Value    | Matrix       |
|-----------|----------|--------------|
| 1B02:FBF4 | 0x2F     |              |
| 1B02:FBF3 | 0x80     |              |
| 1B02:FBF2 | 0x00     |              |
| 1B02:FBF1 | 0x00     | A[0,0]       |
| ...       | ...      | ...          |
| 1B02:FBE8 | 0x40     |              |
| 1B02:FBE7 | 0x80     | A[1,1]       |
| ...   | ...  | ...            |
| 1B02:FBCF | 0x41     |              |
| 1B02:FBCE | 0x10     |              |
| 1B02:FBCD | 0x00     |              |
| 1B02:FBCC | 0x00     | C[0,0]       |
|...|...|...|...|
| 1B02:FBC8 | 0x41     |              |
| 1B02:FBC7 | 0x40     |              |
| 1B02:FBC6 | 0x00     |              |
| 1B02:FBC5 | 0x00     | C[1,1]       |
| ...       | ...      | ...          |

#### Data
A=[ [1, 2], [3, 4] ]

B=[ [5, 6], [7, 8] ]

C=[ [9, 10], [11, 12] ]



#### 4. Compute (b*A)

##### Code
```masm
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
```

##### Memory
Vector of matrix descriptors will be as follows:
| Address   | Value    | Description       | Matrix       |
|-----------|----------|-------------------|--------------|
| DS:0137   | 0x00     |                   |              |
| DS:0136   | 0x02     | **Columns**       |              |
| DS:0135   | 0x00     |                   |              |
| DS:0134   | 0x02     | **Rows**          |              |
| DS:0133   | 0x1B     |                   |              |
| DS:0132   | 0x02     |                   |              |
| DS:0131   | 0xFB     |                   |              |
| DS:0130   | 0xC4     | **DataPointer**   |              |
| DS:012F   | 0x01     | **UsedFlag**      | b*A          |
| ...       | ...      | ...               | ...          |
| DS:011A   | 0x1B     |                   |              |
| DS:0119   | 0x02     |                   |              |
| DS:0118   | 0xFB     |                   |              |
| DS:0117   | 0xF4     | **DataPointer**   |              |
| DS:0116   | 0x00     | **UsedFlag**      | A            |


And matrix storage will look like:
| Address   | Value    | Matrix       |
|-----------|----------|--------------|
| 1B02:FBF4 | 0x2F     |              |
| 1B02:FBF3 | 0x80     |              |
| 1B02:FBF2 | 0x00     |              |
| 1B02:FBF1 | 0x00     | A[0,0]       |
| ...       | ...      | ...          |
| 1B02:FBE8 | 0x40     |              |
| 1B02:FBE7 | 0x80     | A[1,1]       |
| ...   | ...  | ...            |
| 1B02:FBC8 | 0x40     |              |
| 1B02:FBC7 | 0x00     |              |
| 1B02:FBC6 | 0x00     |              |
| 1B02:FBC5 | 0x00     | b*A[0,0]     |
|...|...|...|...|
| 1B02:FBB8 | 0x41     |              |
| 1B02:FBB7 | 0x00     |              |
| 1B02:FBB6 | 0x00     |              |
| 1B02:FBB5 | 0x00     | b*A[1,1]     |
| ...       | ...      | ...          |

##### Data:
b*A = 2 * [ [1, 2], [3, 4] ] = [ [2, 4], [6, 8] ]

#### NOTE:
A new matrix (b*A) was initialized with the corresponding descriptor.

#### 5. Perform the Addition (b*A + B)

##### Code
```masm
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
```

##### Memory
Vector of matrix descriptors will be as follows:
| Address   | Value    | Description       | Matrix       |
|-----------|----------|-------------------|--------------|
| ...       | ...      | ...               | ...          |
| DS:011A   | 0x1B     |                   |              |
| DS:0119   | 0x02     |                   |              |
| DS:0118   | 0xFB     |                   |              |
| DS:0117   | 0xF4     | **DataPointer**   |              |
| DS:0116   | 0x00     | **UsedFlag**      | b*A+B        |


And matrix storage will look like:
| Address   | Value    | Matrix       |
|-----------|----------|--------------|
| 1B02:FBF4 | 0x40     |              |
| 1B02:FBF3 | 0xE0     |              |
| 1B02:FBF2 | 0x00     |              |
| 1B02:FBF1 | 0x00     | b*A+B[0,0]   |
| ...       | ...      | ...          |
| 1B02:FBE8 | 0x41     |              |
| 1B02:FBE7 | 0x20     | b*A+B[1,1]   |
| ...   | ...  | ...             |

##### Data:
b * A + B = [ [2, 4], [6, 8] ] + [ [5, 6], [7, 8] ] = [ [7, 10], [13, 16] ]

#### NOTE:
Matrix b*a+B was placed in the place of matrix A because we had previously deleted that matrix.

#### 6. Multiply the Result by C to Obtain X

##### Code
```masm
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

    jmp exit
```

##### Memory
Vector of matrix descriptors will be as follows:
| Address   | Value    | Description       | Matrix       |
|-----------|----------|-------------------|--------------|
| ...       | ...      | ...               | ...          |
| DS:011A   | 0x1B     |                   |              |
| DS:0119   | 0x02     |                   |              |
| DS:0118   | 0xFB     |                   |              |
| DS:0117   | 0xE4     | **DataPointer**   |              |
| DS:011D   | 0x01     | **UsedFlag**      | (b*A+B)*С    |
|...|...|...|..|


And matrix storage will look like:
| Address   | Value    | Matrix         |
|-----------|----------|----------------|
| 1B02:FBE4 | 0x43     |                |
| 1B02:FBE3 | 0x2D     |                |
| 1B02:FBE2 | 0x00     |                |
| 1B02:FBE1 | 0x00     | (b*A+B)*С[0,0] |
| ...       | ...      | ...            |
| 1B02:FBD8 | 0x43     |                |
| 1B02:FBD7 | 0x1A     |                |
| 1B02:FBD8 | 0x00     |                |
| 1B02:FBD7 | 0x00     | (b*A+B)*С[1,1] |
| ...       | ...      | ...            |

##### Data:
X = (b * A + B) * C = [ [173, 190], [293, 322] ]

##### Note:
Matrix (b*a+B)*C was placed in the place of matrix B because we had previously deleted that matrix.

### Users functions

```masm
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
END main
```