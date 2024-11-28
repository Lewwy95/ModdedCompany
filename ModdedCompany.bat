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
echo.
powershell -c "(New-Object System.Net.WebClient).DownloadFile('https://github.com/Lewwy95/ModdedCompany/archive/refs/heads/main.zip','%~dp0\bin\Temp\ModdedCompany-main.zip')"
cls

:: Extract Latest Revision
echo Extracting latest revision...
powershell -c "Expand-Archive '%~dp0\bin\Temp\ModdedCompany-main.zip' -Force '%~dp0\bin\Temp'"
cls

:: Clear Mods Folder
echo Clearing mods folder...
del /s /q "%~dp0\bin\Mods\*"
rmdir /s /q "%~dp0\bin\Mods"
mkdir "%~dp0\bin\Mods"
cls

:: Clear Configs Folder
echo Clearing configs folder...
del /s /q "%~dp0\bin\Configs\*"
rmdir /s /q "%~dp0\bin\Configs"
mkdir "%~dp0\bin\Configs"
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
    :: Create the core folders and move the files
    powershell -c "Expand-Archive '%~dp0\bin\Mods\BepInEx.zip' -Force '%~dp0\bin\Temp'"
    xcopy /f /y "%~dp0\bin\Temp\BepInEx\BepInEx\*" "%~dp0..\BepInEx"
    timeout /t 2 /nobreak >nul

    :: Make unique mod and dependency folders
    mkdir "%~dp0..\BepInEx\patchers\FixPluginTypesSerialization"
    mkdir "%~dp0..\BepInEx\config\MoreSuitsConfig"
    mkdir "%~dp0..\BepInEx\plugins\moresuits"
    mkdir "%~dp0..\BepInEx\plugins\Assets"
    mkdir "%~dp0..\BepInEx\plugins\LethalResonance"
    mkdir "%~dp0..\BepInEx\plugins\CSync"
    timeout /t 2 /nobreak >nul

    :: Copy mods and dependencies over
    xcopy /f /y "%~dp0\bin\Configs\*" "%~dp0..\BepInEx\config"
    xcopy /f /y "%~dp0\bin\Mods\*.dll" "%~dp0..\BepInEx\plugins"
    xcopy /f /y "%~dp0\bin\Mods\moresuits\*" "%~dp0..\BepInEx\plugins\moresuits"
    xcopy /f /y "%~dp0\bin\Mods\Assets\*" "%~dp0..\BepInEx\plugins\Assets"
    xcopy /f /y "%~dp0\bin\Mods\LethalResonance\*" "%~dp0..\BepInEx\plugins\LethalResonance"
    xcopy /f /y "%~dp0\bin\Mods\CSync\*" "%~dp0..\BepInEx\plugins\CSync"
    xcopy /f /y "%~dp0\bin\Core\*" "%~dp0..\BepInEx\core"
    xcopy /f /y "%~dp0\bin\Patchers\*" "%~dp0..\BepInEx\patchers"
    copy "%~dp0\bin\Temp\BepInEx\doorstop_config.ini" "%~dp0..\"
    copy "%~dp0\bin\Temp\BepInEx\winhttp.dll" "%~dp0..\"
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
echo - CustomDeathPenalty>> modlist.txt
echo - FasterItemDropship>> modlist.txt
echo - Helmet Cameras>> modlist.txt
echo - HideChat>> modlist.txt
echo - IntroTweaks>> modlist.txt
echo - LCUltrawide>> modlist.txt
echo - LETHALRESONANCE>> modlist.txt
echo - Mimics>> modlist.txt
echo - MoreBlood>> modlist.txt
echo - MoreCompany>> modlist.txt
echo - More Suits>> modlist.txt
echo - QuickRestart>> modlist.txt
echo - QuotaRollover>> modlist.txt
echo - ReservedFlashlightSlot>> modlist.txt
echo - ReservedWalkieSlot>> modlist.txt
echo - ScrollInverter>> modlist.txt
echo - ShipLoot>> modlist.txt
echo - TooManyEmotes>> modlist.txt
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
