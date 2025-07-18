@echo off
:: compile lib modules 
ml /c ..\code\Add.asm
if errorlevel 1 goto compile_error
ml /c ..\code\Deg.asm 
if errorlevel 1 goto compile_error
ml /c ..\code\Det.asm 
if errorlevel 1 goto compile_error
ml /c ..\code\DotScal.asm 
if errorlevel 1 goto compile_error
ml /c ..\code\Inv.asm 
if errorlevel 1 goto compile_error
ml /c ..\code\Matrix.asm 
if errorlevel 1 goto compile_error
ml /c ..\code\Mul.asm 
if errorlevel 1 goto compile_error
ml /c ..\code\Neg.asm 
if errorlevel 1 goto compile_error
ml /c ..\code\StrInt.asm 
if errorlevel 1 goto compile_error
ml /c ..\code\Sub.asm 
if errorlevel 1 goto compile_error
ml /c ..\code\Tools.asm 
if errorlevel 1 goto compile_error
ml /c ..\code\Transp.asm 
if errorlevel 1 goto compile_error


:: compile test modules
ml /c test_1.asm 
if errorlevel 1 goto compile_error
ml /c test_2.asm 
if errorlevel 1 goto compile_error
ml /c test_3.asm 
if errorlevel 1 goto compile_error
ml /c test_4.asm 
if errorlevel 1 goto compile_error
ml /c test_5.asm 
if errorlevel 1 goto compile_error
ml /c test_6.asm 
if errorlevel 1 goto compile_error
ml /c test_7.asm 
if errorlevel 1 goto compile_error
ml /c test_8.asm 
if errorlevel 1 goto compile_error
ml /c test_9.asm 
if errorlevel 1 goto compile_error
ml /c test_10.asm 
if errorlevel 1 goto compile_error
ml /c test_11.asm 
if errorlevel 1 goto compile_error
ml /c test_12.asm 
if errorlevel 1 goto compile_error
ml /c test_13.asm 
if errorlevel 1 goto compile_error
ml /c test_14.asm 
if errorlevel 1 goto compile_error
ml /c test_15.asm 
if errorlevel 1 goto compile_error
ml /c test_16.asm 
if errorlevel 1 goto compile_error
ml /c test_17.asm 
if errorlevel 1 goto compile_error
ml /c test_18.asm 
if errorlevel 1 goto compile_error
ml /c test_19.asm 
if errorlevel 1 goto compile_error
ml /c test_20.asm 
if errorlevel 1 goto compile_error
ml /c test_21.asm 
if errorlevel 1 goto compile_error


::linking and testing
link test_1.obj matrix.obj , 1.exe,,,
if errorlevel 1 goto link_error
1.exe
if errorlevel 2 echo Error in test 2
if errorlevel 2 goto end
if errorlevel 1 echo Error in test 1
if errorlevel 1 goto end
echo All tests in test_1 passed successfully

link test_2.obj matrix.obj , 2.exe,,,
if errorlevel 1 goto link_error
2.exe
if errorlevel 3 echo Error in test 3
if errorlevel 3 goto end
if errorlevel 2 echo Error in test 2
if errorlevel 2 goto end
if errorlevel 1 echo Error in test 1
if errorlevel 1 goto end
echo All tests in test_2 passed successfully

link test_3.obj matrix.obj , 3.exe,,,
if errorlevel 1 goto link_error
3.exe
if errorlevel 2 echo Error in test 2
if errorlevel 2 goto end
if errorlevel 1 echo Error in test 1
if errorlevel 1 goto end
echo All tests in test_3 passed successfully

link test_4.obj matrix.obj tools.obj , 4.exe,,,
if errorlevel 1 goto link_error
4.exe
if errorlevel 3 echo Error in test 3
if errorlevel 3 goto end
if errorlevel 2 echo Error in test 2
if errorlevel 2 goto end
if errorlevel 1 echo Error in test 1
if errorlevel 1 goto end
echo All tests in test_4 passed successfully

link test_5.obj matrix.obj tools.obj , 5.exe,,,
if errorlevel 1 goto link_error
5.exe
if errorlevel 3 echo Error in test 3
if errorlevel 3 goto end
if errorlevel 2 echo Error in test 2
if errorlevel 2 goto end
if errorlevel 1 echo Error in test 1
if errorlevel 1 goto end
echo All tests in test_5 passed successfully

link test_6.obj matrix.obj tools.obj , 6.exe,,,
if errorlevel 1 goto link_error
6.exe
if errorlevel 2 echo Error in test 2
if errorlevel 2 goto end
if errorlevel 1 echo Error in test 1
if errorlevel 1 goto end
echo All tests in test_6 passed successfully

link test_7.obj matrix.obj tools.obj add.obj , 7.exe,,,
if errorlevel 1 goto link_error
7.exe
if errorlevel 2 echo Error in test 2
if errorlevel 2 goto end
if errorlevel 1 echo Error in test 1
if errorlevel 1 goto end
echo All tests in test_7 passed successfully

