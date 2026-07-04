$ErrorActionPreference = "Stop"
$venv = Join-Path $PSScriptRoot ".venv"
$python = Join-Path $venv "Scripts\python.exe"
$main = Join-Path $PSScriptRoot "voice2type\main.py"
& $python $main
