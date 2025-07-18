# Matrix Library Algorithms

This document describes the algorithms for matrix operations and management in the matrix library.

## 1. Library Initialization (matrixInit)
1. Input: User-defined stack size (in bytes) and maximum elements in matrix (max_elem_in_mat).
2. Validate stack size:
   - If size exceeds available memory, throw error.
3. Initialize global variables:
   - Set user stack size.
   - Calculate maximum number of matrices based on available memory.
   - Initialize memory pointers in matrix structures.
   - Clear the matrix list (mark all slots as free).
4. Return success or error status.

## 2. Create Matrix (newMatrix)
1. Input: Number of rows $m$, number of columns $n$, maximum elements in matrix $max\_elem\_in\_mat$.
2. Validate dimensions:
   - If $m \leq 0$ or $n \leq 0$, or ($(m * n) \geq max\_elem\_in\_mat$ ) throw error.
3. Find free slot in matrix list:
   - If none available, throw error.
4. Update matrix descriptor:
   - Set used flag to occupied.
   - Store rows ($m$), columns ($n$).
5. Сlears the memory in the slot assigned to the structure.
6. Increment matrix count.
7. Return matrix ID.

## 3. Delete Matrix (freeMatrix)
1. Input: Matrix ID.
2. Validate ID:
   - If ID is invalid or null, throw error.
3. Update matrix descriptor:
   - Clear used flag.
   - Set rows and columns to zero.
4. Decrement matrix count.
5. Return success.

## 4. Set Element (setElement)
1. Input: Matrix ID, row index $i$, column index $j$, 32-bit float value.
2. Validate inputs:
   - If ID is invalid, throw error.
   - If $i \geq \text{rows}$ or $j \geq \text{columns}$, throw error.
3. Compute element location: $(i \cdot \text{columns} + j)$.
4. Store the float at the computed location in the matrix’s data block.
5. Return success or error status.

## 5. Get Element (getElement)
1. Input: Matrix ID, row index $i$, column index $j$.
2. Validate inputs:
   - If ID is invalid, throw error.
   - If $i \geq \text{rows}$ or $j \geq \text{columns}$, throw error.
3. Compute element location: $(i \cdot \text{columns} + j)$.
4. Retrieve the 32-bit float at the computed location.
5. Return the float value.

## 6. Write Element (writeElement)
1. Input: Matrix ID, row index $i$, column index $j$, adress to the buffer (string with decimal notation).
2. Validate inputs:
   - If ID is invalid, throw error.
   - If $i \geq \text{rows}$ or $j \geq \text{columns}$, throw error.
2. Parse string to 32-bit float:
   - If string format is invalid, throw error.
3. Call set element algorithm with matrix ID, $i$, $j$, and parsed float.
4. Return success or error status.

## 7. Read Element (readElement)
1. Input: Matrix ID, row index $i$, column index $j$.
2. Validate inputs:
   - If ID is invalid, throw error.
   - If $i \geq \text{rows}$ or $j \geq \text{columns}$, throw error.
2. Call get element algorithm to retrieve 32-bit float.
3. Convert float to string:
   - If conversion fails, throw error.
4. Store string in output buffer.
5. Return adress of buffer with string, success or error status.

## 8. String to Float (stringToFloat)
1. Input: String with decimal notation.
2. Parse string into components (sign, integer part, fractional part).
3. Convert to 32-bit float:
   - Compute sign bit.
   - Normalize mantissa and calculate exponent.
   - If format is invalid, throw error.
4. Return float value.

## 9. Float to String (floatToString)
1. Input: 32-bit float value.
2. Extract sign, exponent, and mantissa.
3. Convert to decimal notation:
   - Compute sign.
   - Adjust mantissa based on exponent.
   - Format as decimal string.
   - If conversion fails, throw error.
4. Write string to output buffer.
5. Return success or error status.

## 10. Addition (addMatrix)
1. Input: Two IDs of matrices A of dimension m × n and B of dimension m × n.
1. Check dimensions:
   - If rows(A) ≠ rows(B) or cols(A) ≠ cols(B), throw error.
2. Create an empty matrix $C$ of size m × n (size of $A$ and $B$).
3. Element-wise addition: C[i,j] = A[i,j] + B[i,j].
4. Return result matrix.

## 11. Subtraction (subMatrix)
1. Input: Two IDs of matrices $A$ of dimension m × n and $B$ of dimension m × n.
1. Check dimensions:
   - If rows(A) ≠ rows(B) or cols(A) ≠ cols(B), throw error.
2. Create an empty matrix $C$ of size m × n (size of $A$ and $B$).
3. Element-wise subtraction: $C[i,j] = A[i,j] - B[i,j].
4. Return result matrix.

