@echo off
setlocal
set "HERE=%~dp0"
set "ROOT=%HERE%.."
set "PORT_FILE=%TEMP%\fifa2026-widget-port.txt"
del "%PORT_FILE%" >nul 2>nul

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$self = $PID; Get-CimInstance Win32_Process | Where-Object { $_.ProcessId -ne $self -and $_.CommandLine -match 'desktop-widget\.ps1|server_worldcup\.py' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }" >nul 2>nul

start "FIFA 2026 Widget Server" /min cmd /c "pushd ""%ROOT%"" && set NO_BROWSER=1&& set WORLDCUP_PORT_FILE=%PORT_FILE%&& py server_worldcup.py"

for /l %%i in (1,1,80) do (
  if exist "%PORT_FILE%" goto :open
  timeout /t 1 /nobreak >nul
)

exit /b 1

:open
set /p PORT=<"%PORT_FILE%"
set "API=http://127.0.0.1:%PORT%/api/worldcup"
start "FIFA 2026 Desktop Widget" powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%HERE%desktop-widget.ps1" -ApiUrl "%API%"
