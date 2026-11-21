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
".venv\Scripts\python.exe" src\hello.py
if errorlevel 1 exit /b 1
exit /b 0