## 12. Multiplication (mulMatrix)
1. Input: Two IDs of matrices $A$ of dimension m × n and $B$ of dimension n × p.
2. Check compatibility: If cols(A) ≠ rows(B), throw error.
3. Initialize: Create an empty matrix $C$ of size m × p.
4. Compute each entry of $C$:
   - For each $i = 1$ to $m$:
     - For each $j = 1$ to $p$:
       - Set sum = 0.
       - For each $k = 1$ to $n$:
         - sum = sum + A[i,k] × B[k,j].
       - Assign C[i,j] = sum.
5. Return result matrix.

## 13. Dot Multiplication (dotMatrix)
1. Input: ID of Matrix A of dimension m × n and a scalar k.
1. Create an empty matrix C with dimensions rows(A) × cols(A).
2. Multiply each element of matrix A by a scalar k:
   - C[i,j] = k * A[i,j].
3. Return result matrix.

## 14. Degree Conversion (degMatrix)
1. Input: ID of Matrix A of dimension m × n and a scalar k.
1. Check dimension compatibility:
   - If cols(A) ≠ rows(A), throw error.
2. Create an empty matrix C with dimensions rows(A) × cols(A).
3. Multiply matrix A by itself $k$ times (k is a given number):
   - C = A × ... × A (k times).
4. Return result matrix.

## 15. Determinant (detMatrix)
1. Input: ID of Square matrix A (n × n).
2. Initialize det = 1.
3. For each i from 0 to n-1:
   - If A[i,i] = 0:
     - Find a row k > i such that A[k,i] ≠ 0.
     - If no such row exists, return 0.
     - Swap rows i and k; update determinant sign: det = -det.
   - For each j from i+1 to n-1:
     - Compute factor = A[j,i] / A[i,i].
     - Subtract (factor * row_i) from (row_j).
   - Multiply det by diagonal element A[i,i]: det = det * A[i,i].
4. Return det.

## 16. Negative (negMatrix)
1. Input: ID of Square matrix A (n × n).
1. Create an empty matrix C with dimensions rows(A) × cols(A).
2. Multiply each element of matrix A by -1:
   - C[i,j] = (-1) * A[i,j].
3. Return result matrix.

## 17. Transposition (transpMatrix)
1. Input: ID of Matrix A (m × n)
1. Create an empty matrix C with dimensions cols(A) × rows(A).
2. Change values for rows and cols:
   - cols(C) = rows(A).
   - rows(C) = cols(A).
2. Compute the result:
   - C[i,j] = A[j,i].
3. Return result matrix.

## 18. Inversion (invMatrix)
1. Input: ID of square matrix A of size n × n.  
2. Form augmented matrix: [A | I_n], where I_n is the n × n identity.  
3. Gauss–Jordan elimination:  
   1. For each i = 1 to n:  
      1. Pivoting:  
      - If the pivot entry A[i,i] = 0, find a row k > i such that A[k,i] ≠ 0.  
         - If no such row exists, the matrix is singular (no inverse), throw an error.  
         - Else, swap row i and row k of the augmented matrix.  
      2. Normalize pivot row:  
         - Let pivot = A[i,i].  
         - Divide every entry in row i by pivot so that the new pivot A[i,i] = 1.  
      3. Eliminate other entries in column i:  
         - For each j = 1 to n, j ≠ i:  
           1. Let factor = A[j,i].  
           2. Subtract (factor * row_i) from (row_j) so that A[j,i] becomes 0.  
4. Extract inverse: once the left block is reduced to I_n, the right block of the augmented matrix is A^(-1).  
5. Return: the right n × n block as the inverse matrix A^(-1).
         - Let pivot = A[i,i].  
         - Divide every entry in row i by pivot so that the new pivot A[i,i] = 1.  
      3. Eliminate other entries in column $i$:  
         - For each j from 1 to n, j ≠ i:  
           1. Let factor = A[j,i].  
           2. Subtract factor \times row_i from row_j so that A[j,i] becomes 0.  
4. Extract inverse: once the left block is reduced to I_n, the right block of the augmented matrix is A^(-1).  
5. Return: the right n × n block as the inverse matrix A^(-1).

## 19. Check Matrix ID (checkID)

1. Input: matrix ID. 
2. Verify matrix ID:
   - Read the first byte from descriptor.
   - If byte not is `1`, throw error.
3. Return:
   - If the check passes, moves into `DI` offset of the decriptor of the matrix with ID in a matrix storage.

## 20. Check if Matrix is Numeric (checkNumMat)

1. Input: matrix ID. 
2. Verify matrix ID.
3. Access matrix descriptor:
   - Read Data Pointer, Rows (R), and Columns (C).
4. Check elements:
   - Iterate over R×C elements in the matrix starting from Data Pointer.
   - For each element:  
   - If the exponent is `0xFF` and the mantissa is non-zero then `CL` = `01` and exit.
   - If the exponent is `0xFF` and the mantissa is zero, then `CL` = `01` and exit.
   - If the exponent is `0x0F` and the mantissa is zero, then `CL` = `01` and exit.
5. Return type of matrix.
