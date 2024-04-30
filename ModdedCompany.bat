@echo off
setlocal

:: Create 'Temp' Directory
if not exist "%~dp0\bin\Temp" mkdir "%~dp0\bin\Temp"

:: Set Current Version Number
set /p current=<version.txt

:: Get Latest Version File
echo Comparing versions...
type NUL > "%~dp0\bin\Temp\version_new.txt"
powershell -c "(Invoke-WebRequest -URI 'https://raw.githubusercontent.com/Lewwy95/ModdedCompany/main/version.txt').Content | Set-Content -Path '%~dp0\bin\Temp\version_new.txt'"
cls

:: Set Latest Version Number
set /p new=<"%~dp0\bin\Temp\version_new.txt"

:: Print Version Information
echo Checking for updates...
echo.
echo Current: v%current%
echo Latest: v%new%
timeout /t 2 /nobreak >nul
cls

:: Clear New Version File
del /s /q "%~dp0\bin\Temp\version_new.txt"
cls

:: Check For Different Version Files
if %new% neq %current% (
    echo Update required! Installing...
    timeout /t 2 /nobreak >nul
    cls
    goto install
)

:: Check For Install
if exist "%~dp0..\BepInEx" goto launch

:: Not Installed
echo ModdedCompany is not installed! Installing...
timeout /t 2 /nobreak >nul
cls
goto install

:: Installation/Updater
:install
echo Downloading latest revision...
powershell -c "(New-Object System.Net.WebClient).DownloadFile('https://github.com/Lewwy95/ModdedCompany/archive/refs/heads/main.zip','%~dp0\bin\Temp\ModdedCompany-main.zip')"
cls

:: Extract Latest Revision
echo Extracting latest revision...
powershell -c "Expand-Archive '%~dp0\bin\Temp\ModdedCompany-main.zip' -Force '%~dp0\bin\Temp'"
cls

:: Clear Mods Folder
echo Clearing mods folder...
del /s /q "%~dp0\bin\Mods\*"
cls

:: Deploy Latest Revision
echo Deploying latest revision...
xcopy /s /y "%~dp0\bin\Temp\ModdedCompany-main" "%~dp0"
cls

:: Apply New Version File
break>version.txt
powershell -c "(Invoke-WebRequest -URI 'https://raw.githubusercontent.com/Lewwy95/ModdedCompany/main/version.txt').Content | Set-Content -Path '%~dp0\version.txt'"
cls

:: Uninstall All Mods
call "%~dp0\Uninstall.bat"

:: Move New Mods
echo Installing mods...
if not exist "%~dp0..\BepInEx" (
    mkdir "%~dp0..\BepInEx"
    mkdir "%~dp0..\BepInEx\config"
    mkdir "%~dp0..\BepInEx\core"
    mkdir "%~dp0..\BepInEx\patchers"
    mkdir "%~dp0..\BepInEx\plugins"
    mkdir "%~dp0..\BepInEx\plugins\resAdditionalSuits"
    mkdir "%~dp0..\BepInEx\plugins\HDLethalCompany"
    mkdir "%~dp0..\BepInEx\plugins\LethalConfig"
    mkdir "%~dp0..\BepInEx\plugins\LethalResonance"
    powershell -c "Expand-Archive '%~dp0\bin\Mods\BepInEx.zip' -Force '%~dp0\bin\Temp'"
    xcopy /s /y "%~dp0\bin\Temp\BepInEx\BepInEx\*" "%~dp0..\BepInEx"
    xcopy /s /y "%~dp0\bin\Configs\*" "%~dp0..\BepInEx\config"
    xcopy /s /y "%~dp0\bin\Mods\*.dll" "%~dp0..\BepInEx\plugins"
    xcopy /s /y "%~dp0\bin\Mods\resAdditionalSuits\*" "%~dp0..\BepInEx\plugins\resAdditionalSuits\"
    xcopy /s /y "%~dp0\bin\Mods\HDLethalCompany\*" "%~dp0..\BepInEx\plugins\HDLethalCompany\"
    xcopy /s /y "%~dp0\bin\Mods\LethalConfig\*" "%~dp0..\BepInEx\plugins\LethalConfig\"
    xcopy /s /y "%~dp0\bin\Mods\LethalResonance\*" "%~dp0..\BepInEx\plugins\LethalResonance\"
    xcopy /s /y "%~dp0\bin\Mods\Dependencies\Core\*" "%~dp0..\BepInEx\core\"
    xcopy /s /y "%~dp0\bin\Mods\Dependencies\Patchers\*" "%~dp0..\BepInEx\patchers\"
    copy "%~dp0\bin\Temp\BepInEx\doorstop_config.ini" "%~dp0..\"
    copy "%~dp0\bin\Temp\BepInEx\winhttp.dll" "%~dp0..\"
    del /s /q "%~dp0..\BepInEx\plugins\Dependencies\*"
    rmdir /s /q "%~dp0..\BepInEx\plugins\Dependencies"
)
cls

:: Widescreen Checker
powershell.exe Get-WmiObject win32_videocontroller | find "CurrentHorizontalResolution" > resChecker.txt
powershell.exe Get-WmiObject win32_videocontroller | find "CurrentVerticalResolution" >> resChecker.txt
for /f "tokens=1-2 delims=^:^ " %%a in (resChecker.txt) do set %%a=%%b
if %CurrentHorizontalResolution% neq 3440 goto nowide

:: Widescreen Install
del /s /q "%~dp0\resChecker.txt"
del /s /q "%~dp0..\BepInEx\config\LCUltrawide.cfg"
ren "%~dp0..\BepInEx\config\LCUltrawide_wide.cfg" "LCUltrawide.cfg"
cls
goto modlist

:: No Wide Install
:nowide
del /s /q "%~dp0\resChecker.txt"
del /s /q "%~dp0..\BepInEx\config\LCUltrawide_wide.cfg"
cls

:: Create Text File With Mods
:modlist
if exist "%~dp0\modlist.txt" del /s /q "%~dp0\modlist.txt"
echo Creating mods text file...
echo - Additional Suits> modlist.txt
echo - AlwaysHearActiveWalkies>> modlist.txt
echo - CustomDeathPenalty>> modlist.txt
echo - HDLethalCompany>> modlist.txt
echo - HideChat>> modlist.txt
echo - ItemQuickSwitch>> modlist.txt
echo - LateCompany>> modlist.txt
echo - LethalResonance>> modlist.txt
echo - LetTheDeadRest>> modlist.txt
echo - LBtoKG>> modlist.txt
echo - LCUltrawide>> modlist.txt
echo - Mirage>> modlist.txt
echo - MoreBlood>> modlist.txt
echo - MoreCompany>> modlist.txt
echo - ScrollInverter>> modlist.txt
echo - ShipClock>> modlist.txt
echo - ShipLoot>> modlist.txt
echo - QuickRestart>> modlist.txt
cls

:: Clear 'Temp' Folder
echo Cleaning up...
del /s /q "%~dp0\bin\Temp\*"
rmdir /s /q "%~dp0\bin\Temp"
mkdir "%~dp0\bin\Temp"
cls

:: Launch Game
:launch
echo Launching game...
timeout /t 2 /nobreak >nul
start "" "steam://rungameid/1966720"

:: Finish
endlocal
