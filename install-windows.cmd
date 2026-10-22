@echo off
rem IoTMart Agent Kit - double-click to install (Windows)
chcp 65001 >nul
set "IOTMART_AGENT_KIT_LAUNCHER=1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0scripts\install.ps1" %*
set "INSTALLER_EXIT=%ERRORLEVEL%"
set "IOTMART_AGENT_KIT_LAUNCHER="
if not "%INSTALLER_EXIT%"=="0" echo 安裝程式結束，錯誤代碼：%INSTALLER_EXIT%
pause
exit /b %INSTALLER_EXIT%
