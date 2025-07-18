### Requirements before starting:
1. The repository must be uploaded to the local machine, or the repository files must be copied without disturbing the file structure of the project
2. In the launch directory of the `build' file.bat` there must be files `DOSXNT.EXE `, `LIB.EXE` and `MASM.EXE `, or these files should be added to the local PATH variable using the command `SET PATH=%PATH%;C:\{route}`
3. Add the LIB file.INC to the directory, either write or write in 'main.asm' instead of the string `include LIB.inc` the string `include ../code/LIB.INC`.
