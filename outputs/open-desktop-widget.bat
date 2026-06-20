@echo off
set "HERE=%~dp0"
start "" powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%HERE%start-desktop-widget.ps1"
