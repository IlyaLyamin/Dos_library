# Matrix Library Test Cases

This document provides test cases for the procedures in the  library, designed for MASM and DOS, to ensure correct functionality for matrix operations. Each test case includes a description, inputs, expected outputs, and error conditions, referencing the error codes from the [error codes](proc_and_syntax.md#L<36>).

**All values are calculated to 6 significant decimal numbers.**

-------------

## 1. matrixInit

### Test Case 1.1: Valid Stack Size
- **Description**: Initialize the library with a valid stack size.
- **Inputs**: `AX` = 1024 (bytes), `BX` = 256 (elements)
- **Expected Output**: Carry flag clear (success), `AL` = 0

### Test Case 1.2: Memory Allocation Failure
- **Description**: Attempt to initialize with a stack size exceeding available memory.
- **Inputs**: `AX` = 0xFFFF (excessive size), `BX` = 256 (elements)
- **Expected Output**: Carry flag set, `AL` = 0x01 (`ERR_MEM_ALLOC`)

----

## 2. newMatrix

### Test Case 2.1: Valid Matrix Creation
- **Description**: Create a 2x3 matrix.
- **Inputs**: `AX` = 2 (rows), `BX` = 3 (columns)
- **Expected Output**: `DX` = valid matrix ID, `AL` = 0, `CL` = 0 (numeric). Descriptor should have the following fields: **Used Flag** = 1, **Data Pointer** = Pointer to the storage, **Rows** = 2, **Columns** = 3.

### Test Case 2.2: Invalid Dimensions (Zero Rows)
- **Description**: Attempt to create a matrix with zero rows.
- **Inputs**: `AX` = 0 (rows), `BX` = 3 (columns)
- **Expected Output**: `AL` = 0x03 (`ERR_INVALID_DIMS`), `DX` = 0

### Test Case 2.3: Matrix exceeds maximum supported dimensions
- **Description**: Attempt to create a matrix where $(m \cdot n) \geq$ max_elem_in_mat .
- **Inputs**: max_elem_in_mat = 120, `AX` = 13 (rows), `BX` = 10 (columns)
- **Expected Output**: `AL` = 0x03 (`ERR_INVALID_DIMS`), `DX` = 0

---

## 3. freeMatrix

### Test Case 3.1: Valid Matrix Deletion
- **Description**: Delete an existing matrix.
- **Inputs**: `DX` = valid matrix ID
- **Expected Output**: `AL` = 0. The descriptor should have the **Used Flag** = 1, with all other fields staying the same.

---

## 4. setElement

### Test Case 4.1: Valid Element Update
- **Description**: Set element at [1,1] to 3.14 in a 2x2 matrix.
- **Inputs**: `DX` = valid matrix ID, `BX` = 1 (row), `SI` = 1 (column), `CX:DI` = 3.14
- **Expected Output**: `AL` = 0. In a matrix with an ID of `DX` an [`BX`,`SI`] element equals `0x4048F5C3` (3.14).

### Test Case 4.2: Index Out of Bounds (row)
- **Description**: Attempt to set an element outside matrix bounds.
- **Inputs**: `DX` = valid matrix ID (2x2), `BX` = 3, `SI` = 1, `CX:DI` = 1.0 
- **Expected Output**: `AL` = 0x04 (`ERR_OUT_OF_BOUNDS`)

### Test Case 4.3: Index out of Bounds (column)
- **Description**: Attempt to set an element outside matrix bounds.
- **Inputs**: `DX` = valid matrix ID (2x2), `BX` = 1, `SI` = 3, `CX:DI` = 1.0 
- **Expected Output**: `AL` = 0x04 (`ERR_OUT_OF_BOUNDS`)

---

## 5. getElement

### Test Case 5.1: Valid Element Retrieval
- **Description**: Retrieve element at (1,1) from a 2x2 matrix set to 3.14.
- **Inputs**: `DX` = valid matrix ID, `BX` = 1, `SI` = 1
- **Expected Output**: `CX:DI` = `0x4048F5C3` (3.14), `AL` = 0

### Test Case 5.2: Index Out of Bounds (row)
- **Description**: Attempt to get an element outside matrix bounds.
- **Inputs**: `DX` = valid matrix ID (2x2), `BX` = 3, `SI` = 1
- **Expected Output**: `AL` = 0x04 (`ERR_OUT_OF_BOUNDS`)

### Test Case 5.3: Index Out of Bounds (column)
- **Description**: Attempt to get an element outside matrix bounds.
- **Inputs**: `DX` = valid matrix ID (2x2), `BX` = 1, `SI` = 3
- **Expected Output**: `AL` = 0x04 (`ERR_OUT_OF_BOUNDS`)

---

## 6. getDim

### Test Case 6.1: Valid Matrix Dimensions
- **Description**: Get dimensions of a 2x3 matrix.
- **Inputs**: `DX` = valid matrix ID
- **Expected Output**: `BX` = 2 (rows), `SI` = 3 (columns), `AL` = 0

---

## 7. addMatrix

### Test Case 7.1: Valid Matrix Addition
- **Description**: Add two 2x2 matrices:(`[1, 2], [3, 4]`) + (`[5, 6], [7, 8]`).
- **Inputs**: `AX` = ID of first matrix, `BX` = ID of second matrix
- **Expected Output**: `DX` = ID of result matrix (`[6, 8], [10, 12]`), `AL` = 0. Descriptor of a new matrix should have the following fields: **Used Flag** = 1, **Data Pointer** = Pointer to the storage, **Rows** = 2, **Columns** = 2.

### Test Case 7.2: Dimension Mismatch
- **Description**: Attempt to add a 2x2 matrix and a 2x3 matrix.
- **Inputs**: `AX` = ID of 2x2 matrix, `BX` = ID of 2x3 matrix
- **Expected Output**: `AL` = 0x05 (`ERR_DIM_MISMATCH`)

---

## 8. subMatrix

### Test Case 8.1: Valid Matrix Subtraction
- **Description**: Subtract two 2x2 matrices: (`[5, 6], [7, 8]`) - (`[1, 2], [3, 4]`).
- **Inputs**: `AX` = ID of first matrix, `BX` = ID of second matrix
- **Expected Output**: `DX` = ID of result matrix (`[4, 4], [4, 4]`), `AL` = 0.  Descriptor of a new matrix should have the following fields: **Used Flag** = 1, **Data Pointer** = Pointer to the storage, **Rows** = 2, **Columns** = 2.

### Test Case 8.2: Dimension Mismatch
- **Description**: Attempt to subtract a 2x3 matrix from a 2x2 matrix.
- **Inputs**: `AX` = ID of 2x2 matrix, `BX` = ID of 2x3 matrix
- **Expected Output**: `AL` = 0x05 (`ERR_DIM_MISMATCH`)

---

## 9. mulMatrix

### Test Case 9.1: Valid Matrix Multiplication
- **Description**: Multiply a 2x3 matrix (`[1, 2, 3], [4, 5, 6]`) by a 3x2 matrix (`[7, 8], [9, 10], [11, 12]`).
- **Inputs**: `AX` = ID of first matrix, `BX` = ID of second matrix
- **Expected Output**: `DX` = ID of result matrix (`[58, 64], [139, 154]`), `AL`=0. Descriptor of a new matrix should have the following fields: **Used Flag** = 1, **Data Pointer** = Pointer to the storage, **Rows** = 2, **Columns** = 2.

### Test Case 9.2: Dimension Incompatibility
- **Description**: Attempt to multiply a 2x2 matrix by a 3x2 matrix.
- **Inputs**: `AX` = ID of 2x2 matrix, `BX` = ID of 3x2 matrix
- **Expected Output**: `AL` = 0x06 (`ERR_INCOMPAT_DIMS`)

---

## 10. dotMatrix

### Test Case 10.1: Valid Scalar Multiplication
- **Description**: Multiply a 2x2 matrix (`[1, 2], [3, 4]`) by scalar 2.0.
- **Inputs**: `DX` = matrix ID, `CX:DI` = 2.0 
- **Expected Output**: `DX` = ID of result matrix (`[2, 4], [6, 8]`), `AL` = 0.  Descriptor of a new matrix should have the following fields: **Used Flag** = 1, **Data Pointer** = Pointer to the storage, **Rows** = 2, **Columns** = 2.

---

## 11. degMatrix

### Test Case 11.1: Valid Matrix Power
- **Description**: Raise a 2x2 matrix (`[1, 2], [3, 4]`) to power 2.
- **Inputs**: `AX` = matrix ID, `BX` = 2
- **Expected Output**: `DX` = ID of result matrix (`[7, 10], [15, 22]`), `AL` = 0.  Descriptor of a new matrix should have the following fields: **Used Flag** = 1, **Data Pointer** = Pointer to the storage, **Rows** = 2, **Columns** = 2.

### Test Case 11.2: Non-Square Matrix
- **Description**: Attempt to raise a 2x3 matrix to a power.
- **Inputs**: `AX` = ID of 2x3 matrix, `BX` = 2
- **Expected Output**: `AL` = 0x07 (`ERR_NON_SQUARE`)

### Test Case 11.3: Zero Exponent
- **Description**: Raise a 2x2 matrix to power 0 (should return identity matrix).
- **Inputs**: `AX` = matrix ID, `BX` = 0
- **Expected Output**: `DX` = ID of 2x2 identity matrix, `AL` = 0.  Descriptor of a new matrix should have the following fields: **Used Flag** = 1, **Data Pointer** = Pointer to the storage, **Rows** = 2, **Columns** = 2.

---

## 12. detMatrix

### Test Case 12.1: Valid Determinant (1x1)
- **Description**: Compute determinant of (`[2]`).
- **Inputs**: `DX` = matrix ID
- **Expected Output**: `CX:DI` = `40000000` (2.0) , `AL` = 0

### Test Case 12.2: Valid Determinant (4x4)
- **Description**: Compute determinant of (`[5, 6, 7, 8], [9, 2, 3, 1], [8, 3, 6, 8], [3, 3, 2, 0]`).
- **Inputs**: `DX` = matrix ID
- **Expected Output**: `CX:DI` ≈ `C1700000` (-15.0), `AL` = 0

### Test Case 12.3: Non-Square Matrix
- **Description**: Attempt to compute determinant of a 2x3 matrix.
- **Inputs**: `DX` = ID of 2x3 matrix
- **Expected Output**: `AL` = 0x07 (`ERR_NON_SQUARE`)

---

## 13. negMatrix

### Test Case 13.1: Valid Negative Matrix
- **Description**: Compute negative of (`[1, 2], [3, 4]`).
- **Inputs**: `DX` = matrix ID
- **Expected Output**: `DX` = ID of result matrix (`[-1, -2], [-3, -4]`), `AL` = 0.  Descriptor of a new matrix should have the following fields: **Used Flag** = 1, **Data Pointer** = Pointer to the storage, **Rows** = 2, **Columns** = 2.

---

## 14. transpMatrix

### Test Case 14.1: Valid Transpose
- **Description**: Transpose a 2x3 matrix (`[1, 2, 3], [4, 5, 6]`).
- **Inputs**: `DX` = matrix ID
- **Expected Output**: `DX` = ID of result matrix (`[1, 4], [2, 5], [3, 6]`), `AL` = 0.  Descriptor of a new matrix should have the following fields: **Used Flag** = 1, **Data Pointer** = Pointer to the storage, **Rows** = 3, **Columns** = 2.

---

## 15. invMatrix

### Test Case 15.1: Valid Matrix Inverse
- **Description**: Compute inverse of (`[5, 6, 7, 8], [9, 2, 3, 1], [8, 3, 6, 8], [3, 3, 2, 0]`) (determinant ≠ 0).
- **Inputs**: `DX` = matrix ID
- **Expected Output**: `DX` = ID of result matrix (`[-1.87, -1.6, 2.07, 2.73], [-4.93, -4.8, 5.53, 7.87], [10.2, 9.6, -11.4, -15.4], [-3.93, -3.8, 4.53, 5.87]`), `AL` = 0.  Descriptor of a new matrix should have the following fields: **Used Flag** = 1, **Data Pointer** = Pointer to the storage, **Rows** = 4, **Columns** = 4.

### Test Case 15.2: Singular Matrix
- **Description**: Attempt to invert a singular matrix (`[1, 2], [2, 4]`) (determinant = 0).
- **Inputs**: `DX` = matrix ID
- **Expected Output**: `AL` = 0x08 (`ERR_SINGULAR`)

### Test Case 15.3: Non-Square Matrix
- **Description**: Attempt to invert a 2x3 matrix.
- **Inputs**: `DX` = ID of 2x3 matrix
- **Expected Output**: `AL` = 0x07 (`ERR_NON_SQUARE`)

---

## 16. writeElement

### Test Case 16.1: Valid Input
- **Description**: Attempt to write an element with decimal notation into a matrix.
- **Inputs**: `DX` = valid matrix ID, `AX` = 1, `BX` = 1, `ES:SI` = address of a string `3.14`
- **Expected Output**: `AL` = 0. In a matrix with an ID of `DX` an [`BX`,`SI`] element equals `0x4048F5C3`.

---

## 17. readElement

### Test Case 17.1: Valid Number
- **Description**: Attempt to read an element from a matrix and convert it into decimal notation.
- **Inputs**: `DX` = valid matrix ID, `AX` = 1, `BX` = 1, an elements equals `0x4048F5C3`
- **Expected Output**: `AL` = 0, a string `3.14` is stored at `ES:SI`.

---

## 18. stringToFloat (Internal)

### Test Case 18.1: Valid Decimal String
- **Description**: Convert `3.14` to IEEE754 float.
- **Inputs**: `ES:SI` = address of string `3.14`
- **Expected Output**: `CX:DI` = `0x4048F5C3` , `AL` = 0

### Test Case 18.2: Invalid String Format (Non-Numeric Characters)
- **Description**: Convert a string with non-numeric characters.
- **Inputs**: `ES:SI` = address of string `12.3a`
- **Expected Output**: `AL` = 0x0A (`ERR_STR_CONV`)

### Test Case 18.3: Invalid String Format (Whitespace String)
- **Description**: Convert a string with no characters.
- **Inputs**: `ES:SI` = address of string ` `
- **Expected Output**: `AL` = 0x0A (`ERR_STR_CONV`)

### Test Case 18.3: Invalid String Format (Multiple Decimal Points)
- **Description**: Convert a string with more than one decimal point.
- **Inputs**: `ES:SI` = address of string `12.3.4`
- **Expected Output**: `AL` = 0x0A (`ERR_STR_CONV`)

---

## 19. floatToString (Internal)

### Test Case 19.1: Valid Float Conversion
- **Description**: Convert 3.14  to string.
- **Inputs**: `CX:DI` = 3.14 (`0x4048F5C3`)
- **Expected Output**: `ES:SI` = address of string `3.14`, `AL` = 0

### Test Case 19.2: Valid Float Conversion (Not a Number)
- **Description**: Convert a NaN.
- **Inputs**: `CX:DI` = NaN (`0x7FC00000`)
- **Expected Output**: `ES:SI` = adders of string `NaN`, `AL` = 0

### Test Case 19.3: Valid Float Conversion ($+ \infty$)
- **Description**: Convert a positive infinity.
- **Inputs**: `CX:DI` = $+ \infty$ (`0x7F800000`)
- **Expected Output**: `ES:SI` = adders of string `+inf`, `AL` = 0

### Test Case 19.4: Valid Float Conversion ($- \infty$)
- **Description**: Convert a negative infinity.
- **Inputs**: `CX:DI` = $- \infty$ (`0xFF800000`)
- **Expected Output**: `ES:SI` = adders of string `-inf`, `AL` = 0

---

## 20. checkID

### Test Case 20.1: Valid Matrix ID
- **Description**: Validate a matrix ID that refers to an existing matrix.
- **Inputs**: `DX` = valid matrix ID  
- **Expected Output**: `DI` - correct offset of a decriptor, `AL` = 0 (success)

### Test Case 20.2: Invalid Matrix ID
- **Description**: Validate a matrix ID that is not currently in use.
- **Inputs**: `DX` = invalid or freed matrix ID  
- **Expected Output**: `AL` = 0x09 (`ERR_INCORERECT_ID`)

---

## 21. checkNumMat

### Test Case 21.1: All Elements Are Numeric
- **Description**: Check a matrix where all elements are valid numeric values (not NaN, not +∞, and not −∞).
- **Inputs**: `DX` = ID of matrix with all valid float values  
- **Expected Output**: `CL` = 0x00 (numeric), `AL` = 0

### Test Case 21.2: Contains Non-Numeric Element (NaN)
- **Description**: Check a matrix that contains at least one NaN value.
- **Inputs**: `DX` = ID of matrix with one or more NaN elements  
- **Expected Output**: `CL` = 0x01 (not numeric), `AL` = 0

### Test Case 21.3: Invalid Matrix ID
- **Description**: Check a matrix ID that is invalid or not in use.
- **Inputs**: `DX` = invalid matrix ID  
- **Expected Output**: `AL` = 0x09 (`ERR_INCORERECT_ID`)
