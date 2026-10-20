@echo off
rem Roda os testes automatizados (usa o banco amparapet_teste, que e apagado e recriado).
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\banco.ps1 iniciar || (pause & exit /b 1)
cd backend
"..\.venv\Scripts\python.exe" -m pytest -q %*
