param(
    [string]$ModelSize = "medium",
    [switch]$AutoStart
)

$ErrorActionPreference = "Stop"
$PluginDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ToolDir = Join-Path $PluginDir "voice2type"
$VenvDir = Join-Path $PluginDir ".venv"

Write-Host "=== Voice2Type Installer ===" -ForegroundColor Cyan
Write-Host ""

try {
    $py = (Get-Command python).Source
    $ver = & python --version
    Write-Host "Python: $ver" -ForegroundColor Green
} catch {
    Write-Host "Python not found. Please install Python 3.10+" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $VenvDir)) {
    Write-Host "Creating virtual environment..." -ForegroundColor Yellow
    & python -m venv $VenvDir
}

$pip = Join-Path $VenvDir "Scripts\pip.exe"
$python = Join-Path $VenvDir "Scripts\python.exe"

Write-Host "Installing dependencies..." -ForegroundColor Yellow
& $pip install -r (Join-Path $ToolDir "requirements.txt")

Write-Host "Generating icons..." -ForegroundColor Yellow
& $python (Join-Path $ToolDir "assets\generate_icons.py")

Write-Host "Creating config..." -ForegroundColor Yellow
$configDir = "$env:USERPROFILE\.voice2type"
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}
$configPath = Join-Path $configDir "config.json"
if (-not (Test-Path $configPath)) {
    @{
        hotkey = "ctrl+shift+v"
        model_size = $ModelSize
        device = "auto"
        compute_type = "default"
        language = "zh"
        vad_threshold = 0.5
        min_audio_duration_ms = 300
        sample_rate = 16000
        autostart = $AutoStart.IsPresent
    } | ConvertTo-Json | Set-Content -Path $configPath -Encoding UTF8
}

$launcherPath = Join-Path $PluginDir "start_voice2type.ps1"
@"
`$ErrorActionPreference = "Stop"
`$venv = Join-Path `$PSScriptRoot ".venv"
`$python = Join-Path `$venv "Scripts\python.exe"
`$main = Join-Path `$PSScriptRoot "voice2type\main.py"
& `$python `$main
"@ | Set-Content -Path $launcherPath -Encoding UTF8

if ($AutoStart) {
    $startupDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    $shortcutPath = Join-Path $startupDir "Voice2Type.lnk"
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "powershell.exe"
    $shortcut.Arguments = "-WindowStyle Hidden -File `"$launcherPath`""
    $shortcut.Save()
    Write-Host "Auto-start enabled" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Installation complete ===" -ForegroundColor Cyan
Write-Host "Run: $launcherPath" -ForegroundColor Green
Write-Host ""
Write-Host "Press Ctrl+Shift+V to record, release to transcribe."
Write-Host "Config at: ~\.voice2type\config.json"
Write-Host "Logs at:   ~\.voice2type\logs\voice2type.log"
