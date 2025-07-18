; MatrixLib.inc - Header file for Matrix Library constants

; Error codes as defined in library_overview.md
ERR_MEM_ALLOC       EQU 01h
ERR_MATRIX_FULL     EQU 02h
ERR_INVALID_DIMS    EQU 03h
ERR_OUT_OF_BOUNDS   EQU 04h
ERR_DIM_MISMATCH    EQU 05h
ERR_INCOMPAT_DIMS   EQU 06h
ERR_NON_SQUARE      EQU 07h
ERR_SINGULAR        EQU 08h
ERR_INCORRECT_ID   EQU 09h
ERR_STR_CONV        EQU 0Ah

; Constants
ELEMENT_SIZE        EQU 4        ; Size of each matrix element (32-bit float)
DESCRIPTOR_SIZE     EQU 9        ; Size of matrix descriptor (1 + 4 + 2 + 2 bytes)

Matrix STRUCT
    UsedFlag    DB  0           ; 1 byte: 0 = free, 1 = used
    DataPointer DD  0           ; 4 bytes: Pointer to matrix data
    Rows        DW  0           ; 2 bytes: Number of rows
    Columns     DW  0           ; 2 bytes: Number of columns
Matrix ENDS