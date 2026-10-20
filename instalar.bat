@echo off
rem Cria o ambiente virtual Python e instala as dependencias. Requer Python 3.11+ no PATH.
cd /d "%~dp0"
if not exist ".venv\Scripts\python.exe" python -m venv .venv || (echo Python nao encontrado & pause & exit /b 1)
".venv\Scripts\python.exe" -m pip install -r backend\requirements.txt || (pause & exit /b 1)
if not exist ".env" copy ".env.example" ".env" >nul
echo Instalacao concluida.
