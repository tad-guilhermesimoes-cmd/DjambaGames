@echo off
rem Abre o console do MySQL ja conectado no banco amparapet.
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\banco.ps1 console
