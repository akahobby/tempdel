@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem Force legacy CMD color mode (no ANSI escape output).
for %%V in (ESC RST BOLD DIM RED GRN YLW BLU CYN WHT) do set "%%V="

call :EnsureElevated
if errorlevel 1 exit /b 0

set "TARGET_1=%TEMP%"
set "TARGET_2=C:\Windows\Temp"
set "TARGET_3=C:\Windows\Prefetch"

set /a TOTAL_FILES=0
set /a TOTAL_DIRS=0
set /a TOTAL_SKIPPED=0
set /a TOTAL_ERRORS=0

call :Header
call :Intro

for %%D in ("%TARGET_1%" "%TARGET_2%" "%TARGET_3%") do (
    call :CleanDirectory "%%~D"
)

call :Summary
exit /b 0

:EnsureElevated
net session >nul 2>&1
if %errorlevel%==0 exit /b 0

echo Requesting Administrator privileges...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
exit /b 1

:Header
cls
color 0B
echo ======================================================================
echo                     TEMPORARY FILE CLEANUP TOOL
echo ======================================================================
color 07
echo UI mode: native CMD colors (ANSI disabled).
echo.
exit /b 0

:Intro
color 07
echo This utility cleans:
echo   [1] %TARGET_1%
echo   [2] %TARGET_2%
echo   [3] %TARGET_3%
echo.
color 0E
echo A UAC prompt will appear automatically if admin rights are required.
color 07
echo.
pause
exit /b 0

:CleanDirectory
set "DIR=%~1"
set /a FILES=0
set /a DIRS=0
set /a ERRORS=0

color 0B
echo ----------------------------------------------------------------------
color 07
echo Cleaning: %DIR%

if not exist "%DIR%" (
    color 0E
    echo   [SKIP] Directory not found.
    color 07
    set /a TOTAL_SKIPPED+=1
    exit /b 0
)

for /f "delims=" %%F in ('dir /a:-d /b /s "%DIR%" 2^>nul') do (
    del /f /q "%%F" >nul 2>&1
    if errorlevel 1 (
        set /a ERRORS+=1
    ) else (
        set /a FILES+=1
    )
)

for /f "delims=" %%G in ('dir /a:d /b /s "%DIR%" 2^>nul ^| sort /R') do (
    rd /s /q "%%G" >nul 2>&1
    if not errorlevel 1 set /a DIRS+=1
)

set /a TOTAL_FILES+=FILES
set /a TOTAL_DIRS+=DIRS
set /a TOTAL_ERRORS+=ERRORS

if !ERRORS! GTR 0 (
    color 0E
    echo   [DONE - WARNINGS] Files deleted: !FILES! ^| Folders removed: !DIRS! ^| Access issues: !ERRORS!
) else (
    color 0A
    echo   [DONE] Files deleted: !FILES! ^| Folders removed: !DIRS!
)
color 07
exit /b 0

:Summary
echo.
color 0B
echo ======================================================================
color 07
echo Cleanup complete.
echo.
color 0A
echo   Total files deleted : %TOTAL_FILES%
echo   Total folders removed: %TOTAL_DIRS%
color 0E
echo   Skipped locations    : %TOTAL_SKIPPED%
if %TOTAL_ERRORS% GTR 0 (
    color 0C
    echo   Access/lock issues  : %TOTAL_ERRORS%
    color 07
    echo   Some files may require elevated privileges or a reboot.
)
color 0B
echo ======================================================================
color 07
echo.
pause
exit /b 0
