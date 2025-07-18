# Matrix Library Description

This document outlines a matrix library’s design, including how it stores data, the organization of its source files and functions, and general project information such as notation and naming conventions.

## Notations:
- Variable notation: `snake_case`
- Program naming notation: `camelCase`
- Code file naming notation: `PascalCase`
- Documentation file naming notation: `snake_case`

## Calling convention
- Matrix ids are transferred via one of the following registers: AX, BX, DX.
- Individual matrix elements are transferred via registers: CX:DI (CX - upper 16 bits, DI - lower 16 bits).
- The coordinates of elements in the matrix are passed as BX-row, SI-column.
- The addresses of the string buffers are passed through registers: ES:SI.

## Structures and Their Storage

### Matrix Elements (real numbers):
+ Floating-Point Format was adopted because it is natively supported by the **FPU (Floating-Point Unit)**, which accelerates mathematical operations on such numbers. The FPU supports three main floating-point formats. But we will use only 32-bit [IEEE754](https://en.wikipedia.org/wiki/IEEE_754) floating-point numbers. Based on this **elementSize** is further taken as equal to 4.

### Matrix Descriptor Structure
The library manages matrices using a **matrix descriptor** structure, which holds metadata about each matrix. This structure is stored in memory as a contiguous block and includes the following fields:  
- **Used Flag** (1 byte): Indicates if the matrix slot is occupied (1) or free (0).  
- **Data Pointer** (4 bytes): Points to the memory location where the matrix elements are stored.  
- **Rows** (2 bytes): Unsigned integer that specifies the number of rows in the matrix. Will be described further as R.
- **Columns** (2 bytes): Unsigned integer that specifies the number of columns in the matrix. Will be described further as C.

Each descriptor occupies 9 bytes (1 + 4 + 2 + 2). Multiple descriptors are stored in an array called the **Matrix List**, which supports a predefined maximum number of matrices.

### Matrix Data Storage
Matrix elements are stored separately from the descriptor in a contiguous memory block, referenced by the **Data Pointer**. Each element is taking up 4 bytes. The elements are arranged in **row-major order**:  
- The first row’s elements are stored first, followed by the second row, and so on.  
- For a matrix with R (rows) and C (columns), the element at position *(i, j)* (using 0-based indexing) is located at an offset of *(i × C + j) × **elementSize*** bytes from the **Data Pointer**.  
- Each matrix is ​​allocated a certain number of bytes, defined by the user as the maximum matrix size

## Procedures
All external operations (procedures) must be called with command <code>call procedure_name</code>. Internal procedure cannot be called from outside of the module.  

| Operation | Name of Procedure | Short Description | Data | Result | Errrors |
|:--|:--|:--|:--|:--|:--|
| **Memory Management** |
| Initialize library (external) | `matrixInit` | Initializes the matrix library with a user-defined stack size end maximum matrix size | `AX`-user stack size (bytes), `BX`-maximum elements in matrix| `CX`-number of initialized matrices |[ERR_MATRIX_FULL](#2)|
| Create matrix (external) | `newMatrix` | Allocates memory for a new matrix | `AX`-rows, `BX`-columns | `DX`-matrix ID  |[ERR_MEM_ALLOC](#1) [ERR_MATRIX_FULL](#2) [ERR_INVALID_DIMS](#3)|
| Delete matrix (external) | `freeMatrix` | Free matrix memory | `DX`-matrix ID | (None) |[ERR_INCORERECT_ID](#9)|
| Check matrix ID (external) | `checkID` |   checks that the correct matrix ID is specified, returns offset of a decriptor of the matrix | `DX`-matrix ID | `DI`-offset of a descriptor of a matrix with ID in a decriptor storage |[ERR_INCORERECT_ID](#9)|
| **Element Access (Register-Based)** |
| Set element (external) | `setElement` | Updates a matrix element with a float value |`DX`-matrix ID, `BX`-row, `SI`-column, `CX:DI`-float value | (None) | [ERR_OUT_OF_BOUNDS](#4) [ERR_INCORERECT_ID](#9)|
| Get element (external) | `getElement` | Returns the float value of a matrix element | `DX`-matrix ID, `BX`-row, `SI`-column| `CX:DI`-float value| [ERR_OUT_OF_BOUNDS](#4) [ERR_INCORERECT_ID](#9) |
| **Matrix Properties** |
| Get dimensions (external) | `getDim` | Returns matrix dimensions | `DX`-matrix ID | `BX`-rows, `SI`-columns |  [ERR_INCORERECT_ID](#9) |
| Сheck if matrix is numeric (external)| `checkNumMat` |  Сhecks that all elements in a matrix are numeric | `DX`-matrix ID | `CL`- `00(numeric)` or `01(not numeric)` |[ERR_INCORERECT_ID](#9) |
| **Matrix Operations** |
| Add matrices (external) | `addMatrix` | Element-wise addition of two matrices | `AX`-ID of first matrix, `BX`-ID of second matrix | `DX`-result matrix ID |  [ERR_MATRIX_FULL](#2) [ERR_INCORERECT_ID](#9)   |
| Subtract matrices (external) | `subMatrix` | Element-wise subtraction of two matrices | `AX`-ID of first matrix, `BX`-ID of second matrix | `DX`-result matrix ID |[ERR_MATRIX_FULL](#2)   [ERR_DIM_MISMATCH](#5) [ERR_INCORERECT_ID](#9)  |
| Multiply matrices (external) | `mulMatrix` | Algebraic matrix multiplication | `AX`-ID of first matrix, `BX`-ID of second matrix | `DX`-result matrix ID |[ERR_MATRIX_FULL](#2)   [ERR_INCOMPAT_DIMS](#6) [ERR_INCORERECT_ID](#9)  |
| Scalar multiply (external) | `dotMatrix` | Multiplies matrix elements by a scalar | `DX`-matrix ID, `CX:DI`-scalar value | `DX`-result matrix ID |  [ERR_MATRIX_FULL](#2)   [ERR_DIM_MISMATCH](#5) [ERR_INCORERECT_ID](#9)   |
| Matrix power (external) | `degMatrix` | Raises a square matrix to a power | `AX`-matrix ID, `BX`-exponent | `DX`-result matrix ID |  [ERR_MATRIX_FULL](#2) [ERR_NON_SQUARE](#7)   [ERR_INCORERECT_ID](#9) |
| Determinant (external) | `detMatrix` | Computes the determinant| `DX`-matrix ID | `CX:DI`-determinant value |  [ERR_NON_SQUARE](#7)   [ERR_INCORERECT_ID](#9)  |
| Negative matrix (external) | `negMatrix` | Multiplies matrix by `-1` | `DX`-matrix ID | `DX`-result matrix ID |   [ERR_MATRIX_FULL](#2)  [ERR_INCORERECT_ID](#9)|
| Transpose (external) | `transpMatrix` | Swaps rows and columns | `DX`-matrix ID | `DX`-result matrix ID |   [ERR_MATRIX_FULL](#2) [ERR_INCORERECT_ID](#9)  |
| Invert matrix (external) | `invMatrix` | Computes inverse via adjugate and determinant | `DX`-matrix ID | `DX`-result matrix ID |   [ERR_MATRIX_FULL](#2) [ERR_NON_SQUARE](#7)   [ERR_INCORERECT_ID](#9) [ERR_SINGULAR](#8)|
| **Element Access (String-Based)** |
| Write element (external) | `writeElement` | Parses a string with decimal notation and updates a matrix element |`DX`-matrix ID, `AX`-row, `BX`-column, `ES:SI`-address of input string | (None) | [ERR_OUT_OF_BOUNDS](#4)   [ERR_INCORERECT_ID](#9) [ERR_STR_CONV](#10) |
| Read element (external) | `readElement` | Converts a matrix element to a decimal-notation string |`DX`-matrix ID, `AX`-row, `BX`-column | `ES:SI`-output buffer |[ERR_OUT_OF_BOUNDS](#4)   [ERR_INCORERECT_ID](#9)|
| **Conversion Utilities** |
| String to float (internal) | `stringToFloat` | Converts a string with decimal notation to float value| `ES:SI`-address of input string | `CX:DI`-float value | [ERR_STR_CONV](#10)|
| Float to string (internal) | `floatToString` | Converts float value to string with decimal notation| `CX:DI`-float value | `ES:SI`-output buffer address ||

## Error Codes
After each procedure is executed, the error code value is placed in the register `AL` in accordance with the table, unless specified otherwise.
| Constant| Error Codes | Description |
|:---|:---|:---|
| <a id="1"></a>ERR_MEM_ALLOC | `0x01` | Memory allocation failure |
| <a id="2"></a>ERR_MATRIX_FULL | `0x02` | Matrix allocation failure (there is no free slots) |
| <a id="3"></a>ERR_INVALID_DIMS | `0x03` | Invalid dimensions (rows/columns ≤ 0, rows×columns > maximum elements in matrix) |
| <a id="4"></a>ERR_OUT_OF_BOUNDS | `0x04` | Index out of bounds (set/get) |
| <a id="5"></a>ERR_DIM_MISMATCH | `0x05` | Dimension mismatch (cols₁ ≠ cols₂, rows₁ ≠ rows₂) |
| <a id="6"></a>ERR_INCOMPAT_DIMS | `0x06` | Dimension incompatibility (cols₁ ≠ rows₂) (mul) |
| <a id="7"></a>ERR_NON_SQUARE | `0x07` | Non-square matrix |
| <a id="8"></a>ERR_SINGULAR | `0x08` | Singular matrix (det=0) |
| <a id="9"></a>ERR_INCORERECT_ID | `0x09` | Null matrix reference (id is incorrect) |
| <a id="10"></a>ERR_STR_CONV | `0x0A` | String conversion failure |