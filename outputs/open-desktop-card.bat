@echo off
setlocal
set "HERE=%~dp0"
set "ROOT=%HERE%.."
set "PORT_FILE=%TEMP%\fifa2026-card-port.txt"
del "%PORT_FILE%" >nul 2>nul

start "FIFA 2026 Card Server" /min cmd /c "cd /d "%ROOT%" && set NO_BROWSER=1&& set WORLDCUP_PORT_FILE=%PORT_FILE%&& py server_worldcup.py"

for /l %%i in (1,1,80) do (
  if exist "%PORT_FILE%" goto :open
  timeout /t 1 /nobreak >nul
)

echo FIFA 2026 server did not report a port yet.
pause
exit /b 1

:open
set /p PORT=<"%PORT_FILE%"
set "URL=http://127.0.0.1:%PORT%/desktop-card.html"
set "EDGE=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
if not exist "%EDGE%" set "EDGE=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"

if exist "%EDGE%" (
  start "" "%EDGE%" --app="%URL%" --window-size=410,545 --window-position=1460,120
) else (
  start "" "%URL%"
)
