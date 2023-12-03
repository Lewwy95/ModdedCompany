@echo off
setlocal

:: Uninstall All Mods
echo Uninstalling current mods...
timeout /t 1 /nobreak >nul

:: Delete All Mods
if exist "%~dp0..\BepInEx" del /s /q "%~dp0..\BepInEx\*"
if exist "%~dp0..\BepInEx" rmdir /s /q "%~dp0..\BepInEx"
if exist "%~dp0..\doorstop_config.ini" del /s /q "%~dp0..\doorstop_config.ini"
if exist "%~dp0..\winhttp.dll" del /s /q "%~dp0..\winhttp.dll"
cls

:: Finish
endlocal
