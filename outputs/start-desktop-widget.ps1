param()

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Resolve-Path (Join-Path $here "..")
$portFile = Join-Path $env:TEMP "fifa2026-widget-port.txt"
$serverScript = Join-Path $root "server_worldcup.py"
$widgetScript = Join-Path $here "desktop-widget.ps1"

Remove-Item -LiteralPath $portFile -Force -ErrorAction SilentlyContinue

$currentPid = $PID
Get-CimInstance Win32_Process |
  Where-Object {
    $_.ProcessId -ne $currentPid -and
    (
      ($_.Name -eq "powershell.exe" -and $_.CommandLine -like "*-File*desktop-widget.ps1*") -or
      ($_.Name -in @("cmd.exe", "py.exe", "python.exe") -and $_.CommandLine -like "*server_worldcup.py*")
    )
  } |
  ForEach-Object {
    Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
  }

$serverInfo = New-Object System.Diagnostics.ProcessStartInfo
$serverInfo.FileName = "py"
$serverInfo.Arguments = "`"$serverScript`""
$serverInfo.WorkingDirectory = [string]$root
$serverInfo.UseShellExecute = $false
$serverInfo.CreateNoWindow = $true
$serverInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
$serverInfo.EnvironmentVariables["NO_BROWSER"] = "1"
$serverInfo.EnvironmentVariables["WORLDCUP_PORT_FILE"] = $portFile
[System.Diagnostics.Process]::Start($serverInfo) | Out-Null

for ($i = 0; $i -lt 80; $i++) {
  if (Test-Path -LiteralPath $portFile) { break }
  Start-Sleep -Milliseconds 500
}

if (-not (Test-Path -LiteralPath $portFile)) {
  exit 1
}

$port = (Get-Content -LiteralPath $portFile -Raw).Trim()
$apiUrl = "http://127.0.0.1:$port/api/worldcup"

$widgetInfo = New-Object System.Diagnostics.ProcessStartInfo
$widgetInfo.FileName = "powershell.exe"
$widgetInfo.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$widgetScript`" -ApiUrl `"$apiUrl`""
$widgetInfo.WorkingDirectory = $here
$widgetInfo.UseShellExecute = $false
$widgetInfo.CreateNoWindow = $true
$widgetInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
[System.Diagnostics.Process]::Start($widgetInfo) | Out-Null
