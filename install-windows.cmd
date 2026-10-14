@echo off
rem IoTMart Agent Kit - double-click to install (Windows)
chcp 65001 >nul
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0scripts\install.ps1" %*
if errorlevel 1 pause
