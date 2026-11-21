@echo off
setlocal

if exist ".venv\" goto check_venv_python
where python >nul 2>nul
if errorlevel 1 goto python_missing
python -m venv .venv
if errorlevel 1 exit /b 1

:check_venv_python
if exist ".venv\Scripts\python.exe" goto venv_python_ready
echo .venv\Scripts\python.exe is missing. 1>&2
exit /b 1

:python_missing
echo python is required to create .venv. 1>&2
exit /b 1

:venv_python_ready
".venv\Scripts\python.exe" -m pip install -r requirements.txt
if errorlevel 1 exit /b 1
".venv\Scripts\python.exe" -m pytest -v
if errorlevel 1 exit /b 1

if not exist "dist\" mkdir dist
if errorlevel 1 exit /b 1

if exist "dist\hello.py" goto compare_hello
copy /b src\hello.py dist\hello.py >nul
if errorlevel 1 exit /b 1
goto hello_done

:compare_hello
fc /b src\hello.py dist\hello.py >nul
if errorlevel 1 goto hello_conflict

:hello_done
if exist "dist\add.py" goto compare_add
copy /b src\add.py dist\add.py >nul
if errorlevel 1 exit /b 1
goto add_done

:compare_add
fc /b src\add.py dist\add.py >nul
if errorlevel 1 goto add_conflict

:add_done
exit /b 0

:hello_conflict
echo Refusing to overwrite differing file: dist\hello.py 1>&2
exit /b 1

:add_conflict
echo Refusing to overwrite differing file: dist\add.py 1>&2
exit /b 1

:python_missing
echo python is required to create .venv. 1>&2
exit /b 1