link test_8.obj matrix.obj tools.obj sub.obj , 8.exe,,,
if errorlevel 1 goto link_error
8.exe
if errorlevel 2 echo Error in test 2
if errorlevel 2 goto end
if errorlevel 1 echo Error in test 1
if errorlevel 1 goto end
echo All tests in test_8 passed successfully

link test_9.obj matrix.obj tools.obj mul.obj , 9.exe,,,
if errorlevel 1 goto link_error
9.exe
if errorlevel 2 echo Error in test 2
if errorlevel 2 goto end
if errorlevel 1 echo Error in test 1
if errorlevel 1 goto end
echo All tests in test_9 passed successfully

link test_10.obj matrix.obj tools.obj dotscal.obj , 10.exe,,,
if errorlevel 1 goto link_error
10.exe
if errorlevel 1 echo Error in test 1
if errorlevel 1 goto end
echo All tests in test_10 passed successfully

link test_11.obj matrix.obj tools.obj deg.obj mul.obj, 11.exe,,,
if errorlevel 1 goto link_error
11.exe
if errorlevel 3 echo Error in test 3
if errorlevel 3 goto end
if errorlevel 2 echo Error in test 2
if errorlevel 2 goto end
if errorlevel 1 echo Error in test 1
if errorlevel 1 goto end
echo All tests in test_11 passed successfully

link test_12.obj matrix.obj tools.obj  det.obj, 12.exe,,,
if errorlevel 1 goto link_error
12.exe
if errorlevel 3 echo Error in test 3
if errorlevel 3 goto end
if errorlevel 2 echo Error in test 2
if errorlevel 2 goto end
if errorlevel 1 echo Error in test 1
if errorlevel 1 goto end
echo All tests in test_12 passed successfully

link test_13.obj matrix.obj tools.obj neg.obj, 13.exe,,,
if errorlevel 1 goto link_error
13.exe
if errorlevel 1 echo Error in test 1
if errorlevel 1 goto end
echo All tests in test_13 passed successfully

link test_14.obj matrix.obj tools.obj transp.obj, 14.exe,,,
if errorlevel 1 goto link_error
14.exe
if errorlevel 1 echo Error in test 1
if errorlevel 1 goto end
echo All tests in test_14 passed successfully

link test_15.obj matrix.obj tools.obj  inv.obj, 15.exe,,,
if errorlevel 1 goto link_error
15.exe
if errorlevel 3 echo Error in test 3
if errorlevel 3 goto end
if errorlevel 2 echo Error in test 2
if errorlevel 2 goto end
if errorlevel 1 echo Error in test 1
if errorlevel 1 goto end
echo All tests in test_15 passed successfully

link test_16.obj matrix.obj tools.obj strint.obj, 16.exe,,,
if errorlevel 1 goto link_error
16.exe
if errorlevel 1 echo Error in test 1
if errorlevel 1 goto end
echo All tests in test_16 passed successfully

link test_17.obj matrix.obj tools.obj strint.obj, 17.exe,,,
if errorlevel 1 goto link_error
17.exe
if errorlevel 1 echo Error in test 1
if errorlevel 1 goto end
echo All tests in test_17 passed successfully

link test_18.obj matrix.obj tools.obj strint.obj, 18.exe,,,
if errorlevel 1 goto link_error
18.exe
if errorlevel 4 echo Error in test 4
if errorlevel 4 goto end
if errorlevel 3 echo Error in test 3
if errorlevel 3 goto end
if errorlevel 2 echo Error in test 2
if errorlevel 2 goto end
if errorlevel 1 echo Error in test 1
if errorlevel 1 goto end
echo All tests in test_18 passed successfully

link test_19.obj matrix.obj tools.obj strint.obj, 19.exe,,,
if errorlevel 1 goto link_error
19.exe
if errorlevel 4 echo Error in test 4
if errorlevel 4 goto end
if errorlevel 3 echo Error in test 3
if errorlevel 3 goto end
if errorlevel 2 echo Error in test 2
if errorlevel 2 goto end
if errorlevel 1 echo Error in test 1
if errorlevel 1 goto end
echo All tests in test_19 passed successfully

link test_20.obj matrix.obj tools.obj , 20.exe,,,
if errorlevel 1 goto link_error
20.exe
if errorlevel 3 echo Error in test 3
if errorlevel 3 goto end
if errorlevel 2 echo Error in test 2
if errorlevel 2 goto end
if errorlevel 1 echo Error in test 1
if errorlevel 1 goto end
echo All tests in test_20 passed successfully

link test_21.obj matrix.obj tools.obj , 21.exe,,,
if errorlevel 1 goto link_error
21.exe
if errorlevel 3 echo Error in test 3
if errorlevel 3 goto end
if errorlevel 2 echo Error in test 2
if errorlevel 2 goto end
if errorlevel 1 echo Error in test 1
if errorlevel 1 goto end
echo All tests in test_21 passed successfully

goto end
:compile_error
echo Compilation error
goto end
:link_error
echo Linking error
:end