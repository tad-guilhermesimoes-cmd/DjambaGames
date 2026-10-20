@echo off
rem Inicia o MySQL portatil e a API do AmparaPet. Ctrl+C (ou fechar a janela) para so a API; parar.bat desliga tudo.
cd /d "%~dp0"
if not exist ".venv\Scripts\python.exe" call instalar.bat || exit /b 1
if not exist ".env" copy ".env.example" ".env" >nul
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\banco.ps1 iniciar || (pause & exit /b 1)
echo.
echo  Interface de teste: http://localhost:8000/teste/
echo  Documentacao da API: http://localhost:8000/docs
echo.
cd backend
"..\.venv\Scripts\python.exe" -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
