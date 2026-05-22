@echo off
REM Mininet Docker Environment Wrapper for Windows
REM This script safely bypasses the local PowerShell execution policy
REM and forwards all your commands directly to the .ps1 script.

PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0docker-run.ps1" %*